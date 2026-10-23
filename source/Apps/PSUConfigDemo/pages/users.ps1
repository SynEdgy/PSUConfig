New-UDPage -Name 'PSUConfig users' -Url '/users' -Content {
    $module = Get-PSUConfigModule
    $moduleBase = $module.ModuleBase
    $defaultUILanguage = (Get-PSUConfigSetting).DefaultUILanguage
    if ($null -eq $defaultUILanguage)
    {
        $defaultUILanguage = 'en'
    }

    $languageParameters = @{
        ModuleBase        = $moduleBase
        Name              = 'PSUConfig.Users'
        PreferredLanguage = [System.String] $Cookies['PSUConfigLanguage']
        AcceptLanguage    = [System.String] $Headers['Accept-Language']
        DefaultUILanguage = $defaultUILanguage
    }
    $language = Resolve-PSULocalizationLanguage @languageParameters
    if ($null -eq $Cache:PSUConfigLocalization)
    {
        $Cache:PSUConfigLocalization = [System.Collections.Hashtable]::Synchronized(@{})
    }

    $psuConfigUsersStringsParameters = @{
        Name     = 'PSUConfig.Users'
        Language = $language
        Cache    = $Cache:PSUConfigLocalization
    }
    $psuConfigUsersStrings = Get-PSUConfigLocalizedData @psuConfigUsersStringsParameters

    $addUserButtonParameters = @{
        Id            = 'addPSUConfigUser'
        SyncElementId = 'psuConfigUsersRegion'
        Language      = $language
        Confirm       = $false
    }
    New-PSUConfigAddUserButton @addUserButtonParameters

    New-UDElement -Tag 'main' -Attributes @{
        style = @{
            minHeight = '100vh'
            margin    = '-24px'
            padding   = '48px 32px 72px'
        }
    } -Content {
        New-UDElement -Tag 'div' -Attributes @{
            style = @{
                maxWidth = '1440px'
                margin   = '0 auto'
            }
        } -Content {
            # 'SYNEDGY · SQLITE DATA'
            New-UDTypography -Text $psuConfigUsersStrings.PageEyebrow -Variant overline -Style @{
                color         = '#38A7DF'
                fontWeight    = 800
                letterSpacing = '0.14em'
            }
            # 'PSUConfig users'
            New-UDTypography -Text ($psuConfigUsersStrings.PageTitle -f $module.Name) -Variant h3 -Style @{
                fontWeight    = 850
                letterSpacing = '-0.035em'
                marginBottom  = '8px'
            }
            # 'User records loaded through the module-first Get-PSUConfigUser command.'
            New-UDTypography -Text ($psuConfigUsersStrings.PageDescription -f 'Get-PSUConfigUser') -Sx @{
                color = 'text.secondary'
            } -Style @{
                marginBottom = '24px'
            }

            New-UDPaper -Elevation 3 -Style @{
                border       = '1px solid rgba(56,167,223,.24)'
                borderRadius = '18px'
                padding      = '20px'
            } -Children {
                New-UDDynamic -Id 'psuConfigUsersRegion' -Content {
                    $tableParameters = @{
                        Id            = 'psuConfigUsers'
                        PageSize      = 10
                        SyncElementId = 'psuConfigUsersRegion'
                        Language      = $language
                        Confirm       = $false
                    }

                    New-PSUConfigUserTable @tableParameters
                }
            }
        }
    }
}
