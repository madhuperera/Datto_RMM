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

[String] $DiskReport = ""
$PrimaryDisk = Get-Disk -Number 0 -ErrorAction SilentlyContinue

if ($PrimaryDisk)
{
    if ($PrimaryDisk.Size)
    {
        [int] $Capacity = $PrimaryDisk.Size / 1000000000
    }
    
    $DiskReport = "MODEL: $($PrimaryDisk.Model) | S_No: $($PrimaryDisk.SerialNumber) | Size: $($Capacity) GB"
    Update-OutputOnExit -ExitCode $ExitWithNoError -Results "SUCCESS: Obtained Disk Information" -UDF_Value "Custom27" -Registry_Value $DiskReport
}
else
{
    $DiskReport = "No Disk"
    Update-OutputOnExit -ExitCode $ExitWithError -Results "FAILURE: No Disk Information" -UDF_Value "Custom27" -Registry_Value $DiskReport
}

