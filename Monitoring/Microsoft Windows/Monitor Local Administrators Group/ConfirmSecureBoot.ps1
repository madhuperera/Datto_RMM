# Author : Madhu Perera
# Summary: Simple script to check if Secure Boot is enabled

# ------------------------------- START -------------------------------

# ______________________________________________________________

[bool] $ExitWithError = $true
[bool] $ExitWithNoError = $false

function Get-DeviceDetails
{
	
	$Date_String = Get-Date -Format "dddd dd/MM/yyyy HH:mm:ss"
	$ComputerName = $ENV:COMPUTERNAME
	
	$DeviceDetails = "Script running on the Computer: $ComputerName on $Date_String`n`n"
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

    if ($UDF_Value -and $Registry_Value)
    {
        New-ItemProperty -Path HKLM:\SOFTWARE\CentraStage\ -Name $UDF_Value -PropertyType String -Value $Registry_Value -Force | Out-Null
    }
        
    write-host '<-Start Result->' -ErrorAction SilentlyContinue
    write-host "STATUS=$Results" -ErrorAction SilentlyContinue
    write-host '<-End Result->' -ErrorAction SilentlyContinue
    exit $ExitCode
}


try
{
    if (Confirm-SecureBootUEFI)
    {
        Update-OutputOnExit -ExitCode $ExitWithNoError -Results "Secure Boot is enabled on the Device."
    }
    else
    {
        Update-OutputOnExit -ExitCode $ExitWithError -Results "Secure Boot is NOT enabled on the Device."
    } 
}
catch
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "Command was not successful on the device."
}

