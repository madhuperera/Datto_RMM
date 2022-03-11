# _______________ PLEASE CHANGE UDF VARIABLE __________________

[String] $UDF_ToUpdate = "CHANGEME"  # Example: "custom28"

# ______________________________________________________________

[String] $Output = ""
[bool] $ExitWithError = $true
[bool] $ExitWithNoError = $false


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
        New-ItemProperty -Path HKLM:\SOFTWARE\CentraStage\ -Name $UDF_Value -PropertyType String -Value $Registry_Value -Force
    }
        
    write-host '<-Start Result->' -ErrorAction SilentlyContinue
    write-host "STATUS=$Results" -ErrorAction SilentlyContinue
    write-host '<-End Result->' -ErrorAction SilentlyContinue
    exit $ExitCode
}

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
    # PLEASE UPDATE UDF NUMBER BELOW
    REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v Custom28 /t REG_SZ /d "Great | No Admins" /f
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

    # PLEASE UPDATE UDF NUMBER BELOW
    REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v Custom28 /t REG_SZ /d "Warning | Admins Found" /f
    write-host '<-Start Result->'
 	write-host "STATUS=Warning $Output"
 	write-host '<-End Result->'
 	exit 1
}