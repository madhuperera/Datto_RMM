[String] $DesiredDebugInfoType = 3

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

[bool] $ExitWithError = $true
[bool] $ExitWithNoError = $false

function Get-DebugInfoType
{
    [String] $DebugInfoType = ""
    try
    {
        $DebugInfoType = ((wmic RECOVEROS get DebugInfoType | Select-Object -Skip 2) -split " ")[0]
        return $DebugInfoType
    }
    catch
    {
        return "Error"
    }
}

# Getting a the current configuration
[String] $CurrentDebugInfoType = Get-DebugInfoType

switch ($CurrentDebugInfoType)
{
    "Error" 
        {
            Update-OutputOnExit -ExitCode $ExitWithError -Results "Something went wrong trying to check the Debug Info Type!"
        }
    $DesiredDebugInfoType
        {
            Update-OutputOnExit -ExitCode $ExitWithNoError -Results "No Reboot Needed. The System was already configured with the correct Debug Info Type"
        }
    Default
        {
            wmic RECOVEROS set DebugInfoType = 3
            if (Get-DebugInfoType -eq $DesiredDebugInfoType)
            {
                Update-OutputOnExit -ExitCode $ExitWithNoError -Results "We have successfully updated Debug Info Type to $($DesiredDebugInfoType). Please Reboot your Device."
            }
            else
            {
                Update-OutputOnExit -ExitCode $ExitWithError -Results "We tried changing the value but something went wrong!"
            }
        }
}

