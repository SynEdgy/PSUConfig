function Get-PSUConfigAppPath
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
        Get-PSUConfigAppPath -AppName 'PSUConfigDemo'
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter()]
        [System.String]
        $AppName = 'PSUConfigDemo'
    )

    $appPath = Join-Path -Path (Get-PSUConfigModule).ModuleBase -ChildPath 'Apps'
    return (Join-Path -Path $appPath -ChildPath $AppName -Resolve)
}
