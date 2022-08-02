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

$NewestLogEntry = Get-EventLog -LogName Application -Source wininit -Newest 1 -ErrorAction SilentlyContinue

if ($NewestLogEntry)
{
    Write-Host "Time Generated: $($NewestLogEntry.TimeGenerated)"
    Write-Host "Time Written: $($NewestLogEntry.TimeWritten)"
    Write-Host "Message: $($NewestLogEntry.Message)"

    Update-OutputOnExit -ExitCode $ExitWithNoError -Results "We successfully retrieved the latest entry."
}
else
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "Oops. Either we did not find any entry in the logs or it errored during the lookup!"
}