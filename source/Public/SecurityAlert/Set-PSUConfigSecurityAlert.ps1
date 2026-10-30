function Set-PSUConfigSecurityAlert
{
    <#
        .SYNOPSIS
            Updates a monitoring security alert.

        .DESCRIPTION
            Updates only the supplied mutable fields on one securityAlert row and
            records a new modification timestamp for the workflow transition.

        .PARAMETER Id
            Specifies the alert database identifier.

        .PARAMETER Status
            Specifies the replacement workflow status.

        .PARAMETER PsuJobId
            Specifies the associated PowerShell Universal job identifier.

        .PARAMETER MachineOnline
            Specifies the refreshed online state.

        .EXAMPLE
            Set-PSUConfigSecurityAlert -Id 7 -Status Fixing -PsuJobId 42

            Marks alert 7 as fixing and associates job 42.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [OutputType([System.Object])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Int64]
        $Id,

        [Parameter()]
        [ValidateSet('Detected', 'Investigating', 'Fixing', 'Completed', 'Deferred')]
        [System.String]
        $Status,

        [Parameter()]
        [System.String]
        $PsuJobId,

        [Parameter()]
        [System.Nullable[System.Boolean]]
        $MachineOnline
    )

    $rowData = @{}
    if ($PSBoundParameters.ContainsKey('Status'))
    {
        $rowData.status = $Status
    }
    if ($PSBoundParameters.ContainsKey('PsuJobId'))
    {
        $rowData.psuJobId = $PsuJobId
    }
    if ($PSBoundParameters.ContainsKey('MachineOnline'))
    {
        $rowData.machineOnline = [System.Int32][System.Boolean]$MachineOnline
    }
    if ($rowData.Count -eq 0)
    {
        throw 'At least one mutable alert value must be supplied.'
    }
    $rowData.updatedOn = [System.DateTime]::UtcNow.ToString('o')

    if ($PSCmdlet.ShouldProcess([System.String]$Id, 'Update monitoring security alert'))
    {
        $setRowParameters = @{
            SqliteDBConfig = Get-PSUConfigDatabaseConfiguration
            TableName      = 'securityAlert'
            RowData        = $rowData
            ClauseData     = @{ id = $Id }
            Verbose        = $Verbose.IsPresent -or $VerbosePreference -in @('Continue', 'Inquire')
        }
        Set-PSSqliteRow @setRowParameters
    }
}
