function Set-PSUConfigUserProfile
{
    <#
        .SYNOPSIS
            Upserts a cached monitoring owner profile.

        .DESCRIPTION
            Replaces the complete mutable owner profile when its directory
            identifier exists, or creates the profile when it is first discovered.

        .PARAMETER Id
            Specifies the external directory identifier.

        .PARAMETER FirstName
            Specifies the owner's current first name.

        .PARAMETER LastName
            Specifies the owner's current last name.

        .PARAMETER Email
            Specifies the owner's current email address.

        .PARAMETER Department
            Specifies the owner's current department.

        .PARAMETER Title
            Specifies the owner's current job title.

        .EXAMPLE
            Set-PSUConfigUserProfile -Id 13 -FirstName Noah -LastName Hernandez -Email noah@example.test

            Creates or refreshes the cached owner profile.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Int32]
        $Id,

        [Parameter(Mandatory = $true)]
        [System.String]
        $FirstName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $LastName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Email,

        [Parameter()]
        [System.String]
        $Department,

        [Parameter()]
        [System.String]
        $Title
    )

    if ($PSCmdlet.ShouldProcess([System.String]$Id, 'Upsert monitoring owner profile'))
    {
        $rowData = @{
            firstName   = $FirstName
            lastName    = $LastName
            displayName = '{0} {1}' -f $FirstName, $LastName
            email       = $Email
            department  = $Department
            title       = $Title
            syncedOn    = [System.DateTime]::UtcNow.ToString('o')
        }

        if (@(Get-PSUConfigUserProfile -Id $Id).Count -gt 0)
        {
            $setRowParameters = @{
                SqliteDBConfig = Get-PSUConfigDatabaseConfiguration
                TableName      = 'userProfile'
                RowData        = $rowData
                ClauseData     = @{ id = $Id }
                Verbose        = $Verbose.IsPresent -or $VerbosePreference -in @('Continue', 'Inquire')
            }
            Set-PSSqliteRow @setRowParameters
        }
        else
        {
            $newProfileParameters = @{
                Id         = $Id
                FirstName  = $FirstName
                LastName   = $LastName
                Email      = $Email
                Department = $Department
                Title      = $Title
                Confirm    = $false
            }
            New-PSUConfigUserProfile @newProfileParameters
        }
    }
}
