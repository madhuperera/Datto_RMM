# Author : Madhu Perera
# Summary: Simple script to check a list of Domain users

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

Get-DeviceDetails

$OSINfomration = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction SilentlyContinue
if ($OSINfomration.ProductType -ne 2)
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "$ComputerName is not a Domain Controller."
}
else
{
    if (Get-Module -Name ActiveDirectory -ListAvailable -ErrorAction SilentlyContinue)
    {
        Import-Module ActiveDirectory
        $AllDomainUsers = Get-ADUser -Filter 'Enabled -ne $false' -Properties Name, DisplayName, LastLogonDate
        $AllDomainUsers | Sort-Object LastLogonDate -Descending | Format-Table DisplayName, LastLogonDate, Name -Wrap -AutoSize

        Update-OutputOnExit -ExitCode $ExitWithNoError -Results "Script completed successfully"
    }
    else
    {
        Update-OutputOnExit -ExitCode $ExitWithError -Results "Sorry, Active Directory PowerShell Module not installed."
    }
}