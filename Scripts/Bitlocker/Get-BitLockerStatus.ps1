$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root
$ReportFolder = Join-Path $ToolkitRoot "Reports\BitLocker"

if (-not (Test-Path $ReportFolder)) {
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ReportFile = Join-Path $ReportFolder "$ComputerName-BitLockerStatus-$TimeStamp.txt"

Write-Host "Collecting BitLocker status..." -ForegroundColor Cyan
Write-Host ""

Get-BitLockerVolume |
    Select-Object MountPoint,
                  VolumeStatus,
                  ProtectionStatus,
                  EncryptionPercentage,
                  LockStatus,
                  AutoUnlockEnabled,
                  KeyProtector |
    Format-List |
    Tee-Object -FilePath $ReportFile

Write-Host ""
Write-Host "BitLocker report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow