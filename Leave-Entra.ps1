$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\Entra"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-LeaveEntra-$TimeStamp.txt"

Write-Host ""
Write-Host "WARNING" -ForegroundColor Red
Write-Host "This will remove the Entra join from this device."
Write-Host ""

$Confirm = Read-Host "Type LEAVE to continue"

if ($Confirm -ne "LEAVE")
{
    Write-Host "Cancelled." -ForegroundColor Yellow
    return
}

"===== BEFORE =====" |
    Tee-Object -FilePath $ReportFile

dsregcmd /status |
    Tee-Object -FilePath $ReportFile -Append

"`r`n===== LEAVE COMMAND =====" |
    Tee-Object -FilePath $ReportFile -Append

dsregcmd /leave |
    Tee-Object -FilePath $ReportFile -Append

"`r`n===== AFTER =====" |
    Tee-Object -FilePath $ReportFile -Append

dsregcmd /status |
    Tee-Object -FilePath $ReportFile -Append

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow