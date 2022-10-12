param
(
    [String] $DattoURL,
    [String] $DattoKey,
    [String] $DattoSecretKey,
    [String] $CSVPath

)

$params = @{
    Url        =  $DattoURL
    Key        =  $DattoKey
    SecretKey  =  $DattoSecretKey
}
Import-Module DattoRmm
Set-DrmmApiParameters @params

$CSV_File_Path = $CSVPath


# Filtering just for Desktops and Laptops
$DattoAllDevices | Get-DrmmAccountDevices
$DattoDevices = $DattoAllDevices | Where-Object {$_.deviceType.category -eq "Desktop" -or $_.deviceType.category -eq "Laptop"}
$DattoDevices | Export-Csv -Path $CSV_File_Path -NoTypeInformation
