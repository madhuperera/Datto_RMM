[String] $S_Reg_Key_Parent_Path = "HKLM:\SYSTEM\CurrentControlSet\Control"
[String] $S_Reg_Key_Name = "Session Manager"
[String] $S_Reg_Key_Value_Name = "BootExecute"
[String] $S_Reg_Key_Value_Data = "autocheck autochk *"
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

function Test-RegistryKeyValue
{
    param
    (
        [String] $F_Reg_Key_Parent_Path,
        [String] $F_Reg_Key_Name,
        [String] $F_Reg_Key_Value_Name,
        [String] $F_Reg_Key_Value_Data
        # [ValidateSet("String","ExpandString","Binary","DWord","MultiString","Qword")] $F_Reg_Key_Value_Type
    )

    [bool] $ExitValue = $false

    if(Test-Path -Path "$F_Reg_Key_Parent_Path\$Reg_Key_Name" -PathType Container)
    {
        if (Get-ItemProperty -Path "$F_Reg_Key_Parent_Path\$F_Reg_Key_Name" -Name $F_Reg_Key_Value_Name)
        {
            if ((Get-ItemPropertyValue -Path "$F_Reg_Key_Parent_Path\$F_Reg_Key_Name" -Name $F_Reg_Key_Value_Name) -eq $F_Reg_Key_Value_Data)
            {
                $ExitValue = $true
            }
        }
    }

    return $ExitValue
}

if (Test-RegistryKeyValue -F_Reg_Key_Parent_Path $S_Reg_Key_Parent_Path -F_Reg_Key_Name $S_Reg_Key_Name -F_Reg_Key_Value_Name $S_Reg_Key_Value_Name -F_Reg_Key_Value_Data $S_Reg_Key_Value_Data)
{
    Update-OutputOnExit -ExitCode $ExitWithNoError -Results "SUCCESS. Boot Sequence is Normal. No Scheduled Check Disk Found."
}
else
{
    try
    {
        Set-ItemProperty -Path "$S_Reg_Key_Parent_Path\$S_Reg_Key_Name" -Name $S_Reg_Key_Value_Name -Value $S_Reg_Key_Value_Data -Force
        
        if (Test-RegistryKeyValue -F_Reg_Key_Parent_Path $S_Reg_Key_Parent_Path -F_Reg_Key_Name $S_Reg_Key_Name -F_Reg_Key_Value_Name $S_Reg_Key_Value_Name -F_Reg_Key_Value_Data $S_Reg_Key_Value_Data)
        {
            Update-OutputOnExit -ExitCode $ExitWithNoError -Results "SUCCESS. We have successfully cancelled the Scheduled Check Disk"
        }
        else
        {
            Update-OutputOnExit -ExitCode $ExitWithError -Results "WARNING. No errors were thrown but it seems the scheduled check disk has not been cancelled"
        }
    }
    catch
    {
        Update-OutputOnExit -ExitCode $ExitWithError -Results "FAILURE. We could not Cancel the Scheduled Check Disk."
    }
}
