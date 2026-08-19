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
$Lifetime = Read-Host "Enter TAP lifetime in minutes (e.g. 60)"
$UsableOnceAnswer = Read-Host "One-time use? Type YES or NO"

$IsUsableOnce = $false

if ($UsableOnceAnswer.ToUpper() -eq "YES")
{
    $IsUsableOnce = $true
}

$SafeUPN = $UPN -replace '[\\/:*?"<>|]', '_'

$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-CreateTAP-$SafeUPN-$TimeStamp.txt"

$Body = @{
    lifetimeInMinutes = [int]$Lifetime
    isUsableOnce      = $IsUsableOnce
}

try
{
    $Result = New-MgUserAuthenticationTemporaryAccessPassMethod `
        -UserId $UPN `
        -BodyParameter $Body `
        -ErrorAction Stop

    Write-Host ""
    Write-Host "Temporary Access Pass Created" -ForegroundColor Green
    Write-Host ""
    Write-Host "TAP Value:" -ForegroundColor Yellow
    Write-Host $Result.TemporaryAccessPass -ForegroundColor Green
    Write-Host ""

@"
Temporary Access Pass Created

User: $UPN
Created: $(Get-Date)

Lifetime Minutes: $($Result.LifetimeInMinutes)
Usable Once: $($Result.IsUsableOnce)
Start Date Time: $($Result.StartDateTime)
Is Usable: $($Result.IsUsable)
Method Usability Reason: $($Result.MethodUsabilityReason)

TAP Value:
$($Result.TemporaryAccessPass)

IMPORTANT:
The TAP value is sensitive.
Delete this report when it is no longer needed.
"@ | Out-File $ReportFile

}
catch
{
    "FAILED: $($_.Exception.Message)" |
        Tee-Object -FilePath $ReportFile
}

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow
