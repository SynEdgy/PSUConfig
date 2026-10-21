function New-PSUConfigDemoConsole
{
    <#
        .SYNOPSIS
        Creates the PSUConfig demo Universal Dashboard application definition.

        .DESCRIPTION
        Loads dashboard page scripts from the module app folder and composes the
        SynEdgy-branded PSUConfig dashboard. The application demonstrates a
        module-first PowerShell Universal configuration repository built, tested,
        packaged, and deployed through the Sampler framework.

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
    $logoPath = Join-Path -Path $appPath -ChildPath 'assets'
    $logoPath = Join-Path -Path $logoPath -ChildPath 'synedgy-logo.svg'
    $logoData = [System.Convert]::ToBase64String([System.IO.File]::ReadAllBytes($logoPath))
    $logoUrl = 'data:image/svg+xml;base64,{0}' -f $logoData
    $themePath = Join-Path -Path $appPath -ChildPath 'theme.psd1'
    $theme = Import-PowerShellDataFile -Path $themePath

    $pageList = Get-ChildItem -Path $appPagesPath -Recurse -Filter '*.ps1' |
        Sort-Object -Property Name |
        ForEach-Object {
            $pageScript = $_.FullName
            . $pageScript
        }

    if ($PSCmdlet.ShouldProcess('PSUConfig demo dashboard definition', 'Create dashboard application object'))
    {
        $appParameters = @{
            Title                 = 'PSUConfig by SynEdgy'
            Pages                 = $pageList
            Theme                 = $theme
            DefaultTheme          = 'Dark'
            DisableThemeToggle    = $false
            Logo                  = $logoUrl
            HeaderPosition        = 'sticky'
            Navigation            = @(
                New-UDList -Children {
                    $homeParameters = @{
                        Label = 'Module-first demo'
                        Href  = '/'
                        Icon  = New-UDIcon -Icon 'Cubes'
                    }
                    New-UDListItem @homeParameters

                    $usersParameters = @{
                        Label = 'Users'
                        Href  = '/users'
                        Icon  = New-UDIcon -Icon 'Users'
                    }
                    New-UDListItem @usersParameters
                }
            )
            NavigationLayout      = 'Permanent'
        }

        New-UDApp @appParameters
    }
}
