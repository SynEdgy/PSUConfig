function Set-myUser
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Int64]
        $id,

        [Parameter()]
        [string]
        $FirstName,

        [Parameter()]
        [string]
        $LastName,

        [Parameter()]
        [string]
        $Username,

        [Parameter()]
        [string]
        $Email
    )

    $PSBoundParameters['updatedOn'] = (Get-Date)
    @([System.Management.Automation.PSCmdlet]::CommonParameters + [System.Management.Automation.PSCmdlet]::OptionalCommonParameters).ForEach{
        if ($PSBoundParameters.ContainsKey($_))
        {
            $null = $PSBoundParameters.Remove($_)
        }
    }

    $null = $PSBoundParameters.Remove('id')

    $updatePSSqliteRowParams = @{
        SqliteDBConfig = (Get-myModuleConfig)
        TableName = 'myUser'
        RowData = $PSBoundParameters
        ClauseData = @{
            id = $id
        }
        Verbose = $Verbose.IsPresent -or $VerbosePreference -in @('Continue', 'Inquire')
    }

    Set-PSSqliteRow @updatePSSqliteRowParams
}
