function New-myUser
{
    <#
        .SYNOPSIS
            Creates a user record in the PSUConfig SQLite database.

        .DESCRIPTION
            Inserts a new row into the myUser table with the supplied identity
            properties and records the current date and time as the creation value.

        .PARAMETER FirstName
            Specifies the first name to store in the newly created user record.

        .PARAMETER LastName
            Specifies the last name to store in the newly created user record.

        .PARAMETER Username
            Specifies the unique login or display username stored for the new user.

        .PARAMETER Email
            Specifies the email address to store in the newly created user record.

        .EXAMPLE
            New-myUser -FirstName 'Ada' -LastName 'Lovelace' -Username 'ada' -Email 'ada@example.com'

            Creates and returns a new user record when the operation is confirmed.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [APIEndpoint(
        Name = 'newmyUser',
        Path = '/myUser',
        Description = 'New myUser records from the local database.',
        Method = 'POST',
        Authentication = $false,
        Role = ('admin','user'),
        Timeout = 30
    )]
    [AiTool(
        Description = 'Creates a new user in the PSUConfig database'
    )]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $FirstName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $LastName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Username,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Email
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

    $PSBoundParameters['createdOn'] = Get-Date
    $insertPSSqliteRowParameters = @{
        SqliteDBConfig = (Get-myModuleConfig)
        TableName      = 'myUser'
        RowData        = $PSBoundParameters
        Verbose        = $Verbose.IsPresent -or $VerbosePreference -in @('Continue', 'Inquire')
    }

    if ($PSCmdlet.ShouldProcess($Username, 'Create myUser record'))
    {
        New-PSSqliteRow @insertPSSqliteRowParameters
    }
}
