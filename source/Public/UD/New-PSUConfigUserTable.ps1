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

        .PARAMETER Language
            Specifies the requested language for the component-owned
            PSUConfig.UserTable localization resource.

        .EXAMPLE
            New-PSUConfigUserTable -Id 'psuConfigUsers' -PageSize 20 -Language 'fr'

            Renders a localized searchable PSUConfig user table showing twenty
            records per page.
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
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Title,

        [Parameter()]
        [ValidateRange(1, 100)]
        [System.Int32]
        $PageSize = 10,

        [Parameter()]
        [System.String]
        $SyncElementId = 'psuConfigUsersRegion',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Language
    )

    $psuConfigUserTableStringsParameters = @{
        Name              = 'PSUConfig.UserTable'
        Language          = $Language
        DefaultUILanguage = (Get-PSUConfigSetting).DefaultUILanguage
        Cache             = $Cache:PSUConfigLocalization
    }
    $psuConfigUserTableStrings = Get-PSUComponentLocalizedData @psuConfigUserTableStringsParameters
    $Page:PSUConfigUserTableStrings = $psuConfigUserTableStrings
    $Page:PSUConfigUserTableLanguage = $Language
    # 'Internal users'
    $resolvedTitle = if ($PSBoundParameters.ContainsKey('Title')) { $Title } else { $psuConfigUserTableStrings.TableTitle }

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
                # 'ID'
                New-UDTableColumn -Property id -Title $psuConfigUserTableStrings.IdColumn -Width 70 -IncludeInSearch
                # 'First name'
                New-UDTableColumn -Property firstName -Title $psuConfigUserTableStrings.FirstNameColumn -IncludeInSearch
                # 'Last name'
                New-UDTableColumn -Property lastName -Title $psuConfigUserTableStrings.LastNameColumn -IncludeInSearch
                # 'Username'
                New-UDTableColumn -Property username -Title $psuConfigUserTableStrings.UsernameColumn -IncludeInSearch
                # 'UID'
                New-UDTableColumn -Property uid -Title $psuConfigUserTableStrings.UidColumn -IncludeInSearch
                # 'Email'
                New-UDTableColumn -Property email -Title $psuConfigUserTableStrings.EmailColumn -IncludeInSearch
                # 'Created'
                New-UDTableColumn -Property createdOn -Title $psuConfigUserTableStrings.CreatedColumn -IncludeInSearch
                # 'Updated'
                New-UDTableColumn -Property updatedOn -Title $psuConfigUserTableStrings.UpdatedColumn -IncludeInSearch
                # 'Edit'
                New-UDTableColumn -Property edit -Title $psuConfigUserTableStrings.EditColumn -Render {
                    $editButtonParameters = @{
                        Id      = 'editPSUConfigUser-{0}' -f $EventData.id
                        # 'Edit'
                        Text    = $Page:PSUConfigUserTableStrings.EditButton
                        Variant = 'outlined'
                        Color   = 'primary'
                        Icon    = New-UDIcon -Icon Pen
                        OnClick = {
                            Show-UDModal -Content {
                                # 'Edit PSUConfig user'
                                New-UDCard -Title $Page:PSUConfigUserTableStrings.EditModalTitle -Content {
                                    $formParameters = @{
                                        FormId        = 'editPSUConfigUserForm'
                                        SyncElementId = [System.String]$EventData._syncElementId
                                        UserId        = [System.Int64]$EventData.id
                                        FirstName     = [System.String]$EventData.firstName
                                        LastName      = [System.String]$EventData.lastName
                                        Username      = [System.String]$EventData.username
                                        Email         = [System.String]$EventData.email
                                        Language      = $Page:PSUConfigUserTableLanguage
                                        Confirm       = $false
                                    }

                                    New-PSUConfigUserForm @formParameters
                                }
                            } -Footer {
                                # 'Cancel'
                                New-UDButton -Text $Page:PSUConfigUserTableStrings.Cancel -OnClick {
                                    Hide-UDModal
                                }
                            }
                        }
                    }

                    New-UDButton @editButtonParameters
                }
                # 'Remove'
                New-UDTableColumn -Property remove -Title $psuConfigUserTableStrings.RemoveColumn -Render {
                    $removeButtonParameters = @{
                        Id      = 'removePSUConfigUser-{0}' -f $EventData.id
                        # 'Remove'
                        Text    = $Page:PSUConfigUserTableStrings.RemoveButton
                        Variant = 'outlined'
                        Color   = 'error'
                        Icon    = New-UDIcon -Icon Trash
                        OnClick = {
                            Show-UDModal -Content {
                                # 'Remove user {0} ({1})?'
                                New-UDTypography -Text ($Page:PSUConfigUserTableStrings.RemovePrompt -f $EventData.username, $EventData.id) -Variant h6
                                # 'This permanently deletes the selected database row.'
                                New-UDTypography -Text $Page:PSUConfigUserTableStrings.RemoveWarning -Variant body1
                            } -Footer {
                                # 'Cancel'
                                New-UDButton -Text $Page:PSUConfigUserTableStrings.Cancel -OnClick {
                                    Hide-UDModal
                                }

                                # 'Remove user'
                                New-UDButton -Text $Page:PSUConfigUserTableStrings.RemoveConfirm -Color error -OnClick {
                                    try
                                    {
                                        $userId = [System.Int64]$EventData.id
                                        $username = [System.String]$EventData.username
                                        Remove-PSUConfigUser -id $userId -Confirm:$false
                                        Hide-UDModal

                                        $toastParameters = @{
                                            BackgroundColor = 'Green'
                                            MessageColor    = 'White'
                                            # 'User {0} removed.'
                                            Message         = $Page:PSUConfigUserTableStrings.UserRemovedMessage -f $username
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
                Title          = $resolvedTitle
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
