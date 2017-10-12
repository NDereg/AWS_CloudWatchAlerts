# Import data\data.json
Function Import-Data
{
    [CmdLetBinding()]
    Param()

        $_workspaceRoot = $(Get-Item $PSScriptRoot).Parent.FullName;
        $config = "$_workspaceRoot\data\data.json"
        $configRaw = Get-Content $config -Encoding UTF8 -Raw
        $configRawObject = ConvertFrom-Json $configRaw
        Return $configRawObject
}