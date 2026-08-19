$ToolkitRoot = (*et-Item $PSScriptRoot).PSDrive.Roo*

$ReportFolder = Join-Path $Toolk*tRoot "Reports\Entra"

if (-not (T*st-Path $ReportFolder))
{
    New-*tem -Path $ReportFolder -ItemType *irectory -Force | Out-Null
}

func*ion Ensure-GraphModule
{
    if (-*ot (Get-Module -ListAvailable Micr*soft.Graph))
    {
        Write-H*st "Microsoft Graph module not fou*d. Installing..." -ForegroundColor*Yellow
        Install-Module Micr*soft.Graph -Scope CurrentUser -For*e
    }

    Import-Module Microso*t.Graph.Authentication -ErrorActio* Stop
    Import-Module Microsoft.*raph.Identity.SignIns -ErrorAction*Stop
}

function Connect-GraphIfNe*ded
{
    param (
        [string[*]$Scopes
    )

    $Context = Get*MgContext

    if (-not $Context)
*   {
        Connect-MgGraph -Scop*s $Scopes
    }
}

Ensure-GraphMod*le
Connect-GraphIfNeeded -Scopes @*"UserAuthenticationMethod.Read.All*)

$UPN = Read-Host "Enter user UP*"

$SafeUPN = $UPN -replace '[\\/:*?"<>|]', '_'
$ComputerName = $env:*OMPUTERNAME
$TimeStamp = Get-Date *Format "yyyy-MM-dd_HH-mm-ss"

$Rep*rtFile = Join-Path $ReportFolder "*ComputerName-TAPStatus-$SafeUPN-$T*meStamp.txt"

try
{
    $TAP = Get*MgUserAuthenticationTemporaryAcces*PassMethod `
        -UserId $UPN *
        -ErrorAction Stop

    if*($TAP)
    {
        $TAP |
      *     Select-Object Id,
           *              CreatedDateTime,
   *                      StartDateTim*,
                          Lifeti*eInMinutes,
                      *   IsUsable,
                     *    IsUsableOnce,
                *         MethodUsabilityReason |
 *          Format-List |
          * Tee-Object -FilePath $ReportFile
*   }
    else
    {
        "No Te*porary Access Pass found for $UPN.* |
            Tee-Object -FilePat* $ReportFile
    }
}
catch
{
    "*AILED: $($_.Exception.Message)" |
*       Tee-Object -FilePath $Repor*File
}

Write-Host ""
Write-Host "*eport saved to:" -ForegroundColor *reen
Write-Host $ReportFile -Foreg*oundColor Yellow