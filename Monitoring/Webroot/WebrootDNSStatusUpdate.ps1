# Author : Madhu Perera
# Summary: Monitoring to see if Webroot DNS is installed and running for sites with a Webroot Key enabled in Datto

# ------------------------------- START -------------------------------

# PLEASE CHANGE UDF VARIABLE
[String] $UDF_ToUpdate = "CHANGEME"  # Example: "custom29"

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

    if ($UDF_Value)
    {
        New-ItemProperty -Path HKLM:\SOFTWARE\CentraStage\ -Name $UDF_Value -PropertyType String -Value $Registry_Value -Force | Out-Null
    }
        
    write-host '<-Start Result->' -ErrorAction SilentlyContinue
    write-host "STATUS=$Results" -ErrorAction SilentlyContinue
    write-host '<-End Result->' -ErrorAction SilentlyContinue
    exit $ExitCode
}

function Get-ServiceStatus
{
    # Basic function to check the Service and return the status
    # If the service is not running, it will attempt to start the service once
    param
    (
        [String] $ServiceName
    )
    
    $ServiceStatus = (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue).Status
    
    switch ($ServiceStatus)
    {
        "Stopped"
        {
            Start-Service -Name $ServiceName -ErrorAction SilentlyContinue
            $ServiceStatus = (Get-Service -Name $ServiceName -ErrorAction SilentlyContinue).Status
        }
        Default
        {
            return $ServiceStatus
        }
    }

    return $ServiceStatus
}

Get-DeviceDetails

# Checking to see if DNS Proxy Server is running
[bool] $WebrootDNSProcess = $false
[String] $DNSProxyServiceStatus = Get-ServiceStatus -ServiceName "DNSProxyAgent"
if ($DNSProxyServiceStatus -eq "Running")
{
    if ((Get-Process DnsProxySvr -ErrorAction SilentlyContinue).Description -eq "Webroot DNS Protection Agent")
    {
        $WebrootDNSProcess = $true
    }
}



# Checking to see if Local DNS is pointing to Loopback Address
[bool] $WebrootDNSLocalHostEnabled = $false
function Test-LoopbackAddress
{
    [bool] $LoopbackAddressStatus = $false
    $AllAdapters = Get-DnsClientServerAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue
    foreach ($Adapter in $AllAdapters)
    {
        if ($Adapter.ServerAddresses -contains "127.0.0.1")
        {
            $LoopbackAddressStatus = $true
        }
    }

    return $LoopbackAddressStatus
}
$WebrootDNSLocalHostEnabled = Test-LoopbackAddress
if (!$WebrootDNSLocalHostEnabled)
{
    Write-Warning "No Loopback address found"
    if ($WebrootDNSProcess)
    {
        Write-Information "Attempting to restart DNS Proxy Agent Service"
        Restart-Service -Name "DNSProxyAgent"
        $WebrootDNSLocalHostEnabled = Test-LoopbackAddress
    }
}

# Checking if the Client is supposed to have Webroot
[bool] $WebrootManagedSite = $false
if ($ENV:usrWRSASerialSITE)
{
    $WebrootManagedSite = $true
}


if ($WebrootManagedSite)
{
    # Running Steps for Webroot Managed Sites
    if ($WebrootDNSLocalHostEnabled -and $WebrootDNSProcess)
    {
        $Output = "Webroot DNS is Fully Configured and Running."
        $UDFMessage = "Enabled and Running"
        Update-OutputOnExit -UDF_Value $UDF_ToUpdate -ExitCode $ExitWithNoError -Results $Output -Registry_Value $UDFMessage
    }
        elseif (!$WebrootDNSLocalHostEnabled -and $WebrootDNSProcess)
        {
            $Output = "Webroot DNS Process is running but not being used for DNS queries. No Loopsback DNS!"
            $UDFMessage = "Running"
            Update-OutputOnExit -UDF_Value $UDF_ToUpdate -ExitCode $ExitWithError -Results $Output -Registry_Value $UDFMessage
        }
            elseif ($WebrootDNSLocalHostEnabled -and !$WebrootDNSProcess)
            {
                $Output = "Webroot DNS Loopback is found but no process is running. Misconfiguration detected."
                $UDFMessage = "Enabled"
                Update-OutputOnExit -UDF_Value $UDF_ToUpdate -ExitCode $ExitWithError -Results $Output -Registry_Value $UDFMessage
            }
    else
    {
        $Output = "Webroot DNS is missing!"
        $UDFMessage = "Error"
        Update-OutputOnExit -UDF_Value $UDF_ToUpdate -ExitCode $ExitWithError -Results $Output -Registry_Value $UDFMessage
    }

}
else
{
    $Output = "Datto Site is not configured to be a Webroot Site"
    $UDFMessage = "Site Not Configured"
    Update-OutputOnExit -UDF_Value $UDF_ToUpdate -ExitCode $ExitWithNoError -Results $Output -Registry_Value $UDFMessage
}
