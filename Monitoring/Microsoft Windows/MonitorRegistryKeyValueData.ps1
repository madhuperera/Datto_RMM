[String] $SReg_Key_Parent_Path = $ENV:DRMM_SReg_Key_Parent_Path # "HKLM:\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection"
[String] $SReg_Key_Name = $ENV:DRMM_SReg_Key_Name # "DeviceTagging"
[String] $SReg_Key_Value_Name = $ENV:DRMM_SReg_Key_Value_Name # "Group"
[String] $SReg_Key_Value_Data = $ENV:DRMM_SReg_Key_Value_Data # "New_Zealand"
[bool] $ExitWithError = $true
[bool] $ExitWithNoError = $false
[String] $UDF_Value = "CHANGE ME" # Ex: Custom20
[String] $Registry_Value = $SReg_Key_Value_Data # Ex: "New_Zealand"

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

if (Test-RegistryKeyValue -F_Reg_Key_Parent_Path $SReg_Key_Parent_Path -F_Reg_Key_Name $SReg_Key_Name -F_Reg_Key_Value_Name $SReg_Key_Value_Name -F_Reg_Key_Value_Data $SReg_Key_Value_Data)
{
    Update-OutputOnExit -ExitCode $ExitWithNoError -Results "We found the matching Registry Key, Value and Data." -UDF_Value $UDF_Value -Registry_Value $Registry_Value
}
else
{
    Update-OutputOnExit -ExitCode $ExitWithError -Results "Oh No! We did not find what you were after." -UDF_Value $UDF_Value -Registry_Value $Registry_Value
}