function Initialize-PSUConfigLocalizationCache
{
    <#
        .SYNOPSIS
        Initializes the PSUConfig localization server cache.

        .DESCRIPTION
        Uses the shared localization cache initializer for the PSUConfigDemo
        resource and stores the result in the PowerShell Universal execution
        environment cache for use by app runspaces.

        .PARAMETER Name
        The localization resource bundle to initialize. Defaults to PSUConfigDemo.

        .PARAMETER Force
        Forces the underlying localization resource loader to bypass its caches.

        .PARAMETER Cache
        An optional cache dictionary to populate. When omitted, the dictionaries
        are stored in the PSU execution environment's shared Cache scope.

        .EXAMPLE
        Initialize-PSUConfigLocalizationCache -Force
        Reloads all available dictionaries and replaces the environment cache entry.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name = 'PSUConfigDemo',

        [Parameter()]
        [System.Management.Automation.SwitchParameter]
        $Force,

        [Parameter()]
        [System.Collections.IDictionary]
        $Cache
    )

    $cacheWasProvided = $PSBoundParameters.ContainsKey('Cache')
    if ($cacheWasProvided -and $null -eq $Cache)
    {
        throw [System.ArgumentNullException]::new(
            'Cache',
            'The cache dictionary cannot be null when the Cache parameter is supplied.'
        )
    }

    if ($cacheWasProvided)
    {
        $localizationCache = $Cache
    }
    else
    {
        if ($null -eq $Cache:PSUConfigLocalization)
        {
            $Cache:PSUConfigLocalization = [System.Collections.Hashtable]::Synchronized(@{})
        }

        $localizationCache = $Cache:PSUConfigLocalization
    }

    if (-not $localizationCache.Contains($Name))
    {
        $localizationCache[$Name] = [System.Collections.Hashtable]::Synchronized(@{})
    }

    $resourceCache = $localizationCache[$Name]
    if ($resourceCache -isnot [System.Collections.IDictionary])
    {
        $message = "Cached localization resource '$Name' is not a dictionary."
        throw [System.IO.InvalidDataException]::new($message)
    }

    $defaultUICulture = (Get-PSUConfigSetting).DefaultUILanguage
    if ($null -eq $defaultUICulture)
    {
        $defaultUICulture = 'en'
    }

    $initializeParameters = @{
        ModuleBase       = (Get-PSUConfigModule).ModuleBase
        Name             = $Name
        DefaultUICulture = $defaultUICulture
        Cache            = $resourceCache
        Force            = $Force.IsPresent
    }

    $localizedData = Initialize-PSULocalizationCache @initializeParameters
    return $localizedData
}
