[String] $Output = ""
[String] $UFDToUpdate = "Custom28"

# Getting a List of Local Administrators and removing unnecessary lines
[System.Collections.ArrayList] $LocalAdministrators = net localgroup administrators | Select-Object -skip 6
$LocalAdministrators.Remove($LocalAdministrators[$LocalAdministrators.Count - 1])
$LocalAdministrators.Remove($LocalAdministrators[$LocalAdministrators.Count - 1])

$BuiltInAdminName = (Get-LocalUser | Where-Object {$_.Description -like "Built-in account for administering*"}).Name
$BuiltInAdminEnabled = (Get-LocalUser | Where-Object {$_.Description -like "Built-in account for administering*"}).Enabled

If (!$BuiltInAdminEnabled)
{
    $LocalAdministrators.Remove($BuiltInAdminName)
}

if ($LocalAdministrators.Count -eq 0)
{
    $Output = "Excellent! No Local Administrator Accounts Found."
    REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v $UFDToUpdate /t REG_SZ /d "Great | No Admins" /f
    write-host '<-Start Result->'
    write-host "STATUS=All Good $Output"
    write-host '<-End Result->'
    exit 0
}
else
{
    
    foreach ($Account in $LocalAdministrators)
    {
        $Output = $Output + $Account + " | "
    }

    REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v $UFDToUpdate /t REG_SZ /d "Warning | Admins Found" /f
    write-host '<-Start Result->'
 	write-host "STATUS=Warning $Output"
 	write-host '<-End Result->'
 	exit 1
}