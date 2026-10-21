function Get-UDAppPath
{
    <#
        .SYNOPSIS
        Returns the filesystem path for a deployed PowerShell Universal app.

        .DESCRIPTION
        Resolves the path to an app folder relative to the module's base directory.
        Useful for locating bundled Universal Dashboard app files at runtime.

        .PARAMETER AppName
        The name of the app folder. Defaults to 'PSUConfigDemo'.

        .EXAMPLE
        Get-UDAppPath -AppName 'PSUConfigDemo'
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.String]
        $AppName = 'PSUConfigDemo'
    )

    return (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "Apps/$AppName/" -Resolve)
}
