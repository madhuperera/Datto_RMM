# Author : Madhu Perera
# Summary: Deploying a Printer to a PC

# ______________________________________________________________

[bool] $ExitWithError = $true
[bool] $ExitWithNoError = $false

# ------------ DATTO VARIABLES ----------------
[String] $PrinterPortIPAddress = $ENV:DRMM_PrinterPortIPAddress
[String] $PrinterPortName = $ENV:DRMM_PrinterPortName
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

function Test-PrinterPortExists
{
    # IP Address of the Printer
    [Parameter(Mandatory)]
    [String] $PrinterPortName

    if (Get-PrinterPort | Where-Object {$_.Name -like "*$($PrinterPortName)*"})
    {
        return $true
    }
    else
    {
        retrun $false
    }
}

function Test-PrinterExists
{
    # IP Address of the Printer
    [Parameter(Mandatory)]
    [String] $PrinterName

    if (Get-Printer $($PrinterName))
    {
        return $true
    }
    else
    {
        retrun $false
    }
}

if (!(Test-PrinterPortExists))
{
    try
    {
        Add-PrinterPort -Name $PrinterPortName -PrinterHostAddress $PrinterPortIPAddress -PortNumber 9100
    }
    catch
    {
        Update-OutputOnExit -ExitCode $ExitWithError -Results "Error adding Printer Port"
    }
}
else
{
    write-host "$PrinterPortName is aleady exists in the system!"
}

if (!(Test-PrinterExists))
{
    try
    {
        Add-PrinterPort -Name $PrinterPortName -PrinterHostAddress $PrinterPortIPAddress -PortNumber 9100
    }
    catch
    {
        Update-OutputOnExit -ExitCode $ExitWithError -Results "Error adding Printer Port"
    }
}
else
{
    write-host "$PrinterName is aleady exists in the system!"
}
