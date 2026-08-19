$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\System"
$DriverFolderRoot = Join-Path $ToolkitRoot "Recovery\Drivers"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

if (-not (Test-Path $DriverFolderRoot))
{
    New-Item -Path $DriverFolderRoot -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$DriverFolder = Join-Path $DriverFolderRoot "$ComputerName-$TimeStamp"

$ReportFile = Join-Path $ReportFolder "$ComputerName-DriverExport-$TimeStamp.txt"

New-Item -Path $DriverFolder -ItemType Directory -Force | Out-Null

Write-Host ""
Write-Host "Exporting drivers..." -ForegroundColor Cyan

try
{
    Export-WindowsDriver `
        -Online `
        -Destination $DriverFolder |
        Tee-Object -FilePath $ReportFile

    Write-Host ""
    Write-Host "Drivers exported to:" -ForegroundColor Green
    Write-Host $DriverFolder -ForegroundColor Yellow

}
catch
{
    $_.Exception.Message |
        Tee-Object -FilePath $ReportFile
}

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow