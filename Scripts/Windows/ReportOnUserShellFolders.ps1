$RegistryPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders\'
$ReportingShare = "\\localhost\C$\Temp\"
function Get-DeviceDetails
{
	
	$Date_String = Get-Date -Format "dddd dd/MM/yyyy HH:mm:ss"
	$ComputerName = $ENV:COMPUTERNAME
	
	$DeviceDetails = "Script running on the Computer: $ComputerName on $Date_String`n`n"
	return $DeviceDetails

}

Get-DeviceDetails

# Coming up with a unique name for the file
[string] $ExecutionTime = Get-Date -Format "yyyy_MM_dd_HH_MM_ss"
[string] $DeviceName = $ENV:COMPUTERNAME
[string] $UserAccount = $ENV:USERNAME
[string] $FileName = $UserAccount + "_" + $DeviceName + "_" + $ExecutionTime + ".txt"

Get-Item -Path $RegistryPath | Out-File -FilePath $($ReportingShare + $FileName) -Force