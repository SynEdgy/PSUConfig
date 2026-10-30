function Get-PSUConfigServerConnectionParameter
{
    <#
        .SYNOPSIS
            Gets connection parameters for local PSU job invocation.

        .DESCRIPTION
            Selects the configured PSUConfig automation token and server URL
            when available, otherwise returning an integrated connection setting.

        .EXAMPLE
            Get-PSUConfigServerConnectionParameter

            Returns a hashtable suitable for splatting to PSU job commands.
    #>
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param ()

    $parameters = @{}
    $appToken = [System.String]$env:UniversalServerAppToken
    if ([System.String]::IsNullOrWhiteSpace($appToken))
    {
        $appToken = [System.String]$Secret:psuconfig_automation_bot_token
    }

    if (-not [System.String]::IsNullOrWhiteSpace($appToken))
    {
        $parameters.AppToken = $appToken
        $serverUrl = [System.String](Get-PSUConfigSetting).UniversalServerUrl
        if (-not [System.String]::IsNullOrWhiteSpace($serverUrl))
        {
            $parameters.ComputerName = $serverUrl
        }
    }
    else
    {
        $parameters.Integrated = $true
    }

    $parameters
}
