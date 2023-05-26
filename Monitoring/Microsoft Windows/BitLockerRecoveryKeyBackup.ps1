# Author : Madhu Perera
# Version : 1.0.0
# Summary: Monitoring to see if BitLocker is enabled and backup the Recovery Keys

# ------------------------------- START -------------------------------
[bool] $ExitWithError = $true
[bool] $ExitWithNoError = $false
[string] $Output = ""
[String] $UDFMessage = ""
REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v Custom29 /t REG_SZ /d $UFDValue /f

[String] $RecoveryPassword = ""

function Update-OutputOnExit
{
    param
    (
        [String] $UFDValue,
        [bool] $ExitCode,
        [String] $Results
    )

    if ($UFDValue)
    {
        REG ADD HKEY_LOCAL_MACHINE\SOFTWARE\CentraStage /v Custom16 /t REG_SZ /d $UFDValue /f
    }
        
    write-host '<-Start Result->' -ErrorAction SilentlyContinue
    write-host "STATUS=$Results" -ErrorAction SilentlyContinue
    write-host '<-End Result->' -ErrorAction SilentlyContinue
    exit $ExitCode
}

$C_Drive = Get-BitLockerVolume -MountPoint C:


if ($C_Drive)
{  
    if (($C_Drive.VolumeStatus -eq "FullyEncrypted") -or ($C_Drive.VolumeStatus -eq "EncryptionInProgress") )
    {
        $Output += "C Drive is BitLocker Protected"
        $C_Drive

        if ($C_Drive.KeyProtector)
        {
            $RecoveryPassword = ($C_Drive.KeyProtector | Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"}).RecoveryPassword

            if ($RecoveryPassword)
            {
                $UDFMessage = $RecoveryPassword
                $Output += "`nRecovery Password is Available"
                Update-OutputOnExit -UFDValue $UDFMessage -Results $Output -ExitCode $ExitWithNoError
            }
            else
            {
                $UDFMessage = "No Recovery Key"
                $Output += "`nNo Recovery Password"
                Update-OutputOnExit -UFDValue $UDFMessage -Results $Output -ExitCode $ExitWithError
            }
        }
        else
        {
            if ($C_Drive.ProtectionStatus -eq "Off")
            {
                $Output += "`nBitLocker Protection is Turned Off!"
                $UDFMessage = "Off"
                Update-OutputOnExit -UFDValue $UDFMessage -Results $Output -ExitCode $ExitWithError
            }    
        }
    }
    elseif ($C_Drive.VolumeStatus -eq "FullyDecrypted")
    {
        $Output += "C Drive is NOT BitLocker Protected"
        $C_Drive

        $UDFMessage = "Decrypted"
        Update-OutputOnExit -UFDValue $UDFMessage -Results $Output -ExitCode $ExitWithError
    }
    else
    {
        $Output += "Script Needs to be updated to capture the status: $($C_Drive.VolumeStatus) "
        $C_Drive

        $UDFMessage = "Unsupported Status"
        Update-OutputOnExit -UFDValue $UDFMessage -Results $Output -ExitCode $ExitWithError
    }  
}
else
{
    $UDFMessage = "Error"
    
    $Output += "`nIssues checking C Drive BitLocker Status"
    Update-OutputOnExit -UFDValue $UDFMessage -Results $Output -ExitCode $ExitWithError
}
