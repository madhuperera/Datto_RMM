# Author : Madhu Perera
# Summary: Getting a list of users in Local Administrator Group and removing them from the Group

# ------------------------------- START -------------------------------

# ______________________________________________________________

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



[String] $Output = ""

if (Test-Path -Path "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\")
{
    # Getting a List of Local Administrators and removing unnecessary lines
    [System.Collections.ArrayList] $LocalAdministrators = net localgroup administrators | Select-Object -skip 6
    $LocalAdministrators.Remove($LocalAdministrators[$LocalAdministrators.Count - 1])
    $LocalAdministrators.Remove($LocalAdministrators[$LocalAdministrators.Count - 1])

    $BuiltInAdminName = (Get-LocalUser | Where-Object {$_.Description -like "Built-in account for administering*"}).Name
    $BuiltInAdminEnabled = (Get-LocalUser | Where-Object {$_.Description -like "Built-in account for administering*"}).Enabled

    If (!$BuiltInAdminEnabled)
    {
        $LocalAdministrators.Remove($BuiltInAdminName)
    }

    if ($LocalAdministrators.Count -eq 0)
    {
        Update-OutputOnExit -ExitCode $ExitWithNoError -Results "Excellent! We found no Local Admin Accounts to remove."
    }
    else
    {
        
        foreach ($Account in $LocalAdministrators)
        {
            Write-Output "Removing $Account from Administrator Group...`n"
            net localgroup administrators $Account /delete | Out-Null
        }
        Update-OutputOnExit -ExitCode $ExitWithNoError -Results "Warning! We have found and deleted accounts from Local Administrator Group."
    }
}
else
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "Computer is not Azure AD joined"
}
