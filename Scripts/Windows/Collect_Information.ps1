# Author: Madhu Perera
# Reference: https://github.com/madhuperera/Datto_RMM/blob/main/Scripts/Windows/Collect_Information.ps1

$ReportFolder = "C:\Reports_"

# --------------- FUNCTIONS ------------------
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
        New-ItemProperty -Path HKLM:\SOFTWARE\CentraStage\ -Name $UDF_Value -PropertyType String -Value $Registry_Value -Force
    }
        
    write-host '<-Start Result->' -ErrorAction SilentlyContinue
    write-host "STATUS=$Results" -ErrorAction SilentlyContinue
    write-host '<-End Result->' -ErrorAction SilentlyContinue
    exit $ExitCode
}

# ----------------- MAIN -----------------------------

if (!(Test-Path -Path $ReportFolder -PathType Container))
{
    New-Item -Path $ReportFolder -Type Container -ErrorAction SilentlyContinue
}

Start-Transcript -Path "$ReportFolder\"