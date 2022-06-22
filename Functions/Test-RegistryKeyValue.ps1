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