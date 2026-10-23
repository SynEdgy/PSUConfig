function Get-PSUConfigModule
{
    <#
        .SYNOPSIS
        Gets the loaded PSUConfig module.

        .DESCRIPTION
        Returns the PSModuleInfo for the module that owns this command. This
        provides a stable module base for deferred PowerShell Universal
        callbacks without relying on their invocation stack.

        .EXAMPLE
        $moduleBase = (Get-PSUConfigModule).ModuleBase

        Gets the deployed PSUConfig module base.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSModuleInfo])]
    param ()

    $module = $MyInvocation.MyCommand.Module
    if ($null -eq $module)
    {
        throw [System.InvalidOperationException]::new('Unable to resolve the loaded PSUConfig module.')
    }

    return $module
}
