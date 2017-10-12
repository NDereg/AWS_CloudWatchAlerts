# Main function
$WorkspaceRoot = $(Get-Item $PSScriptRoot).FullName;
Function Main {
    [CmdLetBinding()]
    Param()
    
    # Import functions & modules
    Import-Module AWSPowerShell
    foreach ($file in (Get-ChildItem -Path "$WorkspaceRoot/lib" )) {
        . $file.FullName
    }

    $isVerbose = $PSBoundParameters['Verbose'] -eq $true;
    Write-Host "Importing data\config.json..."
    $configJson = Import-Data -Verbose:$isVerbose;
    Write-Host "Verifying SNS Topic's exists..."
    $snsTopic = Invoke-SnsTopic -CloudWatchConfig $configJson -Verbose:$isVerbose
    Write-Host "Invoking CloudWatch Alarm..."
    Invoke-CloudWatchAlarm -CloudWatchConfig $configJson -Sns $snsTopic -Verbose:$isVerbose
}