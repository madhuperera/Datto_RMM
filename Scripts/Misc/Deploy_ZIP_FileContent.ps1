# Author : Madhu Perera
# Summary: Deploying a File to a PC

# ______________________________________________________________

[bool] $ExitWithError = $true
[bool] $ExitWithNoError = $false

# ------------ DATTO VARIABLES ----------------
[String] $DestFolderPath = $ENV:DRMM_DestFolderPath
[String] $ZIP_FileName = $ENV:DRMM_ZIP_FileName
[String] $SubfolderToCopy = $ENV:DRMM_SubfolderToCopy
[String] $DestinationToCopy = $ENV:DRMM_DestinationToCopy

function Get-DeviceDetails
{
	
	$Date_String = Get-Date -Format "dddd dd/MM/yyyy HH:mm:ss"
	$ComputerName = $ENV:COMPUTERNAME
	
	$DeviceDetails = "`nScript running on the Computer: $ComputerName on $Date_String`n`n"
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
try
{
    Expand-Archive -Path ".\$Zip_FileName" -DestinationPath $DestFolderPath -Force

    # Waiting for possible delays by AV Scans
    Start-Sleep -Seconds 60

    If (Test-Path -Path $DestFolderPath -PathType Container)
    {
        Copy-Item -Path "$SubfolderToCopy\*" -Destination $DestinationToCopy -Force
        Update-OutputOnExit -ExitCode $ExitWithNoError -Results "Looks like it all worked!"
    }
    else
    {
        Update-OutputOnExit -ExitCode $ExitWithError -Results "Something went Wrong. Cannot find the folder."
    }
}
catch
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "Script Error!"
}
