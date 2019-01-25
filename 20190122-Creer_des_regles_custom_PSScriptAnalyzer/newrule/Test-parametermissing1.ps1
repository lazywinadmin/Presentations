function Test-parametermissing1
{
    [CmdletBinding()]
    param(
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScripBlockAST
    )

    # Find all the commands in the script
    $ScripBlockAST.FindAll({$args[0] -is [System.Management.Automation.Language.CommandAst]},$true)
}