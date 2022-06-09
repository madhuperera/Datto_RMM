function Test-ServiceExists
{
    param
    (
        [String] $F_ServiceName
    )

    try
    {
        $WinService = Get-Service -Name $F_ServiceName -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        if ($WinService)
        {
            return $true
        }
        else
        {
            return $false
        }
    }
    catch
    {
        return $false
    }
}