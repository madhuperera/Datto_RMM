$S_LogName = $ENV:DRMM_S_LogName # "Microsoft-Windows-DNS-Client/Operational"

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

if ($S_LogName)
{
    $Log = Get-WinEvent -ListLog $S_LogName
    if ($Log.IsEnabled)
    {
        Update-OutputOnExit -ExitCode $ExitWithNoError -Results "SUCCESS: $S_LogName is already Enabled"
    }
    else
    {
        try
        {
            $Log.IsEnabled = $true
            $Log.SaveChanges()
        }
        catch
        {
            Update-OutputOnExit -ExitCode $ExitWithError -Results "Oh No! We ran into a problem trying to enable $S_LogName !"
        }
        Update-OutputOnExit -ExitCode $ExitWithNoError -Results "SUCCESS: We have enabled $S_LogName"
    }
}
else
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "Error. You forgot enter the Log Name"
}


