$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\System"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-BatteryReport-$TimeStamp.html"

Write-Host ""
Write-Host "Generating battery report..." -ForegroundColor Cyan

powercfg /batteryreport /output $ReportFile

Write-Host ""
Write-Host "Battery report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow