$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\System"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-RecentUpdates-$TimeStamp.txt"

Get-HotFix |
    Sort-Object InstalledOn -Descending |
    Select-Object -First 50 |
    Format-Table -AutoSize |
    Out-String |
    Tee-Object -FilePath $ReportFile

Write-Host ""
Write-Host "Recent updates report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow