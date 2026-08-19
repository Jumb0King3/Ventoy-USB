$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\Printers"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-RemovedNetworkPrinters-$TimeStamp.txt"

$Printers = Get-Printer |
    Where-Object { $_.Type -eq "Connection" }

if (-not $Printers)
{
    Write-Host "No network printers found." -ForegroundColor Yellow

    "No network printers found." |
        Out-File $ReportFile

    return
}

Write-Host ""
Write-Host "The following network printers will be removed:" -ForegroundColor Yellow
Write-Host ""

$Printers |
    Format-Table Name,DriverName,PortName -AutoSize

Write-Host ""

$Confirm = Read-Host "Type REMOVE to continue"

if ($Confirm -ne "REMOVE")
{
    Write-Host "Cancelled." -ForegroundColor Yellow
    return
}

foreach ($Printer in $Printers)
{
    try
    {
        Remove-Printer -Name $Printer.Name

        "Removed: $($Printer.Name)" |
            Tee-Object -FilePath $ReportFile -Append
    }
    catch
    {
        "Failed: $($Printer.Name) - $($_.Exception.Message)" |
            Tee-Object -FilePath $ReportFile -Append
    }
}

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow