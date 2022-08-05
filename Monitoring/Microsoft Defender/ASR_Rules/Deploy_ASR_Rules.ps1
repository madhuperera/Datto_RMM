[String] $S_Prevalence_Mode = $ENV:DRMM_S_Prevalence_Mode # Block executable files from running unless they meet a prevalence, age, or trusted list criteria
[String] $S_OfficeChild_Mode = $ENV:DRMM_S_OfficeChild_Mode # Block Office communication applications from creating child processes
[String] $S_OfficeExec_Mode = $ENV:DRMM_S_OfficeExec_Mode # Block Office applications from creating executable content
[String] $S_ObfuscatedScripts_Mode = $ENV:DRMM_S_ObfuscatedScripts_Mode # Block execution of potentially obfuscated scripts
[String] $S_OfficeInject_Mode = $ENV:DRMM_S_OfficeInject_Mode # Block Office applications from injecting code into other processes
[String] $S_AdobeReader_Mode = $ENV:DRMM_S_AdobeReader_Mode # Block Adobe Reader from creating child processes
[String] $S_OfficeMacroAPI_Mode = $ENV:DRMM_S_OfficeMacroAPI_Mode # Block Win32 API calls from Office macro
[String] $S_LSASS_Mode = $ENV:DRMM_S_LSASS_Mode # Block credential stealing from the Windows local security authority subsystem (lsass.exe)
[String] $S_UntrustedUSB_Mode = $ENV:DRMM_S_UntrustedUSB_Mode # Block untrusted and unsigned processes that run from USB
[String] $S_EmailExec_Mode = $ENV:DRMM_S_EmailExec_Mode # Block executable content from email client and webmail
[String] $S_RansomwareProtection_Mode = $ENV:DRMM_S_RansomwareProtection_Mode # Use advanced protection against ransomware
[String] $S_PSExec_Mode = $ENV:DRMM_S_PSExec_Mode # Block process creations originating from PSExec and WMI commands
[String] $S_JSVBScrriptExec_Mode = $ENV:DRMM_S_JSVBScrriptExec_Mode # Block JavaScript or VBScript from launching downloaded executable content
[String] $S_OfficeChildProc_Mode = $ENV:DRMM_S_OfficeChildProc_Mode # Block all Office applications from creating child processes
[String] $S_WMIEvent_Mode = $ENV:DRMM_S_WMIEvent_Mode # Block persistence through WMI event subscription

[String] $S_ASR_NewExclusions = $ENV:DRMM_S_ASR_NewExclusions # Please provide a list of exclusions separated by comma in this format: "C:\Program Files (x86)\CentraStage\CagService.exe","C:\Program Files (x86)\CentraStage\Gui.exe"

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




# ------------------------------------------------------------------------

try
{
    # Block executable files from running unless they meet a prevalence, age, or trusted list criteria
    Add-MpPreference -AttackSurfaceReductionRules_Ids 01443614-cd74-433a-b99e-2ecdc07bfc25 -AttackSurfaceReductionRules_Actions $S_Prevalence_Mode -ErrorAction Stop

    # Block Office communication applications from creating child processes
    Add-MpPreference -AttackSurfaceReductionRules_Ids 26190899-1602-49e8-8b27-eb1d0a1ce869 -AttackSurfaceReductionRules_Actions $S_OfficeChild_Mode -ErrorAction Stop

    # Block Office applications from creating executable content
    Add-MpPreference -AttackSurfaceReductionRules_Ids 3b576869-a4ec-4529-8536-b80a7769e899 -AttackSurfaceReductionRules_Actions $S_OfficeExec_Mode -ErrorAction Stop

    # Block execution of potentially obfuscated scripts
    Add-MpPreference -AttackSurfaceReductionRules_Ids 5beb7efe-fd9a-4556-801d-275e5ffc04cc -AttackSurfaceReductionRules_Actions $S_ObfuscatedScripts_Mode -ErrorAction Stop

    # Block Office applications from injecting code into other processes
    Add-MpPreference -AttackSurfaceReductionRules_Ids 75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84 -AttackSurfaceReductionRules_Actions $S_OfficeInject_Mode -ErrorAction Stop

    # Block Adobe Reader from creating child processes
    Add-MpPreference -AttackSurfaceReductionRules_Ids 7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c -AttackSurfaceReductionRules_Actions $S_AdobeReader_Mode -ErrorAction Stop

    # Block Win32 API calls from Office macro
    Add-MpPreference -AttackSurfaceReductionRules_Ids 92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b -AttackSurfaceReductionRules_Actions $S_OfficeMacroAPI_Mode -ErrorAction Stop

    # Block credential stealing from the Windows local security authority subsystem (lsass.exe)
    Add-MpPreference -AttackSurfaceReductionRules_Ids 9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2 -AttackSurfaceReductionRules_Actions $S_LSASS_Mode -ErrorAction Stop

    # Block untrusted and unsigned processes that run from USB
    Add-MpPreference -AttackSurfaceReductionRules_Ids b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4 -AttackSurfaceReductionRules_Actions $S_UntrustedUSB_Mode -ErrorAction Stop

    # Block executable content from email client and webmail
    Add-MpPreference -AttackSurfaceReductionRules_Ids be9ba2d9-53ea-4cdc-84e5-9b1eeee46550 -AttackSurfaceReductionRules_Actions $S_EmailExec_Mode -ErrorAction Stop

    # Use advanced protection against ransomware
    Add-MpPreference -AttackSurfaceReductionRules_Ids c1db55ab-c21a-4637-bb3f-a12568109d35 -AttackSurfaceReductionRules_Actions $S_RansomwareProtection_Mode -ErrorAction Stop

    # Block process creations originating from PSExec and WMI commands
    Add-MpPreference -AttackSurfaceReductionRules_Ids d1e49aac-8f56-4280-b9ba-993a6d77406c -AttackSurfaceReductionRules_Actions $S_PSExec_Mode -ErrorAction Stop

    # Block JavaScript or VBScript from launching downloaded executable content
    Add-MpPreference -AttackSurfaceReductionRules_Ids d3e037e1-3eb8-44c8-a917-57927947596d -AttackSurfaceReductionRules_Actions $S_JSVBScrriptExec_Mode -ErrorAction Stop

    # Block all Office applications from creating child processes
    Add-MpPreference -AttackSurfaceReductionRules_Ids d4f940ab-401b-4efc-aadc-ad5f3c50688a -AttackSurfaceReductionRules_Actions $S_OfficeChildProc_Mode -ErrorAction Stop

    # Block persistence through WMI event subscription
    Add-MpPreference -AttackSurfaceReductionRules_Ids e6db77e5-3df2-4cf1-b95a-636979351e5b -AttackSurfaceReductionRules_Actions $S_WMIEvent_Mode -ErrorAction Stop

    if ($S_ASR_NewExclusions)
    {
        $List_Of_ASR_Exclusions = $S_ASR_NewExclusions -split ","
        foreach ($Exclusion in $List_Of_ASR_Exclusions)
        {
            Add-MpPreference -AttackSurfaceReductionOnlyExclusions $Exclusion -ErrorAction Stop
            Write-Host "Added $($Exclusion) to ASR Exclusions."
        }
    }
}
catch
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "We ran into an error trying to run the command."
}

Update-OutputOnExit -ExitCode $ExitWithNoError -Results "We have successfull updated ASR Rules on this device."

