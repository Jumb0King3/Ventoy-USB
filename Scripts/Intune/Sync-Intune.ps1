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

$Tasks = Get-ScheduledTask |
    Where-Object {
        $_.TaskPath -like "*EnterpriseMgmt*"
    }

foreach ($Task in $Tasks)
{
    try
    {
        Start-ScheduledTask -InputObject $Task -ErrorAction Stop

        "STARTED: $($Task.TaskName)" |
            Tee-Object -FilePath $ReportFile -Append
    }
    catch
    {
        "SKIPPED: $($Task.TaskName) - $($_.Exception.Message)" |
            Tee-Object -FilePath $ReportFile -Append
    }
}

Write-Host ""
Write-Host "Intune sync tasks processed." -ForegroundColor Green

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow
