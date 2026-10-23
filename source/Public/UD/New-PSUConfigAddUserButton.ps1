function New-PSUConfigAddUserButton
{
    <#
        .SYNOPSIS
            Creates the floating action button used to add a PSUConfig user.

        .DESCRIPTION
            Renders a floating user-add action that opens a modal containing
            New-PSUConfigUserForm.

        .PARAMETER Id
            Specifies the dashboard element identifier assigned to the button.

        .PARAMETER SyncElementId
            Specifies the dashboard element refreshed after creating a user.

        .PARAMETER Language
            Specifies the requested language for the component-owned
            PSUConfig.AddUserButton localization resource.

        .EXAMPLE
            New-PSUConfigAddUserButton -SyncElementId 'usersRegion' -Language 'fr'

            Renders the localized add-user action and refreshes usersRegion
            after submission.
    #>
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Low'
    )]
    [OutputType([System.Object])]
    param
    (
        [Parameter()]
        [System.String]
        $Id = 'addPSUConfigUser',

        [Parameter()]
        [System.String]
        $SyncElementId = 'psuConfigUsersRegion',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Language
    )

    $psuConfigAddUserButtonStringsParameters = @{
        Name              = 'PSUConfig.AddUserButton'
        Language          = $Language
        DefaultUILanguage = (Get-PSUConfigSetting).DefaultUILanguage
        Cache             = $Cache:PSUConfigLocalization
    }
    $psuConfigAddUserButtonStrings = Get-PSUComponentLocalizedData @psuConfigAddUserButtonStringsParameters

    $resolvedSyncElementId = $SyncElementId
    $Page:PSUConfigAddUserButtonSyncElementId = $resolvedSyncElementId
    $Page:PSUConfigAddUserButtonStrings = $psuConfigAddUserButtonStrings
    $Page:PSUConfigAddUserButtonLanguage = $Language

    if ($PSCmdlet.ShouldProcess($Id, 'Render add PSUConfig user button'))
    {
        New-UDTooltip -Content {
            $buttonParameters = @{
                Id      = $Id
                Icon    = New-UDIcon -Icon UserPlus
                Size    = 'Large'
                Color   = 'primary'
                OnClick = {
                    Show-UDModal -Content {
                        # 'Add PSUConfig user'
                        New-UDCard -Title $Page:PSUConfigAddUserButtonStrings.ModalTitle -Content {
                            $formParameters = @{
                                FormId        = 'addPSUConfigUserForm'
                                SyncElementId = $Page:PSUConfigAddUserButtonSyncElementId
                                Language      = $Page:PSUConfigAddUserButtonLanguage
                                Confirm       = $false
                            }

                            New-PSUConfigUserForm @formParameters
                        }
                    } -Footer {
                        # 'Cancel'
                        New-UDButton -Text $Page:PSUConfigAddUserButtonStrings.Cancel -OnClick {
                            Hide-UDModal
                        }
                    }
                }
            }

            New-UDFloatingActionButton @buttonParameters
            # 'Add PSUConfig user'
            New-UDTypography -Text $psuConfigAddUserButtonStrings.Tooltip -Variant body1
        } -FollowCursor -LeaveDelay 5000
    }
}
