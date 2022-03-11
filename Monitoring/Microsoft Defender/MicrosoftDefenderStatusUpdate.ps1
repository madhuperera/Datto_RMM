# Author : Madhu Perera
# Summary: Monitoring to see if all Defender Services and features are enabled and running

# ------------------------------- START -------------------------------

[String] $UDF_ToUpdate = "Custom2"
[bool] $ExitWithError = $true
[bool] $ExitWithNoError = $false


$DefenderStatus = Get-MpComputerStatus

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
        New-ItemProperty -Path HKLM:\SOFTWARE\CentraStage\ -Name $UDF_Value -PropertyType String -Value $Registry_Value -Force
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

$DefenderFirewallServiceStatus = Get-ServiceStatus -ServiceName "mpssvc"
$DefenderATPServiceStatus = Get-ServiceStatus -ServiceName "Sense"
$DefenderNetInspectionServiceStatus = Get-ServiceStatus -ServiceName "WdNisSvc"
$DefenderAVServiceStatus = Get-ServiceStatus -ServiceName "WinDefend"


$AMServiceEnabled = $DefenderStatus.AMServiceEnabled
$AntispywareEnabled = $DefenderStatus.AntispywareEnabled
$AntivirusEnabled = $DefenderStatus.AntivirusEnabled
$BehaviorMonitorEnabled = $DefenderStatus.BehaviorMonitorEnabled
$IoavProtectionEnabled = $DefenderStatus.IoavProtectionEnabled
$IsTamperProtected = $DefenderStatus.IsTamperProtected
$NISEnabled = $DefenderStatus.NISEnabled
$OnAccessProtectionEnabled = $DefenderStatus.OnAccessProtectionEnabled
$RealTimeProtectionEnabled = $DefenderStatus.RealTimeProtectionEnabled

[String] $Output = ""

$AllProtectionsOn = $false
if ($AMServiceEnabled -and $AntispywareEnabled -and $AntivirusEnabled `
    -and $BehaviorMonitorEnabled -and $IoavProtectionEnabled -and $IsTamperProtected `
    -and $NISEnabled -and $OnAccessProtectionEnabled -and $RealTimeProtectionEnabled `
    -and ($DefenderFirewallServiceStatus -eq "Running") `
    -and ($DefenderATPServiceStatus -eq "Running") `
    -and ($DefenderNetInspectionServiceStatus -eq "Running") `
    -and ($DefenderAVServiceStatus -eq "Running"))
{
    $AllProtectionsOn = $true
}


if ($AllProtectionsOn)
{
    $Output = "All Defender Services are running." + "----" + "$DefenderFirewallServiceStatus | Windows Defender Firewall" + " --- " + "$DefenderATPServiceStatus | Windows Defender Advanced Threat Protection Service" + `
    " --- " + "$DefenderNetInspectionServiceStatus | Microsoft Defender Antivirus Network Inspection Service" + `
    " --- " + "$DefenderAVServiceStatus | Microsoft Defender Antivirus Service" + `
    " --- " + "$AMServiceEnabled | Activation of the antimalware service" + `
    " --- " + "$AntispywareEnabled | Antispyware protection activation status" + `
    " --- " + "$AntivirusEnabled | Antivirus protection activation status" + `
    " --- " + "$BehaviorMonitorEnabled | Antivirus behavior monitor status" + `
    " --- " + "$IoavProtectionEnabled | Office Antivirus protection status" + `
    " --- " + "$IsTamperProtected | Antivirus Tamper Protection Status" + `
    " --- " + "$NISEnabled | Antivirus Network Protection (Web Filtering)" + `
    " --- " + "$OnAccessProtectionEnabled | Antivirus Access Protection Status" + `
    " --- " + "$RealTimeProtectionEnabled | Antivirus Realtime Scanning Status"
    

    Update-OutputOnExit -UDF_Value $UDF_ToUpdate -ExitCode $ExitWithNoError -Results $Output -Registry_Value "Running"
}
else
{
    $Output = "Some or all Defender Services are NOT running!" + "----" + "$DefenderFirewallServiceStatus | Windows Defender Firewall" + " --- " + "$DefenderATPServiceStatus | Windows Defender Advanced Threat Protection Service" + `
    " --- " + "$DefenderNetInspectionServiceStatus | Microsoft Defender Antivirus Network Inspection Service" + `
    " --- " + "$DefenderAVServiceStatus | Microsoft Defender Antivirus Service" + `
    " --- " + "$AMServiceEnabled | Activation of the antimalware service" + `
    " --- " + "$AntispywareEnabled | Antispyware protection activation status" + `
    " --- " + "$AntivirusEnabled | Antivirus protection activation status" + `
    " --- " + "$BehaviorMonitorEnabled | Antivirus behavior monitor status" + `
    " --- " + "$IoavProtectionEnabled | Office Antivirus protection status" + `
    " --- " + "$IsTamperProtected | Antivirus Tamper Protection Status" + `
    " --- " + "$NISEnabled | Antivirus Network Protection (Web Filtering)" + `
    " --- " + "$OnAccessProtectionEnabled | Antivirus Access Protection Status" + `
    " --- " + "$RealTimeProtectionEnabled | Antivirus Realtime Scanning Status"

    Update-OutputOnExit -UDF_Value $UDF_ToUpdate -ExitCode $ExitWithError -Results $Output -Registry_Value "Error"
}
