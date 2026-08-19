$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\Office"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-TeamsCacheClear-$TimeStamp.txt"

Write-Host ""
Write-Host "WARNING" -ForegroundColor Yellow
Write-Host "This will close Teams and clear cache files."
Write-Host ""

$Confirm = Read-Host "Type CLEAR to continue"

if ($Confirm -ne "CLEAR")
{
    Write-Host "Cancelled." -ForegroundColor Yellow
    return
}

"Clearing Teams cache on $ComputerName at $TimeStamp" |
    Tee-Object -FilePath $ReportFile

Stop-Process -Name Teams -Force -ErrorAction SilentlyContinue
Stop-Process -Name ms-teams -Force -ErrorAction SilentlyContinue

$CachePaths = @(
    "$env:APPDATA\Microsoft\Teams",
    "$env:LOCALAPPDATA\Microsoft\Teams"
)

foreach ($Path in $CachePaths)
{
    if (Test-Path $Path)
    {
        try
        {
            "Removing $Path" |
                Tee-Object -FilePath $ReportFile -Append

            Remove-Item `
                -Path $Path `
                -Recurse `
                -Force `
                -ErrorAction Stop
        }
        catch
        {
            $_.Exception.Message |
                Tee-Object -FilePath $ReportFile -Append
        }
    }
}

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow