function Remove-PSUConfigSecurityAlert
{
    <#
        .SYNOPSIS
            Removes a monitoring security alert.

        .DESCRIPTION
            Deletes exactly one securityAlert row identified by its required
            database identifier after destructive-operation confirmation.

        .PARAMETER Id
            Specifies the alert database identifier to remove.

        .EXAMPLE
            Remove-PSUConfigSecurityAlert -Id 7 -Confirm:$false

            Removes security alert 7 without an interactive prompt.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Int64]
        $Id
    )

    if ($PSCmdlet.ShouldProcess([System.String]$Id, 'Remove monitoring security alert'))
    {
        $removeRowParameters = @{
            SqliteDBConfig = Get-PSUConfigDatabaseConfiguration
            TableName      = 'securityAlert'
            ClauseData     = @{ id = $Id }
            Verbose        = $Verbose.IsPresent -or $VerbosePreference -in @('Continue', 'Inquire')
        }
        Remove-PSSqliteRow @removeRowParameters
    }
}
