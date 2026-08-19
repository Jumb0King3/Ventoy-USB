$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\Utilities"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-WingetUpgradeAll-$TimeStamp.txt"

function Install-Winget
{
    Write-Host ""
    Write-Host "Winget not detected." -ForegroundColor Yellow
    Write-Host "Attempting installation..." -ForegroundColor Cyan
    Write-Host ""

    try
    {
        Add-AppxPackage `
            -RegisterByFamilyName `
            -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe `
            -ErrorAction Stop

        Write-Host "Winget installation completed." -ForegroundColor Green
        return $true
    }
    catch
    {
        "FAILED TO INSTALL WINGET: $($_.Exception.Message)" |
            Tee-Object -FilePath $ReportFile -Append

        Write-Host ""
        Write-Host "Winget installation failed." -ForegroundColor Red
        Write-Host "Install App Installer from Microsoft Store manually." -ForegroundColor Yellow

        return $false
    }
}

Write-Host ""
Write-Host "Checking for Winget..." -ForegroundColor Cyan
Write-Host ""

$Winget = Get-Command winget.exe -ErrorAction SilentlyContinue

if (-not $Winget)
{
    if (-not (Install-Winget))
    {
        return
    }

    $Winget = Get-Command winget.exe -ErrorAction SilentlyContinue

    if (-not $Winget)
    {
        Write-Host "Winget still unavailable." -ForegroundColor Red
        return
    }
}

"===== AVAILABLE UPDATES BEFORE =====" |
    Tee-Object -FilePath $ReportFile

winget upgrade `
    --include-unknown `
    --accept-source-agreements `
    2>&1 |
    Tee-Object -FilePath $ReportFile -Append

"`r`n===== STARTING WINGET UPGRADE =====" |
    Tee-Object -FilePath $ReportFile -Append

Write-Host ""
Write-Host "Updating applications..." -ForegroundColor Cyan
Write-Host "UAC prompts may appear if required." -ForegroundColor Yellow
Write-Host ""

winget upgrade `
    --all `
    --include-unknown `
    --accept-package-agreements `
    --accept-source-agreements `
    2>&1 |
    Tee-Object -FilePath $ReportFile -Append

"`r`n===== AVAILABLE UPDATES AFTER =====" |
    Tee-Object -FilePath $ReportFile -Append

winget upgrade `
    --include-unknown `
    --accept-source-agreements `
    2>&1 |
    Tee-Object -FilePath $ReportFile -Append

Write-Host ""
Write-Host "Upgrade completed." -ForegroundColor Green
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $
