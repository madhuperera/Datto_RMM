$LogName_S = "Microsoft-Windows-DNS-Client/Operational"

$Log = Get-WinEvent -ListLog $LogName_S
if ($Log.IsEnabled)
{
    # Success
}
else
{
    $Log.IsEnabled = $true
    $Log.SaveChanges()
}