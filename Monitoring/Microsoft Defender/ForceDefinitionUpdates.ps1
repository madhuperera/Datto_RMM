# Author : Madhu Perera
# Summary: This will remove current definitions and update the Defender with the latest ones.

# ------------------------------- START -------------------------------


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

if (Test-Path -Path "C:\Program Files\Windows Defender\MpCmdRun.exe" -PathType Leaf)
{
    Write-Output "Removing Dyanmic Signatures.....`n"
    & "C:\Program Files\Windows Defender\MpCmdRun.exe" -removedefinitions -dynamicsignatures

    Write-Output "`nUpdating the Signatures.....`n"
    & "C:\Program Files\Windows Defender\MpCmdRun.exe" -signatureupdate

    Update-OutputOnExit -ExitCode $ExitWithNoError -Results "Definitions updated successfully"
}
else
{
    Write-Output "Defender Path not found`n"
    Update-OutputOnExit -ExitCode $ExitWithError -Results "Defender File Path is missing"
}