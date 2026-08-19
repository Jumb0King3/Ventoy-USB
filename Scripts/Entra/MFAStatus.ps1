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

function Convert-AuthMethodName
{
    param (
        [string]$ODataType
    )

    switch -Wildcard ($ODataType)
    {
        "*microsoftAuthenticatorAuthenticationMethod"      { "Microsoft Authenticator" }
        "*phoneAuthenticationMethod"                       { "Phone / SMS / Voice" }
        "*fido2AuthenticationMethod"                       { "FIDO2 Security Key" }
        "*windowsHelloForBusinessAuthenticationMethod"     { "Windows Hello for Business" }
        "*temporaryAccessPassAuthenticationMethod"         { "Temporary Access Pass" }
        "*passwordAuthenticationMethod"                    { "Password" }
        "*emailAuthenticationMethod"                       { "Email" }
        "*softwareOathAuthenticationMethod"                { "Software OATH Token" }
        default                                            { $ODataType }
    }
}

Ensure-GraphModule
Connect-GraphIfNeeded -Scopes @("UserAuthenticationMethod.Read.All")

$UPN = Read-Host "Enter user UPN"

$SafeUPN = $UPN -replace '[\\/:*?"<>|]', '_'
$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-MFAStatus-$SafeUPN-$TimeStamp.txt"

try
{
    $Methods = Get-MgUserAuthenticationMethod `
        -UserId $UPN `
        -ErrorAction Stop

    $Report = foreach ($Method in $Methods)
    {
        $ODataType = $Method.AdditionalProperties.'@odata.type'

        [PSCustomObject]@{
            User       = $UPN
            Method     = Convert-AuthMethodName -ODataType $ODataType
            MethodType = $ODataType
            Id         = $Method.Id
        }
    }

    $Report |
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
