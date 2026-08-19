$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root
$ReportFolder = Join-Path $ToolkitRoot "Reports\BitLocker"

if (-not (Test-Path $ReportFolder)) {
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ReportFile = Join-Path $ReportFolder "$ComputerName-BitLockerKeyBackup-$TimeStamp.txt"

Write-Host "This script attempts to back up BitLocker recovery keys to Entra ID." -ForegroundColor Yellow
Write-Host "Only use this on organisation-managed Entra joined or hybrid joined devices." -ForegroundColor Yellow
Write-Host ""

$Confirm = Read-Host "Type YES to continue"

if ($Confirm -ne "YES") {
    Write-Host "Cancelled." -ForegroundColor Red
    exit
}

$Volumes = Get-BitLockerVolume

foreach ($Volume in $Volumes) {
    foreach ($Protector in $Volume.KeyProtector) {
        if ($Protector.KeyProtectorType -eq "RecoveryPassword") {
            try {
                BackupToAAD-BitLockerKeyProtector -MountPoint $Volume.MountPoint -KeyProtectorId $Protector.KeyProtectorId

                "SUCCESS: Backed up recovery key for $($Volume.MountPoint)" |
                    Tee-Object -FilePath $ReportFile -Append
            }
            catch {
                "FAILED: $($Volume.MountPoint) - $($_.Exception.Message)" |
                    Tee-Object -FilePath $ReportFile -Append
            }
        }
    }
}

Write-Host ""
Write-Host "BitLocker backup report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow