$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\Utilities"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$OutputFolder = Join-Path $ReportFolder "$ComputerName-AllDiagnostics-$TimeStamp"

New-Item -Path $OutputFolder -ItemType Directory -Force | Out-Null

Write-Host ""
Write-Host "Collecting diagnostics..." -ForegroundColor Cyan
Write-Host ""

Get-ComputerInfo |
    Out-File (Join-Path $OutputFolder "SystemInfo.txt")

Get-BitLockerVolume |
    Format-List |
    Out-File (Join-Path $OutputFolder "BitLocker.txt")

dsregcmd /status |
    Out-File (Join-Path $OutputFolder "EntraStatus.txt")

ipconfig /all |
    Out-File (Join-Path $OutputFolder "IPConfig.txt")

Get-NetAdapter |
    Format-Table -AutoSize |
    Out-String |
    Out-File (Join-Path $OutputFolder "Adapters.txt")

Get-Printer |
    Format-Table -AutoSize |
    Out-String |
    Out-File (Join-Path $OutputFolder "Printers.txt")

Get-HotFix |
    Sort InstalledOn -Descending |
    Select-Object -First 50 |
    Format-Table -AutoSize |
    Out-String |
    Out-File (Join-Path $OutputFolder "RecentUpdates.txt")

$IMELogPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"

if (Test-Path $IMELogPath)
{
    $IntuneFolder = Join-Path $OutputFolder "IntuneLogs"

    New-Item -Path $IntuneFolder -ItemType Directory -Force | Out-Null

    Copy-Item `
        -Path "$IMELogPath\*" `
        -Destination $IntuneFolder `
        -Recurse `
        -Force `
        -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "Diagnostics saved to:" -ForegroundColor Green
Write-Host $OutputFolder -ForegroundColor Yellow