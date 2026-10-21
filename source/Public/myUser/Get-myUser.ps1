function Get-myUser
{
    <#
        .SYNOPSIS
            Gets user records from the PSUConfig SQLite database.

        .DESCRIPTION
            Queries the myUser table with optional exact, wildcard, and date-range
            filters and returns every database row matching the supplied criteria.

        .PARAMETER id
            Filters results by the stored numeric or textual user record identifier.

        .PARAMETER firstName
            Filters results by first name and supports PSSqlite wildcard matching.

        .PARAMETER lastName
            Filters results by last name and supports PSSqlite wildcard matching.

        .PARAMETER username
            Filters results by the stored username and supports wildcard matching.

        .PARAMETER uid
            Filters results by the external unique identifier stored for the user.

        .PARAMETER email
            Filters results by email address and supports PSSqlite wildcard matching.

        .PARAMETER createdOnBefore
            Returns records created before the supplied date and time boundary.

        .PARAMETER createdOnAfter
            Returns records created after the supplied date and time boundary.

        .PARAMETER updatedOnBefore
            Returns records updated before the supplied date and time boundary.

        .PARAMETER updatedOnAfter
            Returns records updated after the supplied date and time boundary.

        .EXAMPLE
            Get-myUser -username 'ada*'

            Returns user records whose username begins with the supplied text.
    #>
    [CmdletBinding()]
    [APIEndpoint(
        Name = 'getmyUser',
        Path = '/myUser',
        Description = 'Get myUser records from the local database.',
        Method = 'GET',
        Authentication = $false,
        Role = ('admin','user'),
        Timeout = 30
    )]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter()]
        [System.String]
        $id,

        [Parameter()]
        [System.String]
        $firstName,

        [Parameter()]
        [System.String]
        $lastName,

        [Parameter()]
        [System.String]
        $username,

        [Parameter()]
        [System.String]
        $uid,

        [Parameter()]
        [System.String]
        $email,

        [Parameter()]
        [System.DateTime]
        $createdOnBefore,

        [Parameter()]
        [System.DateTime]
        $createdOnAfter,

        [Parameter()]
        [System.DateTime]
        $updatedOnBefore,

        [Parameter()]
        [System.DateTime]
        $updatedOnAfter
    )

    @(
        [System.Management.Automation.PSCmdlet]::CommonParameters +
            [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
    ).ForEach{
        if ($PSBoundParameters.ContainsKey($_))
        {
            $null = $PSBoundParameters.Remove($_)
        }
    }

    $getPSSqliteRowParameters = @{
        SqliteDBConfig = (Get-PSUConfigDatabaseConfiguration)
        TableName      = 'myUser'
        ClauseData     = $PSBoundParameters
        Verbose        = $Verbose.IsPresent -or $VerbosePreference -in @('Continue', 'Inquire')
    }

    Get-PSSqliteRow @getPSSqliteRowParameters
}
