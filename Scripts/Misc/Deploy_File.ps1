# Author : Madhu Perera
# Summary: Deploying a File to a PC

# ______________________________________________________________

[bool] $ExitWithError = $true
[bool] $ExitWithNoError = $false

# ------------ DATTO VARIABLES ----------------
[String] $DestFolderPath = $ENV:DRMM_DestFolderPath # Ex: "C:\Users\Public\Desktop"
[String] $FileName = $ENV:DRMM_FileName             # Ex: "Bing.url"

function Get-DeviceDetails
{
	
	$Date_String = Get-Date -Format "dddd dd/MM/yyyy HH:mm:ss"
	$ComputerName = $ENV:COMPUTERNAME
	
	$DeviceDetails = "`nScript running on the Computer: $ComputerName on $Date_String`n`n"
	return $DeviceDetails

}

function Update-OutputOnExit
{
    param
    (
        [String] $UDF_Value,
        [bool] $ExitCode,
        [String] $Results,
        [String] $Registry_Value
    )

    if ($UDF_Value)
    {
        New-ItemProperty -Path HKLM:\SOFTWARE\CentraStage\ -Name $UDF_Value -PropertyType String -Value $Registry_Value -Force | Out-Null
    }
        
    write-host '<-Start Result->' -ErrorAction SilentlyContinue
    write-host "STATUS=$Results" -ErrorAction SilentlyContinue
    write-host '<-End Result->' -ErrorAction SilentlyContinue
    exit $ExitCode
}

Get-DeviceDetails
try
{
    Copy-Item -Path ".\$FileName" -Destination $DestFolderPath -Force -ErrorAction Stop
}
catch
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "Script Error!"
}
Update-OutputOnExit -ExitCode $ExitWithNoError -Results "$FileName copies to $DestFolderPath successfully!"
