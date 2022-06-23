[bool] $ExitWithError = $true
[bool] $ExitWithNoError = $false
[String] $WingetRelativePath = "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe"

# ------------ DATTO VARIABLES ----------------
[String] $Package_ID = $ENV:DRMM_Package_ID
function Get-DeviceDetails
{
	
	$Date_String = Get-Date -Format "dddd dd/MM/yyyy HH:mm:ss"
	$ComputerName = $ENV:COMPUTERNAME
	
	$DeviceDetails = "Script running on the Computer: $ComputerName on $Date_String`n`n"
	return $DeviceDetails

}
Get-DeviceDetails
function Update-OutputOnExit
{
    param
    (
        [String] $UDF_Value,
        [bool] $ExitCode,
        [String] $Results,
        [String] $Registry_Value
    )

    if ($UDF_Value -and $Registry_Value)
    {
        New-ItemProperty -Path HKLM:\SOFTWARE\CentraStage\ -Name $UDF_Value -PropertyType String -Value $Registry_Value -Force
    }
        
    write-host '<-Start Result->' -ErrorAction SilentlyContinue
    write-host "STATUS=$Results" -ErrorAction SilentlyContinue
    write-host '<-End Result->' -ErrorAction SilentlyContinue
    exit $ExitCode
}

function Get-WingetInstallPath
{
    param
    (
        [String] $F_WingetRelativePath
    )
    $Winget_Paths = Resolve-Path -Path $F_WingetRelativePath -Relative -ErrorAction SilentlyContinue

    if ($Winget_Paths)
    {
        if ($Winget_Paths.count -gt 1)
        {
            $Winget_Path = $Winget_Paths[-1]
            return $Winget_Path
        }
        else
        {
            return $Winget_Paths
        }
    }
    else
    {
        Write-Output "Winget is not installed"
        Update-OutputOnExit -ExitCode $ExitWithError -Results "Winget is not installed"
    }
    
}

$WingetExecutableFolder = Get-WingetInstallPath -F_WingetRelativePath $WingetRelativePath

Write-Output "Winget Install Found at $WingetExecutableFolder"
Set-Location $WingetExecutableFolder

# Now Executing Code using Winget
#.\Winget.exe list --accept-source-agreements

$TestIfPackageExists = .\Winget.exe show $Package_ID --accept-source-agreements
if ($TestIfPackageExists)
{
    .\Winget.exe upgrade --Id $Package_ID --accept-package-agreements --accept-source-agreements --force --silent
}
else
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "Warning. Winget Package $Package_ID not found!"
}

Update-OutputOnExit -ExitCode $ExitWithNoError -Results "Successfully Executed"