<# TODO
- Hide Google bookmarks
- Hide chrome plugins
- Hide Desktop icons
- Re-Launch PowerShell sessions
- VSCode Theme: Light for presentation
- Use Mouse with cable ?

#>
#############################
# PowerShell 7 - What's new #
#############################

<# ABOUT ME
- Based in San Francisco Bay, California
- Cloud DevOps Engineer
- @lazywinadmin
- lazywinadmin.com
- Organizer FrPSUG
- Microsoft MVP (since 2014)
#>

<# FRPSUG
-Chat:  frpsug.com/slack
-Watch: frpsug.com/videos
-Speak: frpsug.com/speak
    or contact:
        -Laurent (@IronTux)
        -Olivier (@omiossec_med)
        -Stephane (@stephanevg)
        -FX (@lazywinadmin)
#>


<# CONTENT
- github.com/lazywinadmin/presentations
- github.com/frpsug/presentations
#>

<# DEMO CONTEXT

- Ubuntu 18.04
- PowerShell 7.0.0
- VSCode + PS Extension 2020.3.0

#>

<# AGENDA
-A propos de PowerShell 7
-Installation
-Foreach-Object -Parallel
-New Error functionalities
-New Operators
-Other differences notices
-Windows only features
#>


<# About PowerShell 7
- First Long Term Servicing (LTS) release
- PowerShell 7 is based on .NET Core 3.1
- OS Supported:
  - Windows 8.1, and 10
  - Windows Server 2012, 2012 R2, 2016, and 2019
  - macOS 10.13+
  - Red Hat Enterprise Linux (RHEL) / CentOS 7
  - Fedora 30+
  - Debian 9
  - Ubuntu LTS 16.04+
  - Alpine Linux 3.8+
  - ARM32 and ARM64 flavors of Debian, Ubuntu, and ARM64 Alpine Linux.
- OS unsupported (where PS7 works)
  - Kali Linux
#>



<# Installation

Main methods available, see docs for more details

-Manual     Install from Github Repository (releases)
    https://github.com/PowerShell/PowerShell/releases/tag/v7.0.0

-WinOS      Chocolatey, Microsoft Store
-MacOS      'brew cask install powershell'
-Linux      'sudo apt-get install -y powershell'    (Debian/Ubuntu)
            'sudo yum install -y powershell'        (CentOS/RedHat)

-.Net SDK   'dotnet tool install --global PowerShell'

#>

####################
<# FOREACH-OBJECT -Parallel
####################

-Built-in parallelism
-Use Current directory


https://devblogs.microsoft.com/powershell/powershell-foreach-object-parallel-feature/

ForEach-Object -Parallel <scriptblock>
    [-InputObject <psobject>]
    [-ThrottleLimit <int>]
    [-TimeoutSeconds <int>]
    [-AsJob]
    [-WhatIf] [-Confirm] [<CommonParameters>]
#>

# What is this ?
#- Start some extra runspaces
#- Similar to what some other modules/scripts can already do (ThreadJob, PoshRSJob, Invoke-Parallel)
#- Can be managed by PowerShell Jobs

# Usage
1..5 | Foreach-Object -Parallel {$_}

# Throttle
# Get-Runspace
1..15 | Foreach-Object -Parallel { $((Get-Runspace).count)} -ThrottleLimit 10 # default is 5


# Show Runspace/Thread ID
1..10 | Foreach-Object -Parallel {
    "$_ - PID: $PID - Thread $([System.Threading.Thread]::CurrentThread.ManagedThreadID) - Runspace ID $(([System.Management.Automation.Runspaces.Runspace]::DefaultRunSpace).id)"
}
# Difference between Process/Thread/Runspace:
#   https://stackoverflow.com/questions/54503232/process-vs-instance-vs-runspace-in-powershell
# Process   : Program that run an instruction set
# Thread    : Single instruction
# Runspace  : New PowerShell engine under the same Program (process)


# IMHO: Not really a good candidate in all scenarios, examples:
# -Targetting the same service (AD, Rest API, ...)
#   - Sharing the same api/server resources/services limits
#   - Sharing the same network bandwidth
# -Local execution sharing the same resource (CPU, Storage, ...)
# -Tasks waiting for other things
#
# Example of good usage
# -Short execution for each thread, no wait
# -Multicore machines
# -Gathering data from different services

