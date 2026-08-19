$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\Office"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-OfficeVersion-$TimeStamp.txt"

$OfficeConfigPath = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration"

if (Test-Path $OfficeConfigPath)
{
    Get-ItemProperty $OfficeConfigPath |
        Select-Object ProductReleaseIds,
                      ClientVersionToReport,
                      VersionToReport,
                      CDNBaseUrl,
                      UpdateChannel,
                      Platform,
                      InstallationPath |
        Format-List |
        Tee-Object -FilePath $ReportFile
}
else
{
    "Office Click-to-Run configuration was not found." |
        Tee-Object -FilePath $ReportFile
}

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow