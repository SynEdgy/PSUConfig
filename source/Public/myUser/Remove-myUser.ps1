function Remove-myUser
{
    <#
        .SYNOPSIS
            Removes a user record from the PSUConfig SQLite database.

        .DESCRIPTION
            Deletes the myUser table row identified by the supplied record identifier
            after PowerShell confirms that the destructive operation should proceed.

        .PARAMETER id
            Specifies the database identifier of the user record that will be removed.

        .EXAMPLE
            Remove-myUser -id 42 -Confirm:$false

            Removes the user record with identifier 42 without an interactive prompt.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Int64]
        $id
    )

    $removePSSqliteRowParameters = @{
        SqliteDBConfig = (Get-myModuleConfig)
        TableName      = 'myUser'
        ClauseData     = @{
            id = $id
        }
        Verbose        = $Verbose.IsPresent -or $VerbosePreference -in @('Continue', 'Inquire')
    }

    if ($PSCmdlet.ShouldProcess([System.String]$id, 'Remove myUser record'))
    {
        Remove-PSSqliteRow @removePSSqliteRowParameters
    }
}
