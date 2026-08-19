$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root
$ReportFolder = Join-Path $ToolkitRoot "Reports\BitLocker"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ReportFile = Join-Path $ReportFolder "$ComputerName-BitLockerKeyBackup-$TimeStamp.txt"

Write-Host "This script attempts to back up BitLocker recovery keys to Entra ID." -ForegroundColor Yellow
Write-Host "Only use this on organisation-managed Entra joined or hybrid joined devices." -ForegroundColor Yellow
Write-Host ""

$Confirm = Read-Host "Type YES to continue"

if ($Confirm -ne "YES")
{
    Write-Host "Cancelled." -ForegroundColor Red
    return
}

@"
==================================================
BitLocker Recovery Key Backup Report

Computer Name: $ComputerName
Date: $(Get-Date)

==================================================

"@ | Out-File $ReportFile

$Volumes = Get-BitLockerVolume

foreach ($Volume in $Volumes)
{
    foreach ($Protector in $Volume.KeyProtector)
    {
        if ($Protector.KeyProtectorType -eq "RecoveryPassword")
        {
            try
            {
                @"
Mount Point: $($Volume.MountPoint)

Recovery Key ID:
$($Protector.KeyProtectorId)

Recovery Password:
$($Protector.RecoveryPassword)

"@ | Tee-Object -FilePath $ReportFile -Append

                BackupToAAD-BitLockerKeyProtector `
                    -MountPoint $Volume.MountPoint `
                    -KeyProtectorId $Protector.KeyProtectorId

                "SUCCESS: Recovery key backed up to Entra ID" |
                    Tee-Object -FilePath $ReportFile -Append

                "" |
                    Tee-Object -FilePath $ReportFile -Append
            }
            catch
            {
                @"
Mount Point: $($Volume.MountPoint)

Recovery Key ID:
$($Protector.KeyProtectorId)

Recovery Password:
$($Protector.RecoveryPassword)

FAILED: $($_.Exception.Message)

"@ | Tee-Object -FilePath $ReportFile -Append
            }
        }
    }
}

Write-Host ""
Write-Host "BitLocker backup report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow
