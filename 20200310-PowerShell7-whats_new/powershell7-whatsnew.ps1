<# TODO
- Hide Google bookmarks
- Hide chrome plugins
- Hide Desktop icons
- Re-Launch PowerShell sessions
- VSCode Theme: Light for presentation
- Use Mouse with cable ?
- Silent Slack
- Close Google Hangout/other chats
- Phone on Silent

#>

# Checks Audience
#-Audio
#-Partage d'ecran
#-Theme
#-Font Size


#############################
# PowerShell 7 - What's new #
#############################

<# ABOUT ME
- Francois-Xavier Cat
- Based in San Francisco Bay, California
- Cloud DevOps Engineer
- @lazywinadmin
- lazywinadmin.com
- Organizer FrPSUG
- Microsoft MVP (since 2014)
#>



<# French PowerShell User Group

-Speak: frpsug.com/speak
    or contact:
        -Laurent    (@IronTux)
        -Olivier    (@omiossec_med)
        -Stephane   (@stephanevg)
        -FX         (@lazywinadmin)
-Chat:  frpsug.com/slack
-Watch: frpsug.com/videos
#>






<# CONTENT
- github.com/lazywinadmin/presentations
- github.com/frpsug/presentations
#>



<# DEMO CONTEXT
- Ubuntu 18.04
- PowerShell 7.0.0
- Visual Studio Code
    Powershell Extension 2020.3.0
#>

<# AGENDA
-Installation
-Foreach-Object -Parallel
-New Error functionalities
-New Operators
-Other differences notices
-Windows only features
#>


<# About PowerShell 7
- First Long Term Servicing (LTS) release
    - Release every other year
    - Support for 3 years

    - Current releases are supported for three months after a subsequent Current or LTS release.

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

-WinOS      Chocolatey, Microsoft Store, or:
            'iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"'
-MacOS      'brew cask install powershell'
-Linux      'sudo apt-get install -y powershell'    (Debian/Ubuntu)
            'sudo yum install -y powershell'        (CentOS/RedHat)
            'wget https://aka.ms/install-powershell.sh; sudo bash install-powershell.sh; rm install-powershell.sh'

-.Net SDK   'dotnet tool install --global PowerShell'

#>




####################
<# FOREACH-OBJECT -Parallel
####################

-Built-in parallelism
-Use Current directory

# What is this ?
#- Start some extra runspaces
#- Similar to what some other modules/scripts can already do (ThreadJob, PoshRSJob, Invoke-Parallel)
#- Can be managed by PowerShell Jobs

ForEach-Object -Parallel <scriptblock>
    [-InputObject <psobject>]
    [-ThrottleLimit <int>]
    [-TimeoutSeconds <int>]
    [-AsJob]
    [-WhatIf] [-Confirm] [<CommonParameters>]
#>

# Usage
1..5 | Foreach-Object {$_}
1..5 | Foreach-Object -Parallel {$_}

# Throttle
# Get-Runspace
1..100 | Foreach-Object -Parallel { $((Get-Runspace).count) } -ThrottleLimit 20 # default is 5


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
#
# Great for
# -Gather data from multiple services or end-points
# -Parse process logs
#
#
# Worth noting.. Invoke-Command already have its own parallelism systems
# so not always a good things to combine the two

# Not always faster
measure-Command { 1..100 | Foreach-Object -Process {$_} }
Measure-Command { 1..100 | Foreach-Object -Parallel {$_} } # Default trottle is
Measure-Command { 1..100 | Foreach-Object -Parallel {$_} -ThrottleLimit 20 } # Increase trottle

# Not always faster
Measure-Command { 1..10 | Foreach-Object -Process {Start-Sleep -Seconds 1} }
Measure-Command { 1..10 | Foreach-Object -Parallel {Start-Sleep -Seconds 1} } # Default trottle is
Measure-Command { 1..10 | Foreach-Object -Parallel {Start-Sleep -Seconds 1} -ThrottleLimit 10 } # Increase trottle

