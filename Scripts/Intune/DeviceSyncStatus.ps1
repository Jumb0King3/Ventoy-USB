$ToolkitRoot = (Get-Item $PSScriptRoot).PSDrive.Root

$ReportFolder = Join-Path $ToolkitRoot "Reports\Intune"

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
    Import-Module Microsoft.Graph.DeviceManagement -ErrorAction Stop
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
Connect-GraphIfNeeded -Scopes @("DeviceManagementManagedDevices.Read.All")

$UPN = Read-Host "Enter user UPN"

$SafeUPN = $UPN -replace '[\\/:*?"<>|]', '_'
$ComputerName = $env:COMPUTERNAME
$TimeStamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

$ReportFile = Join-Path $ReportFolder "$ComputerName-DeviceSyncStatus-$SafeUPN-$TimeStamp.txt"

try
{
    $Devices = Get-MgDeviceManagementManagedDevice -All |
        Where-Object { $_.UserPrincipalName -eq $UPN }

    if ($Devices)
    {
        $Devices |
            Select-Object DeviceName,
                          UserPrincipalName,
                          OperatingSystem,
                          OsVersion,
                          ComplianceState,
                          ManagementState,
                          ManagedDeviceOwnerType,
                          LastSyncDateTime,
                          EnrolledDateTime,
                          SerialNumber,
                          Id |
            Sort-Object DeviceName |
            Format-Table -AutoSize |
            Out-String |
            Tee-Object -FilePath $ReportFile
    }
    else
    {
        "No Intune managed devices found for $UPN." |
            Tee-Object -FilePath $ReportFile
    }
}
catch
{
    "FAILED: $($_.Exception.Message)" |
        Tee-Object -FilePath $ReportFile
}

Write-Host ""
Write-Host "Report saved to:" -ForegroundColor Green
Write-Host $ReportFile -ForegroundColor Yellow