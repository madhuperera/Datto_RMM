param
(
    [String] $ServiceName = "CloudRadial",
    [String] $UDF_ToUpdate = "custom15" # CHANGE ME
)
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

function Test-ServiceExists
{
    param
    (
        [String] $F_ServiceName
    )

    try
    {
        $WinService = Get-Service -Name $F_ServiceName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        if ($WinService)
        {
            return $true
        }
        else
        {
            return $false
        }
    }
    catch
    {
        return $false
    }
}

if (Test-ServiceExists -F_ServiceName $ServiceName)
{
    Update-OutputOnExit -ExitCode $ExitWithNoError -Results "SUCCESS: $ServiceName is detected." -UDF_Value $UDF_ToUpdate -Registry_Value "Running"
}
else
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "FAILURE: $ServiceName is NOT detected."
}
