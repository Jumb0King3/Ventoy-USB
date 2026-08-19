$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root
$ScriptsRoot = Join-Path $ToolkitRoot "Scripts"

function Pause-Toolkit
{
    Write-Host ""
    Read-Host "Press Enter to continue"
}

function Format-DisplayName
{
    param (
        [string]$Name
    )

    $DisplayName = [System.IO.Path]::GetFileNameWithoutExtension($Name)

    $DisplayName = $DisplayName -replace "-", " "
    $DisplayName = $DisplayName -replace "_", " "

    return $DisplayName
}

function Show-Header
{
    param (
        [string]$Title
    )

    Clear-Host

    Write-Host "====================================="
    Write-Host "      HELP DESK TECH TOOLKIT"
    Write-Host "====================================="
    Write-Host ""
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ""
}

function Invoke-ToolkitScript
{
    param (
        [string]$ScriptPath
    )

    if (-not (Test-Path $ScriptPath))
    {
        Write-Host ""
        Write-Host "Script not found:" -ForegroundColor Red
        Write-Host $ScriptPath -ForegroundColor Yellow
        Pause-Toolkit
        return
    }

    try
    {
        & $ScriptPath
    }
    catch
    {
        Write-Host ""
        Write-Host "Script failed to run:" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow
    }

    Pause-Toolkit
}

if (-not (Test-Path $ScriptsRoot))
{
    Write-Host ""
    Write-Host "Scripts folder not found:" -ForegroundColor Red
    Write-Host $ScriptsRoot -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    return
}

do
{
    $Folders = Get-ChildItem -Path $ScriptsRoot -Directory |
        Sort-Object Name

    Show-Header -Title "Select a script folder"

    if (-not $Folders)
    {
        Write-Host "No script folders found under:" -ForegroundColor Yellow
        Write-Host $ScriptsRoot -ForegroundColor Yellow
        Pause-Toolkit
        return
    }

    for ($i = 0; $i -lt $Folders.Count; $i++)
    {
        $Number = $i + 1
        Write-Host "$Number - $($Folders[$i].Name)"
    }

    Write-Host "0 - Exit"
    Write-Host ""

    $FolderChoice = Read-Host "Select Folder"

    if ($FolderChoice -eq "0")
    {
        break
    }

    if (-not ($FolderChoice -as [int]))
    {
        Write-Host ""
        Write-Host "Invalid selection." -ForegroundColor Red
        Pause-Toolkit
        continue
    }

    $FolderIndex = [int]$FolderChoice - 1

    if ($FolderIndex -lt 0 -or $FolderIndex -ge $Folders.Count)
    {
        Write-Host ""
        Write-Host "Invalid selection." -ForegroundColor Red
        Pause-Toolkit
        continue
    }

    $SelectedFolder = $Folders[$FolderIndex]

    do
    {
        $Scripts = Get-ChildItem -Path $SelectedFolder.FullName -File -Filter "*.ps1" |
            Where-Object {
                $_.FullName -ne $PSCommandPath
            } |
            Sort-Object BaseName

        Show-Header -Title $SelectedFolder.Name

        if (-not $Scripts)
        {
            Write-Host "No .ps1 scripts found in:" -ForegroundColor Yellow
            Write-Host $SelectedFolder.FullName -ForegroundColor Yellow
            Write-Host ""
            Write-Host "If your scripts are still saved as .txt files, rename them to .ps1 first." -ForegroundColor Yellow
            Write-Host ""
            Write-Host "0 - Back"
            Write-Host ""

            $ScriptChoice = Read-Host "Select Option"

            if ($ScriptChoice -eq "0")
            {
                break
            }

            continue
        }

        for ($i = 0; $i -lt $Scripts.Count; $i++)
        {
            $Number = $i + 1
            $DisplayName = Format-DisplayName -Name $Scripts[$i].Name
            Write-Host "$Number - $DisplayName"
        }

        Write-Host "0 - Back"
        Write-Host ""

        $ScriptChoice = Read-Host "Select Script"

        if ($ScriptChoice -eq "0")
        {
            break
        }

        if (-not ($ScriptChoice -as [int]))
        {
            Write-Host ""
            Write-Host "Invalid selection." -ForegroundColor Red
            Pause-Toolkit
            continue
        }

        $ScriptIndex = [int]$ScriptChoice - 1

        if ($ScriptIndex -lt 0 -or $ScriptIndex -ge $Scripts.Count)
        {
            Write-Host ""
            Write-Host "Invalid selection." -ForegroundColor Red
            Pause-Toolkit
            continue
        }

        $SelectedScript = $Scripts[$ScriptIndex]
        Invoke-ToolkitScript -ScriptPath $SelectedScript.FullName
    }
    while ($true)
} while ($true)
    