$S_RequiredAcLOutThreshold = 8

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

net accounts /lockoutthreshold:$S_RequiredAcLOutThreshold  
$CLine = net accounts | Where-Object {$_ -like "Lockout threshold:*"}
$CurrentAcLOutThreshold = ($CLine -split " ")[-1]

if ($CurrentAcLOutThreshold -ne $S_RequiredAcLOutThreshold)
{
	Update-OutputOnExit -ExitCode $ExitWithError -Results "We tried updating the Settings to $S_RequiredAcLOutThreshold`nBut we could not verify it!"
}
else
{
	Update-OutputOnExit -ExitCode $ExitWithNoError -Results "Compliant: `n$CLine`nRequired Value is $S_RequiredAcLOutThreshold"
}
