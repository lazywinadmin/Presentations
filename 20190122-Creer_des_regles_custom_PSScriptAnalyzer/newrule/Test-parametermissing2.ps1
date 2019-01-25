function Test-parametermissing2
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
        # Retrieve all the parameters
        $Parameters=[System.Management.Automation.Language.StaticParameterBinder]::BindCommand($CurrentCommand)
        $Parameters.BoundParameters.Keys
    }# foreach
}