[String] $S_User_Account = $ENV:DRMM_S_User_Account
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

if ($S_User_Account)
{
    try
    {
        Add-LocalGroupMember -Group Administrators -Member $S_User_Account -ErrorAction SilentlyContinue
    }
    catch
    {
        Update-OutputOnExit -ExitCode $ExitWithError -Results "We tried but we ran into a problem"
    }
}
else
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "User Account Field Was Emtpy!"
}

try
{
    $LocalAdministrators = net localgroup Administrators
    if ($LocalAdministrators -like "*$S_User_Account*")
    {
        Update-OutputOnExit -ExitCode $ExitWithNoError -Results "We have successfully added and verified the user account, $S_User_Account to the Group"
    }
    else
    {
        Update-OutputOnExit -ExitCode $ExitWithNoError -Results "We added the user ($S_User_Account) to the Group but could not verify"
    }
}
catch
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "We ran into an issue trying to verify"
}
