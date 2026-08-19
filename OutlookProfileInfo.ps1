$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\Office"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-OutlookProfileInfo-$TimeStamp.txt"

"===== Outlook Data Files =====" |
    Tee-Object -FilePath $ReportFile

$OutlookPath = "$env:LOCALAPPDATA\Microsoft\Outlook"

if (Test-Path $OutlookPath)
{
    Get-ChildItem $OutlookPath -File |
        Select-Object Name,
                      Length,
                      LastWriteTime,
                      FullName |
        Format-Table -AutoSize |
        Out-String |
        Tee-Object -FilePath $ReportFile -Append
}
else
{
    "Outlook folder not found." |
        Tee-Object -FilePath $ReportFile -Append
}

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow