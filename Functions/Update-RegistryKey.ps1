function Update-RegistryKey
{
    param
    (
        [String] $Reg_Key_Parent_Path,
        [String] $Reg_Key_Name,
        [String] $Reg_Key_Value_Name,
        [String] $Reg_Key_Value_Data,
        [ValidateSet("String","ExpandString","Binary","DWord","MultiString","Qword")] $Reg_Key_Value_Type
    )
    [bool] $ExitWithError = $true
    [bool] $ExitWithNoError = $false

    if(!(Test-Path -Path "$Reg_Key_Parent_Path\$Reg_Key_Name" -PathType Container))
    {
        New-Item -Path $Reg_Key_Parent_Path -Name $Reg_Key_Name -ItemType Conatiner -Force
    }

    if ($Reg_Key_Value_Data -and $Reg_Key_Value_Name)
    {
        try
        {
            New-ItemProperty -Path "$Reg_Key_Parent_Path\$Reg_Key_Name" -Name $Reg_Key_Value_Name -PropertyType String -Value $Reg_Key_Value_Data -Force
        }
        catch
        {
            exit $ExitWithError
        }
        
    }
    exit $ExitWithNoError
}