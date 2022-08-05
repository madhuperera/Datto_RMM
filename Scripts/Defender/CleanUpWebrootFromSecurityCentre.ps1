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

try
{
    $AllAVProducts = Get-WmiObject -Namespace root\SecurityCenter2 -Class AntiVirusProduct
    foreach ($Product in $AllAVProducts)
    {
        if ($Product.displayName -like "*webroot*")
        {
            Write-Host "Deleting Entry for $($Product.displayName)"
            $Product.Delete()
        }
    }
}
catch
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "Oops. We ran into an issue checking SecurityCenter Settings."
}

Update-OutputOnExit -ExitCode $ExitWithNoError -Results "We have successfully removed Webroot Entries from Security Centre"