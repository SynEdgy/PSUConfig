function New-PSUConfigUserForm
{
    <#
        .SYNOPSIS
            Creates a Universal Dashboard form for adding or editing a PSUConfig user.

        .DESCRIPTION
            Renders the required PSUConfig user fields. The form creates a database
            record through New-PSUConfigUser when UserId is omitted, or updates the
            selected record through Set-PSUConfigUser when UserId is supplied. After
            a successful submission, the modal closes and the configured dashboard
            element is refreshed.

        .PARAMETER FormId
            Specifies the dashboard element identifier assigned to the form.

        .PARAMETER SyncElementId
            Specifies the dashboard element to refresh after creating a user.

        .PARAMETER UserId
            Specifies the database identifier of the user edited by the form.
            When omitted, the form creates a new user.

        .PARAMETER FirstName
            Specifies the initial first name displayed in edit mode.

        .PARAMETER LastName
            Specifies the initial last name displayed in edit mode.

        .PARAMETER Username
            Specifies the initial username displayed in edit mode.

        .PARAMETER Email
            Specifies the initial email address displayed in edit mode.

        .EXAMPLE
            New-PSUConfigUserForm -FormId 'addUserForm' -SyncElementId 'usersRegion'

            Renders a form that refreshes usersRegion after creating a user.
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
        $FormId = 'addPSUConfigUserForm',

        [Parameter()]
        [System.String]
        $SyncElementId,

        [Parameter()]
        [System.Nullable[System.Int64]]
        $UserId,

        [Parameter()]
        [System.String]
        $FirstName,

        [Parameter()]
        [System.String]
        $LastName,

        [Parameter()]
        [System.String]
        $Username,

        [Parameter()]
        [System.String]
        $Email
    )

    $resolvedSyncElementId = $SyncElementId
    $Page:PSUConfigUserFormSyncElementId = $resolvedSyncElementId
    $Page:PSUConfigUserFormUserId = $UserId
    $isEditMode = $null -ne $UserId
    $formAction = if ($isEditMode) { 'edit' } else { 'create' }
    $resolvedFirstName = $FirstName
    $resolvedLastName = $LastName
    $resolvedUsername = $Username
    $resolvedEmail = $Email

    if ($PSCmdlet.ShouldProcess($FormId, 'Render PSUConfig user form in {0} mode' -f $formAction))
    {
        New-UDForm -Id $FormId -Content {
            New-UDStack -Direction column -Spacing 3 -Children {
                New-UDStack -Direction row -Spacing 2 -Children {
                    New-UDElement -Tag 'div' -Attributes @{
                        style = @{
                            flex     = '1 1 0'
                            minWidth = 0
                        }
                    } -Content {
                        New-UDTextbox -Id 'psuConfigUserFirstName' -Label 'First name' -Placeholder 'Ada' -Value $resolvedFirstName -Shrink
                    }

                    New-UDElement -Tag 'div' -Attributes @{
                        style = @{
                            flex     = '1 1 0'
                            minWidth = 0
                        }
                    } -Content {
                        New-UDTextbox -Id 'psuConfigUserLastName' -Label 'Last name' -Placeholder 'Lovelace' -Value $resolvedLastName -Shrink
                    }
                }

                New-UDTextbox -Id 'psuConfigUsername' -Label 'Username' -Placeholder 'ada' -Value $resolvedUsername -Shrink
                New-UDTextbox -Id 'psuConfigUserEmail' -Label 'Email' -Placeholder 'ada@example.com' -Value $resolvedEmail -Shrink
            }
        } -OnSubmit {
            $firstName = [System.String](Get-UDElement -Id 'psuConfigUserFirstName').Value
            $lastName = [System.String](Get-UDElement -Id 'psuConfigUserLastName').Value
            $username = [System.String](Get-UDElement -Id 'psuConfigUsername').Value
            $email = [System.String](Get-UDElement -Id 'psuConfigUserEmail').Value
            $requiredValues = [ordered]@{
                'First name' = $firstName
                'Last name'  = $lastName
                'Username'   = $username
                'Email'      = $email
            }
            $missingFields = @(
                $requiredValues.GetEnumerator() |
                    Where-Object { [System.String]::IsNullOrWhiteSpace([System.String]$_.Value) } |
                    ForEach-Object { $_.Key }
            )

            if ($missingFields.Count -gt 0)
            {
                $toastParameters = @{
                    BackgroundColor = 'Red'
                    MessageColor    = 'White'
                    Message         = 'Complete the required fields: {0}.' -f ($missingFields -join ', ')
                    Duration        = 5000
                    Position        = 'TopCenter'
                }

                Show-UDToast @toastParameters
                return
            }

            $userParameters = @{
                FirstName = $firstName.Trim()
                LastName  = $lastName.Trim()
                Username  = $username.Trim()
                Email     = $email.Trim()
                Confirm   = $false
            }

            try
            {
                if ($null -ne $Page:PSUConfigUserFormUserId)
                {
                    $userParameters['id'] = [System.Int64]$Page:PSUConfigUserFormUserId
                    $null = Set-PSUConfigUser @userParameters
                    $successMessage = 'User {0} updated.' -f $username.Trim()
                }
                else
                {
                    $null = New-PSUConfigUser @userParameters
                    $successMessage = 'User {0} created.' -f $username.Trim()
                }

                Hide-UDModal

                $toastParameters = @{
                    BackgroundColor = 'Green'
                    MessageColor    = 'White'
                    Message         = $successMessage
                    Duration        = 3000
                    Position        = 'TopCenter'
                }

                Show-UDToast @toastParameters

                if (-not [System.String]::IsNullOrEmpty($Page:PSUConfigUserFormSyncElementId))
                {
                    Sync-UDElement -Id $Page:PSUConfigUserFormSyncElementId
                }
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
