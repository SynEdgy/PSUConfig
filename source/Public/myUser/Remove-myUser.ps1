function Remove-myUser
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [Int64]
        $id
    )

    $removePSSqliteRowParams = @{
        SqliteDBConfig = (Get-myModuleConfig)
        TableName = 'myUser'
        ClauseData = @{
            id = $id
        }
        Verbose = $Verbose.IsPresent -or $VerbosePreference -in @('Continue', 'Inquire')
    }

    Remove-PSSqliteRow @removePSSqliteRowParams
}
