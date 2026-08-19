$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\Printers"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-PrinterInfo-$TimeStamp.txt"

Write-Host ""
Write-Host "Collecting printer information..." -ForegroundColor Cyan
Write-Host ""

Get-Printer |
    Select-Object Name,
                  Type,
                  DriverName,
                  PortName,
                  Shared,
                  Published,
                  PrinterStatus |
    Format-Table -AutoSize |
    Tee-Object -FilePath $ReportFile

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow