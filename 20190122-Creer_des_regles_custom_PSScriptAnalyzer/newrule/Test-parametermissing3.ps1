function Test-parametermissing3
{
    [CmdletBinding()]
    param(
        [System.Management.Automation.Language.ScriptBlockAst]
        $ScripBlockAST
    )

    # Find all the commands in the script
    $CommandAST = $ScripBlockAST.FindAll({$args[0] -is [System.Management.Automation.Language.CommandAst]},$true)
    foreach ($CurrentCommand in $CommandAST)
    {
            # command
            $CurrentCommand.tostring()

    }# foreach
    #>
}