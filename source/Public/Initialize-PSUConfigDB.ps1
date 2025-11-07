function Initialize-PSUConfigDB
{
    [CmdletBinding()]
    param
    (
        [Parameter(DontShow)]
        [synedgy.PSSqlite.SqliteDBConfig]
        $SqliteDBConfig = (Get-myModuleConfig),

        [Parameter()]
        [switch]
        $Force
    )

    if ($null -eq $SqliteDBConfig)
    {
        Write-Error -Message 'Configuration could not be loaded.'
        return
    }

    Write-Verbose -Message 'Initializing database...'
    Initialize-PSSqliteDatabase -DatabaseConfig $SqliteDBConfig -Verbose:$Verbose.IsPresent -Force:$Force.IsPresent -Debug:$Debug.IsPresent
}
