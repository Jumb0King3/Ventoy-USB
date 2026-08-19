$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportsFolder = Join-Path $ToolkitRoot "Reports"

if (-not (Test-Path $ReportsFolder))
{
    Write-Host "Reports folder not found." -ForegroundColor Red
    return
}

Write-Host ""
Write-Host "WARNING" -ForegroundColor Red
Write-Host "This will permanently delete ALL report files and diagnostic folders."
Write-Host "The report category folders will be kept."
Write-Host ""

$Confirm = Read-Host "Type DELETE to continue"

if ($Confirm -ne "DELETE")
{
    Write-Host "Cancelled." -ForegroundColor Yellow
    return
}

$DeletedFiles = 0
$DeletedFolders = 0

# Delete report files
Get-ChildItem $ReportsFolder -Recurse -File -ErrorAction SilentlyContinue |
ForEach-Object {
    Remove-Item $_.FullName -Force
    $DeletedFiles++
}

# Delete diagnostic output folders
Get-ChildItem $ReportsFolder -Recurse -Directory -ErrorAction SilentlyContinue |
Sort-Object FullName -Descending |
ForEach-Object {

    # Keep the report category folders
    if (
        $_.FullName -notmatch '\\Reports\\BitLocker$' -and
        $_.FullName -notmatch '\\Reports\\Entra$' -and
        $_.FullName -notmatch '\\Reports\\Intune$' -and
        $_.FullName -notmatch '\\Reports\\Networking$' -and
        $_.FullName -notmatch '\\Reports\\Office$' -and
        $_.FullName -notmatch '\\Reports\\Printers$' -and
        $_.FullName -notmatch '\\Reports\\System$' -and
        $_.FullName -notmatch '\\Reports\\Utilities$'
    )
    {
        Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
        $DeletedFolders++
    }
}

Write-Host ""
Write-Host "Reports cleared successfully." -ForegroundColor Green
Write-Host "Files deleted: $DeletedFiles" -ForegroundColor Yellow
Write-Host "Folders deleted: $DeletedFolders" -ForegroundColor Yellow
Write-Host ""
