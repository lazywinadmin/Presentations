# Joel Sallow
#https://github.com/vexx32/PSWordCloud

Import-Module -Name PSWordCloud

# Une seule command
Get-Help New-WordCloud -ShowWindow

# Voir module (optionnelle)
# ii C:\Users\fxavi\OneDrive\Documents\WindowsPowerShell\Modules\PSWordCloud\1.4.0\

#############
# Example 1 # Simple list
#############
$frpsug="French","PowerShell","FrPSUG","Olivier Miossec",
"LxLechat","Marc Kellerman","Stephane Van Gulick",
"Laurent Lienhard","Francois-Xavier Cat"

$Params = @{
    Path            = '.\Example1.png'
    StrokeWidth     = 1
    StrokeColor     = 'MidnightBlue'
    ImageSize       = 720p
    BackgroundColor = 'Transparent'
    Padding         = 2
    MaxUniqueWords  = 250
}
$frpsug  | New-WordCloud @Params

#############
# Example 2 # Get-Command
#############

(Get-Command -module spacex).Name | New-WordCloud -Path Example2.png

#############
# Example 3 # AST
#############

# Retrieve the commands
$Commands = gci .\AdsiPS\AdsiPS\*.ps1 -Recurse
# Retrieve variable name using AST
$AdsiPSVariables = $Commands | %{
    $Code = Get-Content $_.fullname
    [System.Management.Automation.PSParser]::Tokenize($code,[ref]$Null)|?{$_.Type -eq 'Variable'}
}

# Create cloud
$AdsiPSVariables.content|New-wordcloud -path Example3.png


##################
# Autre Examples #
##################
# Autre examples sympa
https://github.com/vexx32/PSWordCloud/blob/master/Examples/Examples.md

$ExcludeWord |New-WordCloud -Path Excluded.png

# FrPSUG - Past events
# Get-MeetupEvent -GroupName FrenchPSUG -Status past|convertto-json|out-file .\data\frpsug-pastevents.json
$PastEvents = Get-Content .\data\frpsug-pastevents.json|ConvertFrom-Json
$PastEvents.name | New-WordCloud -path FrPSUGPastEvent.png