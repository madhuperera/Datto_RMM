# Author : Madhu Perera
# Summary: This script can be used to configure Microsoft Defender Settings

# PLEASE CHANGE UDF VARIABLE
[String] $UDF_ToUpdate = "CHANGEME"  # Example: "custom28"

# ______________________________________________________________

[String] $Output = ""
[bool] $ExitWithError = $true
[bool] $ExitWithNoError = $false

# All Defender Variables to configure
<#
AMServiceEnabled
AntispywareEnabled
AntivirusEnabled
BehaviorMonitorEnabled
IoavProtectionEnabled
NISEnabled
OnAccessProtectionEnabled
RealTimeProtectionEnabled

CheckForSignaturesBeforeRunningScan
CloudBlockLevel
DisableArchiveScanning
DisableAutoExclusions
DisableBehaviorMonitoring
DisableBlockAtFirstSeen
DisableCatchupFullScan
DisableCatchupQuickScan
DisableCpuThrottleOnIdleScans
DisableEmailScanning
DisableInboundConnectionFiltering
DisableIOAVProtection
DisableRealtimeMonitoring
DisableRemovableDriveScanning
EnableLowCpuPriority
EnableNetworkProtection
PUAProtection
ScanAvgCPULoadFactor

#>


[bool] $CheckForSignaturesBeforeRunningScan = $ENV:DRMM_CheckForSignaturesBeforeRunningScan
[String] $CloudBlockLevel = $ENV:DRMM_CloudBlockLevel
[bool] $DisableArchiveScanning = $ENV:DRMM_DisableArchiveScanning
[bool] $DisableAutoExclusions = $ENV:DRMM_DisableAutoExclusions
[bool] $DisableBehaviorMonitoring = $ENV:DRMM_DisableBehaviorMonitoring
[bool] $DisableBlockAtFirstSeen = $ENV:DRMM_DisableBlockAtFirstSeen
[bool] $DisableCatchupFullScan = $ENV:DRMM_DisableCatchupFullScan
[bool] $DisableCatchupQuickScan = $ENV:DRMM_DisableCatchupQuickScan
[bool] $DisableEmailScanning = $ENV:DRMM_DisableEmailScanning
[bool] $DisableInboundConnectionFiltering = $ENV:DRMM_DisableInboundConnectionFiltering
[bool] $DisableIOAVProtection = $ENV:DRMM_DisableIOAVProtection
[bool] $DisableRealtimeMonitoring = $ENV:DRMM_DisableRealtimeMonitoring
[bool] $DisableRemovableDriveScanning = $ENV:DRMM_DisableRemovableDriveScanning
[bool] $DisableScanningMappedNetworkDrivesForFullScan = $ENV:DRMM_DisableScanningMappedNetworkDrivesForFullScan
[bool] $DisableScanningNetworkFiles = $ENV:DRMM_DisableScanningNetworkFiles
[bool] $DisableScriptScanning = $ENV:DRMM_DisableScriptScanning
[bool] $EnableLowCpuPriority = $ENV:DRMM_EnableLowCpuPriority
[bool] $EnableNetworkProtection = $ENV:DRMM_EnableNetworkProtection
[String] $EngineUpdatesChannel = $ENV:EngineUpdatesChannel
[String] $HighThreatDefaultAction = $ENV:DRMM_HighThreatDefaultAction
[bool] $DisableScriptScanning = $ENV:DRMM_DisableScriptScanning
[bool] $DisableScriptScanning = $ENV:DRMM_DisableScriptScanning
[bool] $DisableScriptScanning = $ENV:DRMM_DisableScriptScanning
[bool] $DisableScriptScanning = $ENV:DRMM_DisableScriptScanning



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

try
{
    Set-MpPreference -CheckForSignaturesBeforeRunningScan $CheckForSignaturesBeforeRunningScan `
        -CloudBlockLevel $CloudBlockLevel `
        -DisableArchiveScanning $DisableArchiveScanning `
        -DisableAutoExclusions $DisableAutoExclusions `
        -DisableBehaviorMonitoring $DisableBehaviorMonitoring `
        -DisableBlockAtFirstSeen $DisableBlockAtFirstSeen `
        -DisableCatchupFullScan $DisableCatchupFullScan `
        -DisableCatchupQuickScan $DisableCatchupQuickScan `
        -DisableEmailScanning $DisableEmailScanning `
        -DisableInboundConnectionFiltering $DisableInboundConnectionFiltering `
        -DisableIOAVProtection $DisableIOAVProtection `
        -DisableRealtimeMonitoring $DisableRealtimeMonitoring `
        -DisableRemovableDriveScanning $DisableRemovableDriveScanning `
        -DisableScanningMappedNetworkDrivesForFullScan $DisableScanningMappedNetworkDrivesForFullScan `
        -DisableScanningNetworkFiles $DisableScanningNetworkFiles `
        -DisableScriptScanning $DisableScriptScanning `
        -EnableLowCpuPriority $EnableLowCpuPriority `
        -EnableNetworkProtection $EnableNetworkProtection `
        -EngineUpdatesChannel $EngineUpdatesChannel `
        -HighThreatDefaultAction $HighThreatDefaultAction `
        -ErrorAction Stop -Force
}
catch
{
    {1:<#Do this if a terminating exception happens#>}
}