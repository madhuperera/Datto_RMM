# Datto_RMM
Welcome to Madhu's Repository of Scripts for [Datto RMM](https://www.datto.com/products/rmm/ "Datto RMM"). I am sharing these scripts AS IS" without any kind of warranty. Please go through the scripts' content before deploying in your environment.

If you have any question about any of the scripts or you have an idea for a PowerShell based script, please leave a comment.

## Resources
- [Functions](https://github.com/madhuperera/Datto_RMM/tree/main/Functions "Functions")
- [Misc](https://github.com/madhuperera/Datto_RMM/tree/main/Misc "Misc")
- [Monitoring](https://github.com/madhuperera/Datto_RMM/tree/main/Monitoring "Monitoring")
- [Scripts](https://github.com/madhuperera/Datto_RMM/tree/main/Scripts "Scripts")

### Functions
Series of repetative PowerShell codes that you can use within your own Scripts. For example, I use the piece of function below to exit the script with Error or Success. You can also use the same function to update output message and a Datto UDF (User Defined Field).
```Shell
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
```

## MicrosoftDefenderStatusUpdate
Monitoring all Defender related services and features.

## MonitoringLocalAdministratorGroup
Monitoring Local Administrator Group to see if there are any user accounts.
