function Initialize-PSUConfigDB
{
    <#
        .SYNOPSIS
            Initializes the SQLite database used by the PSUConfig module.

        .DESCRIPTION
            Applies the configured synedgy.PSSqlite schema to the PSUConfig database,
            optionally forcing an overwrite when an administrative rebuild is required.

        .PARAMETER SqliteDBConfig
            Supplies the resolved SQLite database configuration used for initialization.

        .PARAMETER Force
            Forces an overwrite initialization that can replace the existing database.

        .EXAMPLE
            Initialize-PSUConfigDB -Force

            Recreates the configured PSUConfig database using overwrite migration mode.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.Object])]
    param
    (
        [Parameter(DontShow)]
        [synedgy.PSSqlite.SqliteDBConfig]
        $SqliteDBConfig = (Get-myModuleConfig),

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    if ($null -eq $SqliteDBConfig)
    {
        Write-Error -Message 'Configuration could not be loaded.'
        return
    }

    if ($PSCmdlet.ShouldProcess($SqliteDBConfig.DatabasePath, 'Initialize PSUConfig database'))
    {
        Write-Verbose -Message 'Initializing database...'
        $initializeDatabaseParameters = @{
            DatabaseConfig = $SqliteDBConfig
            Verbose        = $Verbose.IsPresent
            Force          = $Force.IsPresent
            Debug          = $Debug.IsPresent
        }

        Initialize-PSSqliteDatabase @initializeDatabaseParameters
    }
}
