function Get-PSUConfigLocalizedData
{
    <#
        .SYNOPSIS
        Gets cached localized strings for the PSUConfig demo.

        .DESCRIPTION
        Reads a resource-backed dictionary from the PowerShell Universal
        execution environment cache. If the startup cache is missing, it is
        initialized immediately so a deployment does not require a server restart.

        .PARAMETER Name
        The localization resource bundle name. Defaults to PSUConfigDemo.

        .PARAMETER Language
        The resource-backed language to return.

        .PARAMETER Cache
        The shared PSU execution environment cache dictionary.

        .EXAMPLE
        Get-PSUConfigLocalizedData -Language 'fr' -Cache $Cache:PSUConfigLocalization
        Returns the French PSUConfig demo strings.

        .EXAMPLE
        Get-PSUConfigLocalizedData -Name 'PSUConfig.Users' -Language 'fr' -Cache $Cache:PSUConfigLocalization
        Returns the French strings from the PSUConfig.Users resource bundle.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Name = 'PSUConfigDemo',

        [Parameter(Mandatory = $true)]
        [System.String]
        $Language,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]
        $Cache
    )

    if ($null -eq $Cache)
    {
        throw [System.ArgumentNullException]::new('Cache')
    }

    $languageParameters = @{
        ModuleBase = (Get-PSUConfigModule).ModuleBase
        Name       = $Name
    }
    $supportedLanguages = @(Get-PSULocalizationLanguage @languageParameters)
    if ($Language -notin $supportedLanguages)
    {
        throw [System.ArgumentException]::new(
            "Language '$Language' is not available for '$Name'.",
            'Language'
        )
    }

    $resourceCache = $null
    if ($Cache.Contains($Name))
    {
        $resourceCache = $Cache[$Name]
        if ($resourceCache -isnot [System.Collections.IDictionary])
        {
            $message = "Cached localization resource '$Name' is not a dictionary."
            throw [System.IO.InvalidDataException]::new($message)
        }
    }

    if ($null -eq $resourceCache -or -not $resourceCache.Contains($Language))
    {
        $initializeParameters = @{
            Name  = $Name
            Cache = $Cache
        }
        $null = Initialize-PSUConfigLocalizationCache @initializeParameters
        $resourceCache = $Cache[$Name]
    }

    $languageData = $resourceCache[$Language]
    if ($languageData -isnot [System.Collections.IDictionary])
    {
        $message = "Cached localization data for resource '$Name' and language '$Language' is not a dictionary."
        throw [System.IO.InvalidDataException]::new($message)
    }

    $result = @{}
    foreach ($key in $languageData.Keys)
    {
        $result[$key] = [System.String] $languageData[$key]
    }

    return $result
}
