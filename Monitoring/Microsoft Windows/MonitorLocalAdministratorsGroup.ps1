# Author : Madhu Perera
# Summary: Monitoring to see if there are user accounts in Local Administrators group

# PLEASE CHANGE UDF VARIABLE
[String] $UDF_ToUpdate = "CHANGEME"  # Example: "custom28"

# ______________________________________________________________

[String] $Output = ""
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

    if ($UDF_Value)
    {
        New-ItemProperty -Path HKLM:\SOFTWARE\CentraStage\ -Name $UDF_Value -PropertyType String -Value $Registry_Value -Force | Out-Null
    }
        
    write-host '<-Start Result->' -ErrorAction SilentlyContinue
    write-host "STATUS=$Results" -ErrorAction SilentlyContinue
    write-host '<-End Result->' -ErrorAction SilentlyContinue
    exit $ExitCode
}

# Getting a List of Local Administrators and removing unnecessary lines
[System.Collections.ArrayList] $LocalAdministrators = net localgroup administrators | Select-Object -skip 6
$LocalAdministrators.Remove($LocalAdministrators[$LocalAdministrators.Count - 1])
$LocalAdministrators.Remove($LocalAdministrators[$LocalAdministrators.Count - 1])

$BuiltInAdminName = (Get-LocalUser | Where-Object {$_.Description -like "Built-in account for administering*"}).Name
$BuiltInAdminEnabled = (Get-LocalUser | Where-Object {$_.Description -like "Built-in account for administering*"}).Enabled

$Output = Get-DeviceDetails

If (!$BuiltInAdminEnabled)
{
    $LocalAdministrators.Remove($BuiltInAdminName)
}

if ($LocalAdministrators.Count -eq 0)
{
    $Output += "Excellent! No Local Administrator Accounts Found."
    Update-OutputOnExit -UDF_Value $UDF_ToUpdate -ExitCode $ExitWithNoError -Results $Output -Registry_Value "Great | No Admins"
}
else
{
    $Output += "WARNING! These Accounts found: "
    foreach ($Account in $LocalAdministrators)
    {
        $Output = $Output, $Account -join " | "
    }

    Update-OutputOnExit -UDF_Value $UDF_ToUpdate -ExitCode $ExitWithError -Results $Output -Registry_Value "Warning | Admins Found"
}