# Author : Madhu Perera
# Summary: Monitoring to see if the file you are looking for is located in the folder

# PLEASE CHANGE UDF VARIABLE
[String] $UDF_ToUpdate = "CHANGEME"  # Example: "custom28"

# ______________________________________________________________

[String] $Output = ""
[bool] $ExitWithError = $true
[bool] $ExitWithNoError = $false
[String] $FolderPath = $ENV:DRMM_FOLDER_PATH
[String] $SearchString = $ENV:DRMM_SEARCH_STRING

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

$AllItems = Get-ChildItem -Path $FolderPath -Recurse -Include $SearchString -ErrorAction SilentlyContinue
if ($AllItems)
{
    $AllItems
    Update-OutputOnExit -ExitCode $ExitWithError -Results "Files Found"
}
else
{
    Update-OutputOnExit -ExitCode $ExitWithNoError -Results "No Files Found"
}