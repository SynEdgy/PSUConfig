function New-PSUConfigUserProfile
{
    <#
        .SYNOPSIS
            Creates a cached monitoring owner profile.

        .DESCRIPTION
            Inserts a directory owner into the userProfile table with a derived
            display name and generated synchronization timestamp.

        .PARAMETER Id
            Specifies the external directory identifier.

        .PARAMETER FirstName
            Specifies the owner's first name.

        .PARAMETER LastName
            Specifies the owner's last name.

        .PARAMETER Email
            Specifies the owner's email address.

        .PARAMETER Department
            Specifies the owner's department.

        .PARAMETER Title
            Specifies the owner's job title.

        .EXAMPLE
            New-PSUConfigUserProfile -Id 13 -FirstName Noah -LastName Hernandez -Email noah@example.test

            Creates a cached owner profile with a generated display name.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([System.Management.Automation.PSCustomObject])]
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

    if ($PSCmdlet.ShouldProcess([System.String]$Id, 'Create monitoring owner profile'))
    {
        $newRowParameters = @{
            SqliteDBConfig = Get-PSUConfigDatabaseConfiguration
            TableName      = 'userProfile'
            RowData        = @{
                id          = $Id
                firstName   = $FirstName
                lastName    = $LastName
                displayName = '{0} {1}' -f $FirstName, $LastName
                email       = $Email
                department  = $Department
                title       = $Title
                syncedOn    = [System.DateTime]::UtcNow.ToString('o')
            }
            Verbose        = $Verbose.IsPresent -or $VerbosePreference -in @('Continue', 'Inquire')
        }
        New-PSSqliteRow @newRowParameters
    }
}