# Worth testing against different data-set,
# nothing magic here that works in every cases

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
# https://docs.microsoft.com/en-us/dotnet/standard/collections/thread-safe/
$threadSafeDictionary = [System.Collections.Concurrent.ConcurrentDictionary[string,object]]::new()
Get-Process | ForEach-Object -Parallel {
    $dict = $using:threadSafeDictionary
    $dict.TryAdd($_.ProcessName, $_)
}

$threadSafeDictionary.Keys      # ProcessName
$threadSafeDictionary.Values    # Process object
$threadSafeDictionary["pwsh"]   # Specific value

# Set timeout
1..5 | Foreach-Object -Parallel {Start-Sleep -s 10} -TimeoutSeconds 1





####################
# SELECT-STRING
####################
# highlights the string that matches the pattern you searched
Get-content ./20200310-PowerShell7-whats_new/stuff.txt |
    Select-String -Pattern 'powershell'


####################
# ERRORVIEW
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



####################
<# NULL-COALESCING Operators
####################

    ?? and ??=

#>

######
# ?? #
######
# <statementA> ?? <thing to do if statementA is null>

## BEFORE
$x = $null
if ($null -eq $x) {'x is null'}

## NEW

# example A - $x is null
$x = $null
$x ?? 'x is null'   # if $x is null, show 'x is null'. Else show $x value

# example B - $x is null
$x = $null
$x ?? 2

# example C - $x is NOT null
$x = 1
$x ?? 'x is null'

# example D - if posh-git is not present, install it
(Get-Module -ListAvailable posh-git) ?? (Install-Module posh-git -WhatIf -Force)

# example C - if file 'stuff.txt' exists show content, else get some content and create file
(Get-Content ./stuff.txt -ea 0) ?? ((iwr 'http://lazywinadmin.com').content > ./stuff.txt)


#######
# ??= #
#######
# If left statement is null, assign value specified on the right

## BEFORE
$x = $null
if ($null -eq $x) {$x=5}

## NEW in PS 7
$x = $null
$x ??= 5

$x # $x eq 5






####################
<# PIPELINE CHAIN OPERATORS
####################

    && (double Ampersand) / ('Et' commercial)
    || (double Pipe,vertical bar)

    See 'about_pipeline_chain_operators'
#>

# Use $LASTEXITCODE and $? variables to know if pipeline failed

######
# && #
######

# <Command A> && <Command B if Command A was successful>

## BEFORE
Get-Process -id $PID ; if ($?) { 'Second command' }

# NEW in PS 7
Get-Process -id $PID && 'Second command'

# Other examples
install-module adsips -verbose -Force && import-module adsips -verbose
sudo apt update && sudo apt upgrade




######
# || #
######

# <Command 1> || <Command 2 if Command 1 was failed>

## BEFORE
Get-Process -id abc ; if (-not$?) { Write-Output 'Second command' }

## NEW in PowerShell 7
Get-Process -id abc || Write-Output 'Second command'

# ErrorActionPreference obviously is taken into account
$ErrorActionPreference = 'Continue' # Default 'Continue'
1/0 || "Wow something went wrong"

$ErrorActionPreference = 'Stop' # Default 'Continue'
1/0 || "Wow something went wrong"





####################
# TERNARY OPERATORS
####################

# <evaluation> ? $true : $false

## BEFORE
$start  = 5
$end    = 25
if(($end - $start) -gt 5){
    "more than 5"
}else{
    "less than 5"
}

## NEW in PS7
$start  = 5
$end    = 25

(($end - $start) -gt 5) ? "More than 5" : "Less than 5"

