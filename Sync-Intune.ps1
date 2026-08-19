$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\Intune"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-IntuneSync-$TimeStamp.txt"

Write-Host ""
Write-Host "Attempting Intune sync..." -ForegroundColor Cyan
Write-Host ""

try
{
    Get-ScheduledTask |
        Where-Object {
            $_.TaskPath -like "*EnterpriseMgmt*"
        } |
        Start-ScheduledTask

    "Started EnterpriseMgmt scheduled tasks." |
        Tee-Object -FilePath $ReportFile
}
catch
{
    $_.Exception.Message |
        Tee-Object -FilePath $ReportFile
}

Start-Process "ms-settings:workplace"

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow