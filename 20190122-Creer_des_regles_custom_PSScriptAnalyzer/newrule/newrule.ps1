# Load your new rule in memory
. c:\demo\newrule\Test-parametermissing1.ps1
. c:\demo\newrule\Test-parametermissing2.ps1
. c:\demo\newrule\Test-parametermissing3.ps1
. c:\demo\newrule\Test-parametermissing4.ps1

# load the script to test
$scriptcode = Get-Content "C:\demo\scripts\MyScript2.ps1"

# Parse the code with AST
$ScriptAst = [System.Management.Automation.Language.Parser]::ParseInput($scriptcode,[ref]$null,[ref]$null)

# Execute the custom rule against the script
Test-parametermissing1 -ScripBlockAST $ScriptAst # commands
Test-parametermissing2 -ScripBlockAST $ScriptAst # parameters that should be present
Test-parametermissing3 -ScripBlockAST $ScriptAst # Command used
Test-parametermissing4 -ScripBlockAST $ScriptAst # final (nous verifions si le parameter est present dans la command complete)