(gmo -list adsips) ? (ipmo adsips) : (install-module adsips -WhatIf)
(get-service myservice) ? (irm http://myservice?getstuff) : (installmyservice.ps1;irm http://myservice?getstuff)


####################
# NEW VERSION NOTIFICATION
####################
# New Version notification
# https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-70?view=powershell-7#new-version-notification
# once a day PowerShell query online services to determine if a newer version is available
$Env:POWERSHELL_UPDATECHECK
# This need to be set

# see pwsh-preview

####################
# WINDOWS ONLY
####################
# On Windows
Import-Module ActiveDirectory -UseWindowsPowerShell

# Import-Module -PSSession

#-GUI tools are back:
#  Out-GridView
#  Get-Help -ShowWindow
#  Show-Command (a valider)
#-Get-HotFix (is back, added to .Net Core)


####################
# OTHER NEW FEATURES
####################

# PowerShell Jobs

## Foreach-Object parallel can use jobs
1..100 | Foreach-Object -Parallel {"Stuff $_"} -AsJob |Receive-Job -Wait

## Start-job has a WorkDirectory parameter
Start-job -ScriptBlock {"Hey"} -WorkingDirectory (Resolve-Path ~)|Receive-Job -Wait

## Start-job has a PSVersion parameter (only works on Windows)
Start-job -ScriptBlock {"Hey"} -PSVersion 5.1 |Receive-Job -Wait
## Start-job - RunAs32 parameter does not work on 64bits systems
##  to start a 32-bit PowerShell (pwsh) process with RunAs32, you need to have the 32-bit PowerShell installed.


# Invoke-WebRequest and Invoke-RestMethod new params

## New Parameter "-SkipHttpErrorCheck"
##  ignore HTTP error statuses and continue to process responses
Invoke-WebRequest -uri 'http://lazywinadmin.com' -SkipHttpErrorCheck
Invoke-RestMethod -uri 'http://lazywinadmin.com' -SkipHttpErrorCheck

## New Parameter for Invoke-RestMethod
Invoke-RestMethod -uri 'http://lazywinadmin.com' -SkipHttpErrorCheck -StatusCodeVariable mystatuscode
$mystatuscode # Contains the status code


# JSON Cmdlets

# New Parameter -AsHashTable
# credit to https://powershell.anovelidea.org/powershell/ps7now-changes-to-json-cmdlets/
$validJson = @'
{
  "array": [
    1,
    2,
    3
  ],
  "boolean": true,
  "null": null,
  "number": 123,
  "object": {
    "a": "b",
    "c": "d"
  },
  "string": "Hello World",
  "String": "Party On!",
  "" : "Empty Property Name1"
}
'@

$validJson | ConvertFrom-Json -AsHashtable

# New Parameter -NoEnumerate
# See: https://github.com/PowerShell/PowerShell/issues/3424

'[1,2,3]' | ConvertFrom-Json |measure
'[1,2,3]' | ConvertFrom-Json -NoEnumerate |measure

# ConvertTo-Json -EnumsAsString
enum CarTypes {
    Compact
    MidSize
    Intermediate
    SUV
    Luxury
}
[CarTypes]::SUV,[CarTypes]::Compact | ConvertTo-Json
[CarTypes]::SUV,[CarTypes]::Compact | ConvertTo-Json -EnumsAsStrings

# ConvertTo-Json -AsArray
"one" | ConvertTo-Json
"one" | ConvertTo-Json -AsArray

# Test-Json


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

####################
# Desired State Configuration (DSC) (Experimental)
####################
## Ability to invoke DSC resources directly from PowerShell 7 (experimental)
Get-ExperimentalFeature -Name PSDesiredStateConfiguration.InvokeDscResource
Enable-ExperimentalFeature -Name PSDesiredStateConfiguration.InvokeDscResource

####################
# More
####################

# Clipboard Cmdlets are back
# Does not seem to work properly on Linux

# Other information
# -Telemetry will monitor more Microsoft Modules
#   https://github.com/PowerShell/PowerShell/pull/10751

# Update to Format-Hex
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
10u.gettype().FullName
10y
10y.gettype().FullName
10s.GetType().FullName





<# Resources
- Official announcement: https://devblogs.microsoft.com/powershell/announcing-the-powershell-7-0-release-candidate/
- Microsoft doc, PowerShell 7 What's new: https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-70?view=powershell-7
- ChangeLog: https://github.com/PowerShell/PowerShell/blob/master/CHANGELOG/7.0.md
- Breaking changes and Improvements: https://docs.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-70?view=powershell-7#breaking-changes-and-improvements
- Foreach-Object -Parallel https://devblogs.microsoft.com/powershell/powershell-foreach-object-parallel-feature/
- SecretsManagement module https://devblogs.microsoft.com/powershell/secrets-management-module-vault-extensions/
#>