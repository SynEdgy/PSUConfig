function Get-PSUConfigUserProfile
{
    <#
        .SYNOPSIS
            Gets cached monitoring owner profiles.

        .DESCRIPTION
            Queries PSUConfig's userProfile table with optional exact, wildcard,
            and synchronization date-range filters for discovered machine owners.

        .PARAMETER Id
            Filters profiles by directory identifier.

        .PARAMETER FirstName
            Filters profiles by first name.

        .PARAMETER LastName
            Filters profiles by last name.

        .PARAMETER DisplayName
            Filters profiles by display name.

        .PARAMETER Email
            Filters profiles by email address.

        .PARAMETER Department
            Filters profiles by department.

        .PARAMETER Title
            Filters profiles by job title.

        .PARAMETER SyncedOnBefore
            Returns profiles synchronized before this timestamp.

        .PARAMETER SyncedOnAfter
            Returns profiles synchronized after this timestamp.

        .PARAMETER SqliteDBConfig
            Supplies the internal SQLite configuration used to query the profile
            table. This implementation parameter is hidden from interactive and
            generated API endpoint consumers.

        .EXAMPLE
            Get-PSUConfigUserProfile -Department 'Engineering' -DisplayName 'Noah*'

            Returns matching cached monitoring owner profiles.
    #>
    [CmdletBinding()]
    [APIEndpoint(
        Name = 'getPSUConfigUserProfile',
        Path = '/userProfile',
        Description = 'Get cached monitoring owner profiles from the PSUConfig database.',
        Method = 'GET',
        Authentication = $false,
        Role = ('admin','user'),
        Tag = 'Monitoring',
        Timeout = 30
    )]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter()]
        [System.Int32]
        $Id,

        [Parameter()]
        [System.String]
        $FirstName,

        [Parameter()]
        [System.String]
        $LastName,

        [Parameter()]
        [System.String]
        $DisplayName,

        [Parameter()]
        [System.String]
        $Email,

        [Parameter()]
        [System.String]
        $Department,

        [Parameter()]
        [System.String]
        $Title,

        [Parameter()]
        [System.DateTime]
        $SyncedOnBefore,

        [Parameter()]
        [System.DateTime]
        $SyncedOnAfter,

        [Parameter(DontShow)]
        [synedgy.PSSqlite.SqliteDBConfig]
        $SqliteDBConfig = (Get-PSUConfigDatabaseConfiguration)
    )

    $null = $PSBoundParameters.Remove('SqliteDBConfig')
    @(
        [System.Management.Automation.PSCmdlet]::CommonParameters +
            [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
    ).ForEach{
        if ($PSBoundParameters.ContainsKey($_))
        {
            $null = $PSBoundParameters.Remove($_)
        }
    }

    $getRowParameters = @{
        SqliteDBConfig = $SqliteDBConfig
        TableName      = 'userProfile'
        ClauseData     = $PSBoundParameters
        Verbose        = $Verbose.IsPresent -or $VerbosePreference -in @('Continue', 'Inquire')
    }
    Get-PSSqliteRow @getRowParameters
}
