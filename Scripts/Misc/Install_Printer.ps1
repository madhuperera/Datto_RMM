# Author : Madhu Perera
# Summary: Deploying a Printer to a PC

# ______________________________________________________________

[bool] $ExitWithError = $true
[bool] $ExitWithNoError = $false

# ------------ DATTO VARIABLES ----------------
[String] $PrinterPortIPAddress = $ENV:DRMM_PrinterPortIPAddress
[String] $PrinterPortName = $ENV:DRMM_PrinterPortName
[String] $PrinterName = $ENV:DRMM_PrinterName
[String] $PrinterDriverModelName = $ENV:DRMM_PrinterDriverModelName
[String] $PrinterDriverZipFileName = $ENV:DRMM_PrinterDriverZipFileName
[String] $PrinterDriverModelFileName = $ENV:DRMM_PrinterDriverModelFileName

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
    param
    (
        [String] $PrinterFPortName
    )
    

    if (Get-PrinterPort | Where-Object {$_.Name -like "*$($PrinterFPortName)*"})
    {
        return $true
    }
    else
    {
        return $false
    }
}

function Test-PrinterExists
{
    # Name of the Printer
    param
    (
        [String] $PrinterFName
    )    

    if (Get-Printer -Name $PrinterFName)
    {
        return $true
    }
    else
    {
        return $false
    }
}

# Installing the Driver
Expand-Archive -Path "$PSScriptRoot\$PrinterDriverZipFileName" -DestinationPath "$PSScriptRoot\" -Force
If (Test-Path -Path "$PSScriptRoot\Driver")
{
    try
    {
        cscript "C:\Windows\System32\Printing_Admin_Scripts\en-US\prndrvr.vbs" -a -m $PrinterDriverModelName -i "$PSScriptRoot\Driver\$PrinterDriverModelFileName" -h "$PSScriptRoot\Driver" -v 3
    }
    catch
    {
        Update-OutputOnExit -ExitCode $ExitWithError -Results "Error adding $PrinterDriverModelName to Windows"
    }
    
}
else
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "Error Extracting Printer Drivers"
}


# Installing the Printer Port
if (!(Test-PrinterPortExists -PrinterPortName $PrinterPortName))
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
    write-host "$PrinterPortName aleady exists in the system!"
}

# Installing the Printer
if (!(Test-PrinterExists -PrinterName $PrinterName))
{
    try
    {
        Add-Printer -Name $PrinterName -PortName $PrinterPortName -DriverName $PrinterDriverModelName
    }
    catch
    {
        Update-OutputOnExit -ExitCode $ExitWithError -Results "Error adding $PrinterName"
    }
}
else
{
    write-host "$PrinterName aleady exists in the system!"
}

Update-OutputOnExit -ExitCode $ExitWithNoError -Results "$PrinterName has successfully been added!"