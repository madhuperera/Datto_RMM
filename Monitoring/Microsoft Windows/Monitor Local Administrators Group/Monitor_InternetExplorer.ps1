# Author : Madhu Perera
# Summary: Simple script to check if Internet Explorer is enabled

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

Get-DeviceDetails

try
{
    $IEStatus = Get-WindowsOptionalFeature -Online -FeatureName "Internet-Explorer*"
    if ($IEStatus)
    {
        if ($IEStatus.State -eq "Enabled")
        {
            Update-OutputOnExit -ExitCode $ExitWithError -Results "Oh No! IE is Installed and Enabled!"
        }
        elseif ($IEStatus.State -eq "Disabled")
        {
            Update-OutputOnExit -ExitCode $ExitWithNoError -Results "Not Bad! IE is Installed but Disabled!"
        }
        else
        {
            Update-OutputOnExit -ExitCode $ExitWithError -Results "$($IEStatus.State) : Not supported!"
        }
    }
    else
    {
        Update-OutputOnExit -ExitCode $ExitWithError -Results "Excellent! IE Is NOT installed."
    } 
}
catch
{
    Update-OutputOnExit -ExitCode $ExitWithNoError -Results "Command was not successful on the device."
}

