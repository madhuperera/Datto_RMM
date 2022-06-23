[bool] $ExitWithError = $true
[bool] $ExitWithNoError = $false
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

$Winget_Paths = Resolve-Path -Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe" -Relative -ErrorAction SilentlyContinue

if ($Winget_Paths)
{
    $Winget_Path = $Winget_Paths
    if ($Winget_Paths.count -gt 1)
    {
        Write-Output "Found Multiple Winget Install Folders"
        $Winget_Path = $Winget_Paths[-1]

    }

    Write-Output "Winget Install Found at $Winget_Path"
    Set-Location $Winget_Path
    .\Winget.exe list --accept-source-agreements
    Update-OutputOnExit -ExitCode $ExitWithNoError -Results "Successfully Executed"
}
else
{
    Write-Output "Winget is not installed"
    Update-OutputOnExit -ExitCode $ExitWithError -Results "Winget is not installed"
}
