New-UDPage -Name 'PSUConfig users' -Url '/users' -Content {
    New-PSUConfigAddUserButton -Id 'addPSUConfigUser' -SyncElementId 'psuConfigUsersRegion' -Confirm:$false

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
            New-UDTypography -Text 'SYNEDGY · SQLITE DATA' -Variant overline -Style @{
                color         = '#38A7DF'
                fontWeight    = 800
                letterSpacing = '0.14em'
            }
            New-UDTypography -Text 'PSUConfig users' -Variant h3 -Style @{
                fontWeight    = 850
                letterSpacing = '-0.035em'
                marginBottom  = '8px'
            }
            New-UDTypography -Text 'User records loaded through the module-first Get-PSUConfigUser command.' -Sx @{
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
                        Title         = 'Internal users'
                        PageSize      = 10
                        SyncElementId = 'psuConfigUsersRegion'
                        Confirm       = $false
                    }

                    New-PSUConfigUserTable @tableParameters
                }
            }
        }
    }
}
