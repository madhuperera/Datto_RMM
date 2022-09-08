# Please make sure the Get-WindowsAutopilotInfo.ps1 file is added to the Datto Component as File

[String] $S_HashDestinationFolder = $ENV:DRMM_S_HashDestinationFolder
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

try
{
    $ComputerInfo = Get-ComputerInfo
    [String] $HashFileName = $ComputerInfo.CsName + "_" + $ComputerInfo.BiosSerialNumber + "_" + "Hash.csv"
    [String] $HashFileFullPath = $S_HashDestinationFolder + "\$HashFileName"
    if (!(Test-Path -Path $S_HashDestinationFolder))
    {
        New-Item -Path $S_HashDestinationFolder -ItemType Directory -Force
    }

    .\Get-WindowsAutoPilotInfo.ps1 -OutputFile $HashFileFullPath
    Start-Sleep -Seconds 30
    Get-Content -Path $HashFileFullPath
    Update-OutputOnExit -ExitCode $ExitWithNoError -Results "Script executed with no Errors. Please check $HashFileFullPath"
}
catch
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "We ran into issues running the Script"
}


