$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\Networking"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-M365Connectivity-$TimeStamp.txt"

$Targets = @(
    "login.microsoftonline.com",
    "outlook.office365.com",
    "teams.microsoft.com",
    "office.com",
    "graph.microsoft.com",
    "endpoint.microsoft.com",
    "manage.microsoft.com",
    "windowsupdate.microsoft.com"
)

foreach ($Target in $Targets)
{
    Write-Host "Testing $Target..." -ForegroundColor Cyan

    Test-NetConnection -ComputerName $Target -Port 443 |
        Format-List |
        Tee-Object -FilePath $ReportFile -Append

    "`r`n" |
        Tee-Object -FilePath $ReportFile -Append
}

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow