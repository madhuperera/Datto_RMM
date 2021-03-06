# Datto_RMM
Welcome to Madhu's Repository of Scripts for [Datto RMM](https://www.datto.com/products/rmm/ "Datto RMM"). I am sharing these scripts "AS IS" without any kind of warranty. Please go through the scripts' content before deploying in your environment.

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
### Misc
Collection of Miscellaneous Scripts that are not part of Datto Monitoring or Scripts. For example, [Update-WarrantyDetailsUsingCsv](https://github.com/madhuperera/Datto_RMM/blob/main/Misc/Warranty/Update-WarrantyDetailsUsingCsv.ps1 "Update-WarrantyDetailsUsingCsv") is a PowerShell script that you can use to update Warranty Expiry Dates in Datto RMM using a CSV file. 

### Monitoring
Here, you will find a collection of PowerShell scripts that you can use with a Monitoring Policy in Datto RMM. Deploy these Scripts as a Monitoring Component in your Environment, so you can use them within Monitoring Policies. You can find more information on how to create a Datto RMM Monitor [here](https://rmm.datto.com/help/en/Content/4WEBPORTAL/Policies/MonitoringPolicy.htm "here").

### Script
This is collection of PowerShell scripts that you can use to carry out certain tasks on Windows Devices. While a monitoring Script can also be used as a Script in Datto, Scripts found here are not suitable to use with monitoring policies. 

## Feedback
Constructive feedback is always appreciated. I am doing most of these Scripts in my own Personal time, so I will not be able to update these as often as I would have liked to. If you find any issues with the Scripts, please leave a comment and I will try my best to get it sorted and update the Script. If you have an idea for a Script that could be useful for yourself as well as others, you can contact me using any of the Social Media platforms below:
- [LinkedIn](https://www.linkedin.com/in/madhuperera/ "LinkedIn")
- [Twitter](https://twitter.com/madhu_perera "Twitter")