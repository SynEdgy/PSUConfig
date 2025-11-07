function Get-myUser
{
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
    param
    (
        [Parameter()]
        [string]
        $id,

        [Parameter()]
        [string]
        $firstName,

        [Parameter()]
        [string]
        $lastName,

        [Parameter()]
        [string]
        $username,

        [Parameter()]
        [string]
        $uid,

        [Parameter()]
        [string]
        $email,

        [Parameter()]
        [datetime]
        $createdOnBefore,

        [Parameter()]
        [datetime]
        $createdOnAfter,

        [Parameter()]
        [datetime]
        $updatedOnBefore,

        [Parameter()]
        [datetime]
        $updatedOnAfter
    )

    @([System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters).ForEach{
        if ($PSBoundParameters.ContainsKey($_))
        {
            $null = $PSBoundParameters.Remove($_)
        }
    }

    $getPSSqliteRowParams = @{
        SqliteDBConfig = (Get-myModuleConfig)
        TableName = 'myUser'
        ClauseData = $PSBoundParameters
        verbose = $Verbose.IsPresent -or $VerbosePreference -in @('Continue', 'Inquire')
    }

    Get-PSSqliteRow @getPSSqliteRowParams
}
