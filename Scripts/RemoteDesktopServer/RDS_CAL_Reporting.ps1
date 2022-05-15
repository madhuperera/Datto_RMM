$FileName = (Invoke-WmiMethod Win32_TSLicenseReport -Name GenerateReportEx).FileName
$SummaryEntries = (Get-WmiObject Win32_TSLicenseReport|Where-Object FileName -eq $FileName).FetchReportSummaryEntries(0,0).ReportSummaryEntries
$JSONOutput = $SummaryEntries | Select-Object ProductVersion, TSCALType, InstalledLicenses, IssuedLicenses | ConvertTo-Json
$CSVOutput = $SummaryEntries | Select-Object ProductVersion, TSCALType, InstalledLicenses, IssuedLicenses | ConvertTo-Csv -NoTypeInformation

# Generating a String Value for Registry for Datto UDF
$CALValues = $CSVOutput | Where-Object {$_ -like "*RDS Per User CAL*"}
$CustomRegistryValue = ""

if ($CALValues.Count -gt 1)
{
    $count = 0
    do
    {
        $CustomRegistryValue += $CALValues[$count] + " || "
        $count += 1
    }
    while ($count -lt ($CALValues.Count - 1))
    $CustomRegistryValue += $CALValues[$count]
}
else
{
    $CustomRegistryValue = $CALValues
}

New-ItemProperty -Path HKLM:\SOFTWARE\CentraStage -Name Custom25 -Value $CustomRegistryValue -PropertyType String -Force | Out-Null

$Output = $JSONOutput
write-host '<-Start Result->'
write-host "STATUS=Success | $Output"
write-host '<-End Result->'