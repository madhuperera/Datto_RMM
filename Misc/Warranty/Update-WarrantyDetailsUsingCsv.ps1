# Author : Madhu Perera
# Version : 2.0.0
# Summary: 

# Columns Needed in the CSV
# ConfigurationName | ConnectWise Configuration
# Expires | must be DD/MM/YYY Format.
# DeviceID | Datto UID
# SerialNumber | Serial Number from the Device
# ------------------------------- START -------------------------------

param
(
    [String] $DattoURL,
    [String] $DattoKey,
    [String] $DattoSecretKey,
    [String] $CSVPath,
    [String] $DateFormat

)

$params = @{
    Url        =  $DattoURL
    Key        =  $DattoKey
    SecretKey  =  $DattoSecretKey
}
Import-Module DattoRmm
Set-DrmmApiParameters @params

$CSV_File_Path = $CSVPath


$CSV = Import-Csv -Path $CSV_File_Path

function Set-DattoWarrantyDateNZ
{
    param
    (        
        [String] $DateToChange
    )

    [string] $NewDate = ""

    $tmpCatcher = $DateToChange -split "/"
    $NewDate = -join ($tmpCatcher[2],"-",$tmpCatcher[1],"-",$tmpCatcher[0])
    
    return $NewDate
}

function Set-DattoWarrantyDateUS
{
    param
    (        
        [String] $DateToChange
    )

    [string] $NewDate = ""

    $tmpCatcher = $DateToChange -split "/"
    $NewDate = -join ($tmpCatcher[2],"-",$tmpCatcher[0],"-",$tmpCatcher[1])
    
    return $NewDate
}

Write-Host "Starting the import process"
foreach ($Item in $CSV)
{
    Write-Host "Current Device in CSV.... $($Item.ConfigurationName)"
    $DattoDevice = Get-DrmmDevice -deviceUid $Item.DeviceID
    if ($DattoDevice)
    {
        Write-Host "$($Item.DeviceID) is found in Datto" 
        if ($DattoDevice.warrantyDate)
        {
            Write-Host "Warning | Warranty Date is already set in Datto $($DattoDevice.warrantyDate)" -ForegroundColor Yellow
        }
        else
        {

            # Doing some Serial Key Mathing Before Updating

            $WarrantyDate = ""

            if ($DateFormat -eq 'NZ')
            {
                $WarrantyDate = Set-DattoWarrantyDateNZ -DateToChange $Item.Expires
            }
            
            if ($DateFormat -eq 'US')
            {
                $WarrantyDate = Set-DattoWarrantyDateUS -DateToChange $Item.Expires
            }
            

            
            Write-Host "Will Update the Warranty Date with $WarrantyDate" -ForegroundColor Green
            Set-DrmmDeviceWarranty -deviceUid $Item.DeviceID -warrantyDate $WarrantyDate -ErrorAction Stop
            if ((Get-DrmmDevice -deviceUid $Item.DeviceID).warrantyDate)
            {
                Write-Host "Warranty Date successfully updated with $((Get-DrmmDevice -deviceUid $Item.DeviceID).warrantyDate)" -ForegroundColor Green
            }
            else
            {
                Write-Host "Opps! Something went wrong" -ForegroundColor Red
            }
        }
    }
    else
    {
        Write-Host "$($Item.DeviceID) is missing in Datto" -ForegroundColor Red
    }

    Write-Host "--------------------------------------------------------------------------" -ForegroundColor Blue
}
