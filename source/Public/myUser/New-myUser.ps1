function New-myUser
{
    [CmdletBinding()]
    [APIEndpoint(
        Name = 'newmyUser',
        Path = '/myUser',
        Description = 'New myUser records from the local database.',
        Method = 'POST',
        Authentication = $false,  #TODO: set to true
        Role = ('admin','user'),
        Timeout = 30
    )]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]
        $FirstName,

        [Parameter(Mandatory = $true)]
        [string]
        $LastName,

        [Parameter(Mandatory = $true)]
        [string]
        $Username,

        [Parameter(Mandatory = $true)]
        [string]
        $Email
    )

    @([System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters).ForEach{
        if ($PSBoundParameters.ContainsKey($_))
        {
            $null = $PSBoundParameters.Remove($_)
        }
    }

    # TODO: Check for existing entry before recreating a new one?
    $PSBoundParameters['createdOn'] = (Get-Date)

    $insertPSSqliteRowParams = @{
        SqliteDBConfig = (Get-myModuleConfig)
        TableName = 'myUser'
        RowData = $PSBoundParameters
        verbose = $Verbose.IsPresent -or $VerbosePreference -in @('Continue', 'Inquire')
    }

    New-PSSqliteRow @insertPSSqliteRowParams
}
