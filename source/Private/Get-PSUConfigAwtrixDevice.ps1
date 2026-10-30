function Get-PSUConfigAwtrixDevice
{
    <#
        .SYNOPSIS
            Resolves the AWTRIX device used by the monitoring workflow.

        .DESCRIPTION
            Selects the global PSU variable first, then the matching environment
            variable, and finally the default clock.local AWTRIX device URI.

        .EXAMPLE
            Get-PSUConfigAwtrixDevice

            Returns the configured AWTRIX device URI for monitoring notifications.
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    $getVariableParameters = @{
        Name        = 'PSUCONFIG_AWTRIX_DEVICE'
        Scope       = 'Global'
        ValueOnly   = $true
        ErrorAction = 'SilentlyContinue'
    }
    $psuVariable = Get-Variable @getVariableParameters
    if (-not [System.String]::IsNullOrWhiteSpace($psuVariable))
    {
        return [System.String]$psuVariable
    }

    if (-not [System.String]::IsNullOrWhiteSpace($env:PSUCONFIG_AWTRIX_DEVICE))
    {
        return $env:PSUCONFIG_AWTRIX_DEVICE
    }

    'http://clock.local'
}
