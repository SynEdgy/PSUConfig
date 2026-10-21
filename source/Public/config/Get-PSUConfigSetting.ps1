function Get-PSUConfigSetting
{
    <#
        .SYNOPSIS
            Loads and caches the complete PSUConfig module configuration.

        .DESCRIPTION
            Loads the SQLite configuration and general YAML configuration from the
            module config folder, applies the selected environment overrides, and
            caches the merged result for subsequent module and dashboard calls.

        .PARAMETER Environment
            Selects the DEV, QA, or PROD environment section to apply.

        .PARAMETER DBConfigFileName
            Specifies the SQLite configuration filename within the config folder.

        .PARAMETER ConfigFileName
            Specifies the general module configuration filename within the config folder.

        .PARAMETER ConfigFolder
            Specifies the folder containing the module configuration YAML files.

        .PARAMETER Force
            Forces the cached module configuration to be rebuilt from disk.

        .EXAMPLE
            Get-PSUConfigSetting -Environment QA -Force

            Reloads the configuration and applies the QA environment settings.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.IDictionary])]
    param
    (
        [Parameter()]
        [ValidateSet('DEV', 'QA', 'PROD')]
        [string]
        $Environment = (Get-CurrentEnvironment),

        [Parameter(DontShow)]
        [string]
        $DBConfigFileName = ('{0}.PSSqliteConfig.yml' -f $MyInvocation.MyCommand.Module.Name),

        [Parameter(DontShow)]
        [string]
        $ConfigFileName = ('{0}.config.yml' -f $MyInvocation.MyCommand.Module.Name),

        [Parameter(DontShow)]
        [string]
        $ConfigFolder = (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath 'config'),

        [Parameter()]
        [switch]
        $Force
    )

    if ($null -eq $script:PSUConfigSetting -or $Force.IsPresent)
    {
        $config = [ordered]@{}
        $dbConfigFile = Join-Path -Path $ConfigFolder -ChildPath $DBConfigFileName
        if (Test-Path -Path $dbConfigFile)
        {
            $config.SqliteDBConfig = Get-PSSqliteDBConfig -ConfigFile $dbConfigFile
        }

        $configFile = Join-Path -Path $ConfigFolder -ChildPath $ConfigFileName
        if (-not (Test-Path -Path $configFile))
        {
            throw "Module configuration file '$configFile' was not found."
        }

        Write-Verbose -Message ('Loading module configuration from {0}' -f $configFile)
        $additionalConfig = Get-Content -Path $configFile -Raw | ConvertFrom-Yaml -Ordered
        foreach ($key in $additionalConfig.Keys)
        {
            if ($key -ne 'Environments')
            {
                $config[$key] = $additionalConfig[$key]
            }
        }

        $environmentConfig = $additionalConfig.Environments[$Environment]
        if ($null -eq $environmentConfig)
        {
            throw "Environment '$Environment' was not found in module configuration '$configFile'."
        }

        foreach ($key in $environmentConfig.Keys)
        {
            $config[$key] = $environmentConfig[$key]
        }

        $config.CurrentEnvironment = $Environment
        $script:PSUConfigSetting = $config
    }

    $script:PSUConfigSetting
}
