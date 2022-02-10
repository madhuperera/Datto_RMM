# Author : Madhu Perera
# Version : 1.0.0
# Summary: Monitoring to see if all Defender Services and features are enabled and running

# ------------------------------- START -------------------------------

[String] $UFDToUpdate = "Custom2"


$DefenderStatus = Get-MpComputerStatus


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
    

    #Write-Host $Output
    REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v $UFDToUpdate /t REG_SZ /d "Running" /f
    write-host '<-Start Result->'
 	write-host "STATUS=All Good $Output"
 	write-host '<-End Result->'
 	exit 0
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

    #Write-Host $Output

    REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v $UFDToUpdate /t REG_SZ /d "Error" /f

    write-host '<-Start Result->'
 	write-host "STATUS=Error $Output"
 	write-host '<-End Result->'
 	exit 1
}
