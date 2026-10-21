function Get-CurrentEnvironment
{
    <#
        .SYNOPSIS
            Returns the active PSUConfig environment name.

        .DESCRIPTION
            Resolves DEV, QA, or PROD from an explicit value, the ServerEnvironment
            environment variable, or local machine characteristics, and caches the
            result for subsequent configuration requests.

        .PARAMETER Environment
            Explicitly selects the DEV, QA, or PROD environment.

        .PARAMETER Force
            Forces the environment to be evaluated again instead of using the cache.

        .EXAMPLE
            Get-CurrentEnvironment -Environment QA -Force

            Selects QA as the active environment for the current module session.
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param
    (
        [Parameter()]
        [ValidateSet('DEV', 'QA', 'PROD')]
        [string]
        $Environment = 'DEV',

        [Parameter()]
        [switch]
        $Force
    )

    if (-not [string]::IsNullOrWhiteSpace($script:PSUConfigEnvironment) -and -not $Force.IsPresent)
    {
        return $script:PSUConfigEnvironment
    }

    if ($PSBoundParameters.ContainsKey('Environment'))
    {
        $script:PSUConfigEnvironment = $Environment
    }
    elseif (-not [string]::IsNullOrWhiteSpace($env:ServerEnvironment) -and
        $env:ServerEnvironment -in @('DEV', 'QA', 'PROD'))
    {
        $script:PSUConfigEnvironment = $env:ServerEnvironment
    }
    elseif ($env:COMPUTERNAME -match '-QA$')
    {
        $script:PSUConfigEnvironment = 'QA'
    }
    elseif ([System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT -and
        (Get-CimInstance -ClassName Win32_OperatingSystem).ProductType -eq 1)
    {
        $script:PSUConfigEnvironment = 'DEV'
    }
    else
    {
        $script:PSUConfigEnvironment = 'PROD'
    }

    $script:PSUConfigEnvironment
}
