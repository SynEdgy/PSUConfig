function Get-PSUConfigDatabaseConfiguration
{
    <#
        .SYNOPSIS
            Loads and caches the SQLite configuration used by PSUConfig.

        .DESCRIPTION
            Resolves the configured synedgy.PSSqlite YAML file, loads its database
            configuration, and caches the result in module scope for later calls.

        .PARAMETER ConfigFile
            Specifies an alternative SQLite YAML configuration file to load instead
            of resolving the module's default configuration file.

        .PARAMETER Force
            Forces the function to reload the configuration file and replace the
            existing module-scoped cached configuration value.

        .EXAMPLE
            Get-PSUConfigDatabaseConfiguration -Force

            Reloads the default SQLite configuration and returns the refreshed value.
    #>
    [CmdletBinding()]
    [OutputType([synedgy.PSSqlite.SqliteDBConfig])]
    param
    (
        [Parameter(DontShow)]
        [System.String]
        $ConfigFile,

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force
    )

    if (-not [string]::IsNullOrWhiteSpace($ConfigFile))
    {
        Write-Verbose -Message ('Loading SQLite configuration from {0}' -f $ConfigFile)
        $script:MyModuleDBConfig = Get-PSSqliteDBConfig -ConfigFile $ConfigFile
        return $script:MyModuleDBConfig
    }

    $moduleConfig = Get-PSUConfigSetting -Force:$Force.IsPresent
    $script:MyModuleDBConfig = $moduleConfig.SqliteDBConfig

    $script:MyModuleDBConfig
}
