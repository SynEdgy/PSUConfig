function Set-PSUConfigUser
{
    <#
        .SYNOPSIS
            Updates a user record in the PSUConfig SQLite database.

        .DESCRIPTION
            Updates the supplied fields on a single psuConfigUser table row and records the
            current date and time as the row's latest modification timestamp.

        .PARAMETER id
            Specifies the database identifier of the user record that will be updated.

        .PARAMETER FirstName
            Specifies the replacement first name when that field should be updated.

        .PARAMETER LastName
            Specifies the replacement last name when that field should be updated.

        .PARAMETER Username
            Specifies the replacement username when that field should be updated.

        .PARAMETER Email
            Specifies the replacement email address when that field should be updated.

        .EXAMPLE
            Set-PSUConfigUser -id 42 -Email 'ada@example.com' -Confirm:$false

            Updates the email address and modification timestamp for user record 42.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [APIEndpoint(
        Name = 'setPSUConfigUser',
        Path = '/psuConfigUser',
        Description = 'Update a PSUConfig user record in the local database.',
        Method = 'PUT',
        Authentication = $false,
        Role = ('admin','user'),
        Tag = 'Users',
        Timeout = 30
    )]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Int64]
        $id,

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

    $PSBoundParameters['updatedOn'] = Get-Date
    @(
        [System.Management.Automation.PSCmdlet]::CommonParameters +
            [System.Management.Automation.PSCmdlet]::OptionalCommonParameters
    ).ForEach{
        if ($PSBoundParameters.ContainsKey($_))
        {
            $null = $PSBoundParameters.Remove($_)
        }
    }

    $null = $PSBoundParameters.Remove('id')
    $updatePSSqliteRowParameters = @{
        SqliteDBConfig = (Get-PSUConfigDatabaseConfiguration)
        TableName      = 'psuConfigUser'
        RowData        = $PSBoundParameters
        ClauseData     = @{
            id = $id
        }
        Verbose        = $Verbose.IsPresent -or $VerbosePreference -in @('Continue', 'Inquire')
    }

    if ($PSCmdlet.ShouldProcess([System.String]$id, 'Update PSUConfig user record'))
    {
        Set-PSSqliteRow @updatePSSqliteRowParameters
    }
}