# Not always faster
measure-Command { 1..100 | Foreach-Object -Process {$_} }
Measure-Command { 1..100 | Foreach-Object -Parallel {$_} } # Default trottle is
Measure-Command { 1..100 | Foreach-Object -Parallel {$_} -ThrottleLimit 20 } # Increase trottle

# Not always faster
Measure-Command { 1..10 | Foreach-Object -Process {Start-Sleep -Seconds 1} }
Measure-Command { 1..10 | Foreach-Object -Parallel {Start-Sleep -Seconds 1} } # Default trottle is
Measure-Command { 1..10 | Foreach-Object -Parallel {Start-Sleep -Seconds 1} -ThrottleLimit 10 } # Increase trottle

# Passing data to the runspaces
$Message = "Output:"

1..8 | ForEach-Object -Parallel {
    "$Using:Message $_"
    Start-Sleep 1
} -ThrottleLimit 4

# Run in parallel as a job
1..10 | ForEach-Object -Parallel {
    "Output: $_"
    Start-Sleep 1
} -ThrottleLimit 2 -AsJob |
Receive-Job -Wait


# Storing Data
# Using thread safe variable references
$threadSafeDictionary = [System.Collections.Concurrent.ConcurrentDictionary[string,object]]::new()
Get-Process | ForEach-Object -Parallel {
    $dict = $using:threadSafeDictionary
    $dict.TryAdd($_.ProcessName, $_)
}

$threadSafeDictionary.Keys      # ProcessName
$threadSafeDictionary.Values    # Process object
$threadSafeDictionary["pwsh"]

# Set timeout
1..5 | Foreach-Object -Parallel {Start-Sleep -s 10} -TimeoutSeconds 1





####################
# SELECT-STRING
####################
# highlights the string that matches the pattern you searched
Get-content ./20200310-PowerShell7-whats_new/stuff.txt |
    Select-String -Pattern 'powershell'


####################
# ERRORVIEW and GET-ERROR
####################
[System.Management.Automation.ErrorView]::
$ErrorView # ConciseView is default
$ErrorView = 'CategoryView'
Write-Error -Message 'Bad!'
Get-ChildItem -Path /fake

$ErrorView = 'NormalView'
Write-Error -Message 'Bad!'
Get-ChildItem -Path /fake

$ErrorView = 'ConciseView'
Write-Error -Message 'Bad!'
Get-ChildItem -Path /fake
# More information if script context (terminal doesn't support ANSI color escape sequences (VT100))
./errortest.ps1
# Colors are set via $ErrorAccentColor
$Host.PrivateData.ErrorAccentColor = 'Cyan'
$Host.PrivateData.ErrorAccentColor = 'Blue'



####################
# GET-ERROR
####################
# Complete detailed view of the fully qualified error
Get-Error
$Error[0] | Get-Error
Get-Error -Newest 2

$Error[0].ScriptStackTrace


####################
<# NULL-COALESCING Operators
####################

    ?? and ??=

#>

######
# ?? #
######
# <statementA> ?? <thing to do if statementA is null>

# BEFORE
$x = $null
if ($null -eq $x) {'x is null'}

# NEW
# example A - $x is null
$x = $null
$x ?? 'x is null'   # if $x is null, show 'x is null'. Else show $x value

# example B - $x is null
$x = $null
$x ?? 2

# example C - $x is NOT null
$x = 1
$x ?? 'x is null'

# example D - real example (if posh-git is not present, install it)
(Get-Module -ListAvailable posh-git) ?? (Install-Module posh-git -WhatIf -Force)

#######
# ??= #
#######
# If left statement is null, assign stuff specified on the right

# BEFORE
if ($null -eq $x) {$x=5}

# NEW in PS 7
$x = $null
$x ??= 5

$x # $x eq 5




<# PIPELINE CHAIN OPERATORS

    && (Ampersand)
    || (Pipe,vertical bar)

#>

# Get-Help about_pipeline_chain_operators
# These use $LASTEXITCODE and $? variables to know if pipeline failed

# &&
# <Command 1> && <Command 2 if Command 1 was successful>
# BEFORE
Get-Process -id $PID ; if ($?) { Write-Output 'Second command' }
# NEW in PS 7
Get-Process -id $PID && Write-Output 'Second command'

# Other examples
install-module adsips -verbose -Force && import-module adsips -verbose
sudo apt update && sudo apt upgrade

# ||
# <Command 1> && <Command 2 if Command 1 was failed>
Write-Error 'Bad' || Write-Output 'Second'
$ErrorActionPreference = 'Continue' # Default 'Continue'
1/0 || "Wow something went wrong"

