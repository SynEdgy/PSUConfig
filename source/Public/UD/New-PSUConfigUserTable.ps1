function New-PSUConfigUserTable
{
    <#
        .SYNOPSIS
            Creates a Universal Dashboard table for PSUConfig user records.

        .DESCRIPTION
            Loads PSUConfig user records through Get-PSUConfigUser and renders a
            searchable, paginated Universal Dashboard table with identity and
            record timestamp columns. Edit and remove actions use validated modal
            workflows and refresh the configured dashboard element. Database errors
            are rendered as an alert.

        .PARAMETER Id
            Specifies the dashboard element identifier assigned to the rendered table.

        .PARAMETER Title
            Specifies the title displayed above the PSUConfig user table.

        .PARAMETER PageSize
            Specifies the number of PSUConfig user records displayed on each table page.

        .PARAMETER SyncElementId
            Specifies the dashboard element refreshed after editing or removing a user.

        .EXAMPLE
            New-PSUConfigUserTable -Id 'psuConfigUsers' -PageSize 20

            Renders a searchable PSUConfig user table showing twenty records per page.
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
        $Id = 'psuConfigUserTable',

        [Parameter()]
        [System.String]
        $Title = 'Internal users',

        [Parameter()]
        [ValidateRange(1, 100)]
        [System.Int32]
        $PageSize = 10,

        [Parameter()]
        [System.String]
        $SyncElementId = 'psuConfigUsersRegion'
    )

    if ($PSCmdlet.ShouldProcess($Id, 'Render PSUConfig user table'))
    {
        try
        {
            $resolvedSyncElementId = $SyncElementId
            $users = @(
                Get-PSUConfigUser |
                    Sort-Object -Property username |
                    Select-Object -Property *, @{
                        Name       = '_syncElementId'
                        Expression = { $resolvedSyncElementId }
                    }
            )
            $columns = @(
                New-UDTableColumn -Property id -Title 'ID' -Width 70 -IncludeInSearch
                New-UDTableColumn -Property firstName -Title 'First name' -IncludeInSearch
                New-UDTableColumn -Property lastName -Title 'Last name' -IncludeInSearch
                New-UDTableColumn -Property username -Title 'Username' -IncludeInSearch
                New-UDTableColumn -Property uid -Title 'UID' -IncludeInSearch
                New-UDTableColumn -Property email -Title 'Email' -IncludeInSearch
                New-UDTableColumn -Property createdOn -Title 'Created' -IncludeInSearch
                New-UDTableColumn -Property updatedOn -Title 'Updated' -IncludeInSearch
                New-UDTableColumn -Property edit -Title 'Edit' -Render {
                    $editButtonParameters = @{
                        Id      = 'editPSUConfigUser-{0}' -f $EventData.id
                        Text    = 'Edit'
                        Variant = 'outlined'
                        Color   = 'primary'
                        Icon    = New-UDIcon -Icon Pen
                        OnClick = {
                            Show-UDModal -Content {
                                New-UDCard -Title 'Edit PSUConfig user' -Content {
                                    $formParameters = @{
                                        FormId        = 'editPSUConfigUserForm'
                                        SyncElementId = [System.String]$EventData._syncElementId
                                        UserId        = [System.Int64]$EventData.id
                                        FirstName     = [System.String]$EventData.firstName
                                        LastName      = [System.String]$EventData.lastName
                                        Username      = [System.String]$EventData.username
                                        Email         = [System.String]$EventData.email
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

                    New-UDButton @editButtonParameters
                }
                New-UDTableColumn -Property remove -Title 'Remove' -Render {
                    $removeButtonParameters = @{
                        Id      = 'removePSUConfigUser-{0}' -f $EventData.id
                        Text    = 'Remove'
                        Variant = 'outlined'
                        Color   = 'error'
                        Icon    = New-UDIcon -Icon Trash
                        OnClick = {
                            Show-UDModal -Content {
                                New-UDTypography -Text ('Remove user {0} ({1})?' -f $EventData.username, $EventData.id) -Variant h6
                                New-UDTypography -Text 'This permanently deletes the selected database row.' -Variant body1
                            } -Footer {
                                New-UDButton -Text 'Cancel' -OnClick {
                                    Hide-UDModal
                                }

                                New-UDButton -Text 'Remove user' -Color error -OnClick {
                                    try
                                    {
                                        $userId = [System.Int64]$EventData.id
                                        $username = [System.String]$EventData.username
                                        Remove-PSUConfigUser -id $userId -Confirm:$false
                                        Hide-UDModal

                                        $toastParameters = @{
                                            BackgroundColor = 'Green'
                                            MessageColor    = 'White'
                                            Message         = 'User {0} removed.' -f $username
                                            Duration        = 3000
                                            Position        = 'TopCenter'
                                        }

                                        Show-UDToast @toastParameters
                                        Sync-UDElement -Id $EventData._syncElementId
                                    }
                                    catch
                                    {
                                        $toastParameters = @{
                                            BackgroundColor = 'Red'
                                            MessageColor    = 'White'
                                            Message         = $_.Exception.Message
                                            Duration        = 5000
                                            Position        = 'TopCenter'
                                        }

                                        Show-UDToast @toastParameters
                                    }
                                }
                            }
                        }
                    }

                    New-UDButton @removeButtonParameters
                }
            )
            $tableParameters = @{
                Id             = $Id
                Title          = $Title
                Data           = $users
                Columns        = $columns
                Dense          = $true
                ShowSearch     = $true
                ShowPagination = $true
                PageSize       = $PageSize
                RemoveCard     = $true
            }

            New-UDTable @tableParameters
        }
        catch
        {
            New-UDAlert -Severity error -Text $_.Exception.Message
        }
    }
}
