# PLEASE CHANGE UDF VARIABLE
[String] $UDF_ToUpdate = "custom7"  # Example: "custom2"
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

function Main
{
    try
    {
        $CurrentDefStatus = Get-MpComputerStatus
        $DefFullScanStatus = "Never"
        if ($CurrentDefStatus.FullScanEndTime)
        {
            $DefFullScanStatus = $CurrentDefStatus.FullScanAge
            Update-OutputOnExit -UDF_Value $UDF_ToUpdate -ExitCode $ExitWithNoError -Results "Defender has run a full scan" -Registry_Value $DefFullScanStatus
        }

        Update-OutputOnExit -UDF_Value $UDF_ToUpdate -ExitCode $ExitWithError -Results "Defender has never run a full scan" -Registry_Value $DefFullScanStatus
    }
    catch
    {
        Update-OutputOnExit -UDF_Value $UDF_ToUpdate -ExitCode $ExitWithError -Results "Issue running script" -Registry_Value "Error"
    }
}

Main