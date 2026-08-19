$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\Intune"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$OutputFolder = Join-Path $ReportFolder "$ComputerName-IntuneDiagnostics-$TimeStamp"

New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null

$IMELogPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"

Write-Host ""
Write-Host "Collecting Intune diagnostics..." -ForegroundColor Cyan
Write-Host ""

Get-ComputerInfo |
    Out-File (Join-Path $OutputFolder "DeviceInfo.txt")

dsregcmd /status |
    Out-File (Join-Path $OutputFolder "EntraStatus.txt")

if (Test-Path $IMELogPath)
{
    Copy-Item `
        -Path "$IMELogPath\*" `
        -Destination $OutputFolder `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue
}

try
{
    mdmdiagnosticstool.exe `
        -area DeviceEnrollment,DeviceProvisioning,Autopilot `
        -cab (Join-Path $OutputFolder "MDMDiagnostics.cab")
}
catch
{
    $_.Exception.Message |
        Out-File (Join-Path $OutputFolder "MDMDiagnostics-Error.txt")
}

Write-Host ""
Write-Host "Diagnostics saved to:" -ForegroundColor Green
Write-Host $OutputFolder -ForegroundColor Yellow