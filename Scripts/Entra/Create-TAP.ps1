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
    Import-Module Microsoft.Graph.Identity.SignIns -ErrorAction Stop
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
Connect-GraphIfNeeded -Scopes @("UserAuthenticationMethod.ReadWrite.All")

$UPN = Read-Host "Enter user UPN"
$Lifetime = Read-Host "Enter TAP lifetime in minutes, for example 60"
$UsableOnceAnswer = Read-Host "One-time use? Type YES or NO"

if ($UsableOnceAnswer -eq "YES")
{
    $IsUsableOnce = $true
}
else
{
    $IsUsableOnce = $false
}

$SafeUPN = $UPN -replace '[\\/:*?"<>|]', '_'
$ComputerName = *env:COMPUTERNAME
$TimeStamp = Get-*ate -Format "yyyy-MM-dd_HH-mm-ss"
*$ReportFile = Join-Path $ReportFol*er "$ComputerName-CreateTAP-$SafeU*N-$TimeStamp.txt"

$Body = @{
    *ifetimeInMinutes = [int]$Lifetime
*   isUsableOnce      = $IsUsableOn*e
}

try
{
    $Result = New-MgUse*AuthenticationTemporaryAccessPassM*thod `
        -UserId $UPN `
    *   -BodyParameter $Body `
        *ErrorAction Stop

    Write-Host "*
    Write-Host "Temporary Access *ass created." -ForegroundColor Gre*n
    Write-Host ""
    Write-Host*"TAP value:" -ForegroundColor Yell*w
    Write-Host $Result.Temporary*ccessPass -ForegroundColor Green
 *  Write-Host ""

@"
Temporary Acce*s Pass Created

User: $UPN
Created* $(Get-Date)
Lifetime Minutes: $($*esult.LifetimeInMinutes)
Usable On*e: $($Result.IsUsableOnce)
Start D*te Time: $($Result.StartDateTime)
*s Usable: $($Result.IsUsable)
Meth*d Usability Reason: $($Result.Meth*dUsabilityReason)

TAP Value:
$($R*sult.TemporaryAccessPass)

Importa*t:
The TAP value is sensitive. Del*te this report when it is no longe* needed.
"@ | Out-File $ReportFile*}
catch
{
    "FAILED: $($_.Except*on.Message)" |
        Tee-Object *FilePath $ReportFile
}

Write-Host*""
Write-Host "Report saved to:" -*oregroundColor Green
Write-Host $R*portFile -ForegroundColor Yellow
`*