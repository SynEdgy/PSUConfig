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
            HeaderContent         = {
                $moduleBase = (Get-PSUConfigModule).ModuleBase
                $defaultUILanguage = (Get-PSUConfigSetting).DefaultUILanguage
                if ($null -eq $defaultUILanguage)
                {
                    $defaultUILanguage = 'en'
                }

                $languageParameters = @{
                    ModuleBase        = $moduleBase
                    Name              = 'PSUConfigDemo'
                    PreferredLanguage = [System.String] $Cookies['PSUConfigLanguage']
                    AcceptLanguage    = [System.String] $Headers['Accept-Language']
                    DefaultUILanguage = $defaultUILanguage
                }
                $language = Resolve-PSULocalizationLanguage @languageParameters

                $languageSelectorParameters = @{
                    ModuleBase       = $moduleBase
                    Language         = $language
                    Name             = 'PSUConfigDemo'
                    CookieName       = 'PSUConfigLanguage'
                    UseLanguageLabel = $true
                    ClassName        = 'psuconfig-language-selector'
                    Sx               = @{
                        minWidth    = '88px'
                        marginRight = '12px'
                        alignSelf   = 'center'
                        height      = '36px'
                        '& .MuiSelect-select' = @{
                            paddingTop    = '2px'
                            paddingBottom = '2px'
                        }
                    }
                    Confirm          = $false
                }
                New-UDLanguageSelector @languageSelectorParameters
            }
            Navigation            = @(
                New-UDDynamic -Id 'psuconfig-navigation' -Content {
                    $moduleBase = (Get-PSUConfigModule).ModuleBase
                    $defaultUILanguage = (Get-PSUConfigSetting).DefaultUILanguage
                    if ($null -eq $defaultUILanguage)
                    {
                        $defaultUILanguage = 'en'
                    }

                    $navigationLanguageParameters = @{
                        ModuleBase        = $moduleBase
                        Name              = 'PSUConfigDemo'
                        PreferredLanguage = [System.String] $Cookies['PSUConfigLanguage']
                        AcceptLanguage    = [System.String] $Headers['Accept-Language']
                        DefaultUILanguage = $defaultUILanguage
                    }
                    $navigationLanguage = Resolve-PSULocalizationLanguage @navigationLanguageParameters
                    if ($null -eq $Cache:PSUConfigLocalization)
                    {
                        $Cache:PSUConfigLocalization = [System.Collections.Hashtable]::Synchronized(@{})
                    }

                    $psuConfigDemoStringsParameters = @{
                        Language = $navigationLanguage
                        Cache    = $Cache:PSUConfigLocalization
                    }
                    $psuConfigDemoStrings = Get-PSUConfigLocalizedData @psuConfigDemoStringsParameters

                    New-UDList -Children {
                        $homeParameters = @{
                            # 'Module-first demo'
                            Label = $psuConfigDemoStrings.NavigationHome
                            Href  = '/'
                            Icon  = New-UDIcon -Icon 'Cubes'
                        }
                        New-UDListItem @homeParameters

                        $usersParameters = @{
                            # 'Users'
                            Label = $psuConfigDemoStrings.NavigationUsers
                            Href  = '/users'
                            Icon  = New-UDIcon -Icon 'Users'
                        }
                        New-UDListItem @usersParameters
                    }
                }
            )
            NavigationLayout      = 'Permanent'
        }

        New-UDApp @appParameters
    }
}
