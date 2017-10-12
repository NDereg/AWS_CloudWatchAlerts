# This script is used to kick off the Main.ps1 script
# If time is between 5:50 am - 6:30 am exit script, otherwise continue
$time = Get-Date -UFormat %R
if ($time -gt "05:50" -and $time -lt "06:30") {
    exit;
}
elseif ($time -gt "11:40" -and $time -lt "12:10") {
    exit;
}

$_workspaceRoot = $(Get-Item $PSScriptRoot).Parent.FullName;
. "$_workspaceRoot\Main.ps1";
Main