$ErrorActionPreference = 'Stop' # Default 'Continue'
1/0 || "Wow something went wrong"
#




# Ternary Operator

function testdistance {
    param($start,$end)

    if(($end - $start) -gt 5){
        "more than 5"
    }else{
        "less than 5"
    }
}
Testdistance -start 5 -end 25

#with ternary
function testdistance {
    param($start,$end)

        (($end - $start) -gt 5) ? "THe numbers are more than 5" : "less than 5"
        # <evaluation> ? $true : $false
    }

Testdistance -start 5 -end 25
Testdistance -start 5 -end 6


<#

New features

#>

# PowerShell Jobs
## Foreach-Object parallel can use jobs
1..100 | Foreach-Object -Parallel {"Stuff $_"} -AsJob |Receive-Job -Wait
## Start-job has a WorkDirectory parameter
Start-job -ScriptBlock {"Hey"} -WorkingDirectory (Resolve-Path ~)|Receive-Job -Wait
## Start-job has a PSVersion parameter (only works on Windows)
Start-job -ScriptBlock {"Hey"} -PSVersion 5.1 |Receive-Job -Wait
## Start-job - RunAs32 parameter does not work on 64bits systems
##  to start a 32-bit PowerShell (pwsh) process with RunAs32, you need to have the 32-bit PowerShell installed.

# Invoke-WebRequest
## New Parameter "-SkipHttpErrorCheck"
##  ignore HTTP error statuses and continue to process responses
Invoke-WebRequest -uri 'http://lazywinadmin.com' -SkipHttpErrorCheck
Invoke-RestMethod -uri 'http://lazywinadmin.com' -SkipHttpErrorCheck

## New Parameter for Invoke-RestMethod
Invoke-RestMethod -uri 'http://lazywinadmin.com' -SkipHttpErrorCheck -StatusCodeVariable mystatuscode
$mystatuscode # Contains the status code



#using these new functionality
#requires -version 7


# Update to Test-Connection
# See the traceroute neatly
# Latency
Test-Connection www.microsoft.com
Test-Connection www.microsoft.com -Traceroute
Test-Connection www.microsoft.com -Traceroute -ResolveDestination
# .Net on linux is not perfect great
# Should work on Windows properly

Test-Connection www.microsoft.com -TcpPort 80
Test-Connection www.microsoft.com -MtuSize
(Test-Connection www.microsoft.com).reply #reply from the framework directly

# Was present in ps 3 or 4
Format-Hex
"som string" | Format-Hex


0xFF
# Binary
0b010101010

0b011111 -shl 1
0b011111
0b01111

10u
10u.gettype()

10y
10y.gettype()

10s

# On WIndows
Import-Module ActiveDirectory -UseWindowsPowerShell
# Windows only features
#-GUI tools are back: Out-GridView, Get-Help -ShowWindow, Show-Command
#-Import-Module -UseWindowsPowerShell
#-Get-HotFix (is back, added to .Net Core)
###


[System.Collections.Concurrent.*]




# New Version notification
# https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-70?view=powershell-7#new-version-notification
# once a day PowerShell query online services to determine if a newer version is available
$Env:POWERSHELL_UPDATECHECK
# This need to be set



# Clipboard Cmdlets are back
# Does not seem to work properly on Linux


# Other information
# -Telemetry will monitor more Microsoft Modules
#   https://github.com/PowerShell/PowerShell/pull/10751

# -Group-Object -CaseSensitive fixed
$capitonyms = @(
    [PSCustomObject]@{
        Capitonym = 'Bill'
    }
    [PSCustomObject]@{
        Capitonym = 'bill'
    }
)
$capitonyms | Group-Object -Property Capitonym -AsHashTable -CaseSensitive


####################
# Desired State Configuration (DSC) (Experimental)
####################
## Ability to invoke DSC resources directly from PowerShell 7 (experimental)
Get-ExperimentalFeature -Name PSDesiredStateConfiguration.InvokeDscResource
Enable-ExperimentalFeature -Name PSDesiredStateConfiguration.InvokeDscResource


<# Resources
- Official announcement: https://devblogs.microsoft.com/powershell/announcing-the-powershell-7-0-release-candidate/
- Microsoft doc, PowerShell 7 What's new: https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-70?view=powershell-7
- ChangeLog: https://github.com/PowerShell/PowerShell/blob/master/CHANGELOG/7.0.md
- Breaking changes and Improvements: https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-70?view=powershell-7#breaking-changes-and-improvements
#>