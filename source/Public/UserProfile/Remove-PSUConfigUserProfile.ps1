function Remove-PSUConfigUserProfile
{
    <#
        .SYNOPSIS
            Removes a cached monitoring owner profile.

        .DESCRIPTION
            Deletes exactly one userProfile row identified by its required
            external directory identifier after destructive-operation confirmation.

        .PARAMETER Id
            Specifies the profile identifier to remove.

        .EXAMPLE
            Remove-PSUConfigUserProfile -Id 13 -Confirm:$false

            Removes the cached owner profile with identifier 13.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Int32]
        $Id
    )

    if ($PSCmdlet.ShouldProcess([System.String]$Id, 'Remove monitoring owner profile'))
    {
        $removeRowParameters = @{
            SqliteDBConfig = Get-PSUConfigDatabaseConfiguration
            TableName      = 'userProfile'
            ClauseData     = @{ id = $Id }
            Verbose        = $Verbose.IsPresent -or $VerbosePreference -in @('Continue', 'Inquire')
        }
        Remove-PSSqliteRow @removeRowParameters
    }
}
