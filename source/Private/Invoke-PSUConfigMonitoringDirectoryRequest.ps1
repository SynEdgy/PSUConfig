function Invoke-PSUConfigMonitoringDirectoryRequest
{
    <#
        .SYNOPSIS
            Queries the simulated monitoring owner directory.

        .DESCRIPTION
            Sends a bounded request to the configured DummyJSON base URI and
            surfaces a contextual error when owner resolution cannot complete.

        .PARAMETER Path
            Specifies the relative DummyJSON directory resource to request.

        .EXAMPLE
            Invoke-PSUConfigMonitoringDirectoryRequest -Path 'users/13'

            Returns the simulated directory profile for user 13.
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Path
    )

    $baseUri = $env:PSUCONFIG_DUMMYJSON_BASEURI
    if ([System.String]::IsNullOrWhiteSpace($baseUri))
    {
        $baseUri = 'https://dummyjson.com'
    }

    $requestParameters = @{
        Uri         = '{0}/{1}' -f $baseUri.TrimEnd('/'), $Path.TrimStart('/')
        Method      = 'Get'
        TimeoutSec  = 15
        ErrorAction = 'Stop'
    }

    try
    {
        Invoke-RestMethod @requestParameters
    }
    catch
    {
        throw "Monitoring directory request to '$Path' failed: $($_.Exception.Message)"
    }
}
