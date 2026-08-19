$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\Networking"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-NetworkInfo-$TimeStamp.txt"

Write-Host ""
Write-Host "Collecting network information..." -ForegroundColor Cyan
Write-Host ""

"===== IPCONFIG =====" | Tee-Object -FilePath $ReportFile

ipconfig /all |
    Tee-Object -FilePath $ReportFile -Append

"`r`n===== ADAPTERS =====" |
    Tee-Object -FilePath $ReportFile -Append

Get-NetAdapter |
    Format-Table -AutoSize |
    Out-String |
    Tee-Object -FilePath $ReportFile -Append

"`r`n===== IP ADDRESSES =====" |
    Tee-Object -FilePath $ReportFile -Append

Get-NetIPAddress |
    Format-Table -AutoSize |
    Out-String |
    Tee-Object -FilePath $ReportFile -Append

"`r`n===== DNS SERVERS =====" |
    Tee-Object -FilePath $ReportFile -Append

Get-DnsClientServerAddress |
    Format-Table -AutoSize |
    Out-String |
    Tee-Object -FilePath $ReportFile -Append

"`r`n===== ROUTES =====" |
    Tee-Object -FilePath $ReportFile -Append

Get-NetRoute |
    Format-Table -AutoSize |
    Out-String |
    Tee-Object -FilePath $ReportFile -Append

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow