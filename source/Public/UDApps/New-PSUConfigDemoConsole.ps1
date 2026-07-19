function New-PSUConfigDemoConsole
{
    <#
        .SYNOPSIS
        Creates the PSUConfig demo Universal Dashboard application definition.

        .DESCRIPTION
        Loads dashboard page scripts from the module app folder and composes the
        PSUConfig demo dashboard navigation and page registration object. This app
        demonstrates the shared job UI components from synedgy.universal.helper
        (New-UDPsuJobHeader and New-UDPsuJobTerminalView).

        .EXAMPLE
        New-PSUConfigDemoConsole -Confirm:$false
        Builds and returns the dashboard application object for registration.
    #>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]
    param ()

    $moduleBase = $MyInvocation.MyCommand.Module.ModuleBase
    $appPath = Join-Path -Path $moduleBase -ChildPath 'Apps'
    $appPath = Join-Path -Path $appPath -ChildPath 'PSUConfigDemo'
    $appPagesPath = Join-Path -Path $appPath -ChildPath 'pages'

    $pageList = Get-ChildItem -Path $appPagesPath -Recurse -Filter '*.ps1' | ForEach-Object {
        $pageScript = $_.FullName
        . $pageScript
    }

    if ($PSCmdlet.ShouldProcess('PSUConfig demo dashboard definition', 'Create dashboard application object'))
    {
        New-UDApp -Title 'PSUConfig Demo' -Pages $pageList -Navigation (
            New-UDList -Children {
                New-UDListItem -Label 'Home' -Href '/' -Icon (New-UDIcon -Icon 'House')
            }
        ) -NavigationLayout Permanent
    }
}
