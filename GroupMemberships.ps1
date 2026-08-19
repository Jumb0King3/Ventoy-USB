$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\Entra"

if (-not (Test-Path $ReportFolder))
{
    New-Item -Path $ReportFolder -ItemType Directory -Force | Out-Null
}

function Ensure-GraphModule
{
    if (-not (Get-Module -ListAvailable Microsoft.Graph))
    {
        Write-Host "Microsoft Graph module not found. Installing..." -ForegroundColor Yellow
        Install-Module Microsoft.Graph -Scope CurrentUser -Force
    }

    Import-Module Microsoft.Graph.Authentication -ErrorAction Stop
    Import-Module Microsoft.Graph.Users -ErrorAction Stop
}

function Connect-GraphIfNeeded
{
    param (
        [string[]]$Scopes
    )

    $Context = Get-MgContext

    if (-not $Context)
    {
        Connect-MgGraph -Scopes $Scopes
    }
}

Ensure-GraphModule
Connect-GraphIfNeeded -Scopes @("User.Read.All", "Directory.Read.All", "Group.Read.All")

$UPN = Read-Host "Enter user UPN"

$SafeUPN = $UPN -replace '[\\/:*?"<>|]', '_'
$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-GroupMemberships-$SafeUPN-$TimeStamp.txt"

try
{
    $Memberships = Get-MgUserMemberOf `
        -UserId $UPN `
        -All `
        -ErrorAction Stop

    $Report = foreach ($Item in $Memberships)
    {
        [PSCustomObject]@{
            DisplayName = $Item.AdditionalProperties.displayName
            Type        = $Item.AdditionalProperties.'@odata.type'
            Mail        = $Item.AdditionalProperties.mail
            Id          = $Item.Id
        }
    }

    $Report |
        Sort-Object DisplayName |
        Format-Table -AutoSize |
        Out-String |
        Tee-Object -FilePath $ReportFile
}
catch
{
    "FAILED: $($_.Exception.Message)" |
        Tee-Object -FilePath $ReportFile
}

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow