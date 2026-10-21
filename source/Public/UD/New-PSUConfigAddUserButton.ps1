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

        .EXAMPLE
            New-PSUConfigAddUserButton -SyncElementId 'usersRegion'

            Renders the add-user action and refreshes usersRegion after submission.
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
        $SyncElementId = 'psuConfigUsersRegion'
    )

    $resolvedSyncElementId = $SyncElementId
    $Page:PSUConfigAddUserButtonSyncElementId = $resolvedSyncElementId

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
                        New-UDCard -Title 'Add PSUConfig user' -Content {
                            $formParameters = @{
                                FormId        = 'addPSUConfigUserForm'
                                SyncElementId = $Page:PSUConfigAddUserButtonSyncElementId
                                Confirm       = $false
                            }

                            New-PSUConfigUserForm @formParameters
                        }
                    } -Footer {
                        New-UDButton -Text 'Cancel' -OnClick {
                            Hide-UDModal
                        }
                    }
                }
            }

            New-UDFloatingActionButton @buttonParameters
        } -TooltipContent {
            New-UDTypography -Text 'Add PSUConfig user' -Variant body1
        } -FollowCursor -LeaveDelay 5000
    }
}
