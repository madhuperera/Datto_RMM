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

# -------------------------------------------------------------------------------------------
$RuledIDs = Get-MpPreference | Select-Object -ExpandProperty AttackSurfaceReductionRules_Ids
$RuleActions = Get-MpPreference | Select-Object -ExpandProperty AttackSurfaceReductionRules_Actions
$ListOfExclusions = Get-MpPreference | Select-Object -ExpandProperty AttackSurfaceReductionOnlyExclusions

$TotalNumberOfRules = $RuledIDs.Count
$Counter = 0

function Get-RuleActionStatus
{
    param
    (
        $ActionValue
    )

    switch ($ActionValue)
    {
        0 {return "Disabled"}
        1 {return "BlockMode"}
        2 {return "AuditMode"}
        6 {return "Warn"}
        Default {return "Unknown Action"}
    }
    
}

function Main
{
    Write-Host "----------- BEGINING OF THE REPORT -----------`n`n"
    Write-Host "$TotalNumberOfRules Rules have been found on the system`n`n"
    Write-Host "----------- ASR Rule Status -----------`n"
    foreach ($Rule in $RuledIDs)
    {
        switch ($Rule)
        {
            "01443614-cd74-433a-b99e-2ecdc07bfc25" 
            {
                $RuleName = "Block executable files from running unless they meet a prevalence, age, or trusted list criteria"
                $RuleActionStatus = Get-RuleActionStatus -ActionValue $RuleActions[$Counter]
                Write-Host "$RuleActionStatus | $RuleName"
                $Counter += 1
            }
            "26190899-1602-49e8-8b27-eb1d0a1ce869" 
            {
                $RuleName = "Block Office communication applications from creating child processes"
                $RuleActionStatus = Get-RuleActionStatus -ActionValue $RuleActions[$Counter]
                Write-Host "$RuleActionStatus | $RuleName"
                $Counter += 1
            }
            "3b576869-a4ec-4529-8536-b80a7769e899" 
            {
                $RuleName = "Block Office applications from creating executable content"
                $RuleActionStatus = Get-RuleActionStatus -ActionValue $RuleActions[$Counter]
                Write-Host "$RuleActionStatus | $RuleName"
                $Counter += 1
            }
            "5beb7efe-fd9a-4556-801d-275e5ffc04cc" 
            {
                $RuleName = "Block execution of potentially obfuscated scripts"
                $RuleActionStatus = Get-RuleActionStatus -ActionValue $RuleActions[$Counter]
                Write-Host "$RuleActionStatus | $RuleName"
                $Counter += 1
            }
            "75668c1f-73b5-4cf0-bb93-3ecf5cb7cc84" 
            {
                $RuleName = "Block Office applications from injecting code into other processes"
                $RuleActionStatus = Get-RuleActionStatus -ActionValue $RuleActions[$Counter]
                Write-Host "$RuleActionStatus | $RuleName"
                $Counter += 1
            }
            "7674ba52-37eb-4a4f-a9a1-f0f9a1619a2c" 
            {
                $RuleName = "Block Adobe Reader from creating child processes"
                $RuleActionStatus = Get-RuleActionStatus -ActionValue $RuleActions[$Counter]
                Write-Host "$RuleActionStatus | $RuleName"
                $Counter += 1
            }
            "92e97fa1-2edf-4476-bdd6-9dd0b4dddc7b" 
            {
                $RuleName = "Block Win32 API calls from Office macro"
                $RuleActionStatus = Get-RuleActionStatus -ActionValue $RuleActions[$Counter]
                Write-Host "$RuleActionStatus | $RuleName"
                $Counter += 1
            }
            "9e6c4e1f-7d60-472f-ba1a-a39ef669e4b2" 
            {
                $RuleName = "Block credential stealing from the Windows local security authority subsystem (lsass.exe)"
                $RuleActionStatus = Get-RuleActionStatus -ActionValue $RuleActions[$Counter]
                Write-Host "$RuleActionStatus | $RuleName"
                $Counter += 1
            }
            "b2b3f03d-6a65-4f7b-a9c7-1c7ef74a9ba4" 
            {
                $RuleName = "Block untrusted and unsigned processes that run from USB"
                $RuleActionStatus = Get-RuleActionStatus -ActionValue $RuleActions[$Counter]
                Write-Host "$RuleActionStatus | $RuleName"
                $Counter += 1
            }
            "be9ba2d9-53ea-4cdc-84e5-9b1eeee46550" 
            {
                $RuleName = "Block executable content from email client and webmail"
                $RuleActionStatus = Get-RuleActionStatus -ActionValue $RuleActions[$Counter]
                Write-Host "$RuleActionStatus | $RuleName"
                $Counter += 1
            }
            "c1db55ab-c21a-4637-bb3f-a12568109d35" 
            {
                $RuleName = "Use advanced protection against ransomware"
                $RuleActionStatus = Get-RuleActionStatus -ActionValue $RuleActions[$Counter]
                Write-Host "$RuleActionStatus | $RuleName"
                $Counter += 1
            }
            "d1e49aac-8f56-4280-b9ba-993a6d77406c" 
            {
                $RuleName = "Block process creations originating from PSExec and WMI commands"
                $RuleActionStatus = Get-RuleActionStatus -ActionValue $RuleActions[$Counter]
                Write-Host "$RuleActionStatus | $RuleName"
                $Counter += 1
            }
            "d3e037e1-3eb8-44c8-a917-57927947596d" 
            {
                $RuleName = "Block JavaScript or VBScript from launching downloaded executable content"
                $RuleActionStatus = Get-RuleActionStatus -ActionValue $RuleActions[$Counter]
                Write-Host "$RuleActionStatus | $RuleName"
                $Counter += 1
            }
            "d4f940ab-401b-4efc-aadc-ad5f3c50688a" 
            {
                $RuleName = "Block all Office applications from creating child processes"
                $RuleActionStatus = Get-RuleActionStatus -ActionValue $RuleActions[$Counter]
                Write-Host "$RuleActionStatus | $RuleName"
                $Counter += 1
            }
            "e6db77e5-3df2-4cf1-b95a-636979351e5b" 
            {
                $RuleName = "Block persistence through WMI event subscription"
                $RuleActionStatus = Get-RuleActionStatus -ActionValue $RuleActions[$Counter]
                Write-Host "$RuleActionStatus | $RuleName"
                $Counter += 1
            }
            
            Default {}
        }
    }

    Write-Host "`n`n----------- ASR Rule Exclusions -----------`n"
    foreach ($Exclusion in $ListOfExclusions)
    {
        Write-Host "$Exclusion"
    }
    Write-Host "`n`n----------- END OF THE REPORT -----------`n`n`n"
}

try
{
    Main
    Update-OutputOnExit -ExitCode $ExitWithNoError -Results "Report generated successfully"
}
catch
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "We ran into a problem."
}


