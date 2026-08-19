$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\System"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-DiskHealth-$TimeStamp.txt"

"===== Physical Disks =====" |
    Tee-Object -FilePath $ReportFile

Get-PhysicalDisk |
    Select-Object FriendlyName,
                  SerialNumber,
                  MediaType,
                  HealthStatus,
                  OperationalStatus,
                  Size |
    Format-Table -AutoSize |
    Out-String |
    Tee-Object -FilePath $ReportFile -Append

"`r`n===== Logical Disks =====" |
    Tee-Object -FilePath $ReportFile -Append

Get-CimInstance Win32_LogicalDisk |
    Select-Object DeviceID,
                  VolumeName,
                  FileSystem,
                  Size,
                  FreeSpace |
    Format-Table -AutoSize |
    Out-String |
    Tee-Object -FilePath $ReportFile -Append

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow