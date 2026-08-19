$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\Networking"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-NetworkReset-$TimeStamp.txt"

Write-Host ""
Write-Host "WARNING" -ForegroundColor Red
Write-Host "This will reset networking components."
Write-Host ""

$Confirm = Read-Host "Type RESET to continue"

if ($Confirm -ne "RESET")
{
    Write-Host "Cancelled." -ForegroundColor Yellow
    return
}

"===== FLUSH DNS =====" |
    Tee-Object -FilePath $ReportFile

ipconfig /flushdns |
    Tee-Object -FilePath $ReportFile -Append

"`r`n===== WINSOCK RESET =====" |
    Tee-Object -FilePath $ReportFile -Append

netsh winsock reset |
    Tee-Object -FilePath $ReportFile -Append

"`r`n===== TCP/IP RESET =====" |
    Tee-Object -FilePath $ReportFile -Append

netsh int ip reset |
    Tee-Object -FilePath $ReportFile -Append

Write-Host ""
Write-Host "Networking reset complete." -ForegroundColor Green
Write-Host "Restart recommended." -ForegroundColor Yellow

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow