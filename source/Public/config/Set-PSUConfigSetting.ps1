function Set-PSUConfigSetting
{
    <#
        .SYNOPSIS
            Sets the active PSUConfig module configuration.

        .DESCRIPTION
            Reloads the cached module configuration using the selected environment
            so subsequent commands and dashboard pages use that environment's values.

        .PARAMETER Environment
            Selects the DEV, QA, or PROD configuration to load.

        .EXAMPLE
            Set-PSUConfigSetting -Environment QA -Confirm:$false

            Reloads PSUConfig with the QA environment settings.
    #>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Low'
    )]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('DEV', 'QA', 'PROD')]
        [string]
        $Environment
    )

    if ($PSCmdlet.ShouldProcess($Environment, 'Set module configuration'))
    {
        $null = Get-CurrentEnvironment -Environment $Environment -Force
        $null = Get-PSUConfigSetting -Environment $Environment -Force
    }
}
