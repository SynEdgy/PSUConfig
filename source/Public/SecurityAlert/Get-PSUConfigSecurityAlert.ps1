function Get-PSUConfigSecurityAlert
{
    <#
        .SYNOPSIS
            Gets persisted monitoring security alerts.

        .DESCRIPTION
            Queries PSUConfig's securityAlert table with optional exact, wildcard,
            Boolean, and date-range filters for monitoring workflow records.

        .PARAMETER Id
            Filters alerts by their database identifier.

        .PARAMETER VulnerabilityId
            Filters alerts by vulnerability identifier.

        .PARAMETER Severity
            Filters alerts by severity.

        .PARAMETER SoftwareName
            Filters alerts by affected software name.

        .PARAMETER AffectedBeforeVersion
            Filters alerts by affected version boundary.

        .PARAMETER MachineId
            Filters alerts by inventory machine identifier.

        .PARAMETER ComputerName
            Filters alerts by computer name.

        .PARAMETER OwnerId
            Filters alerts by directory owner identifier.

        .PARAMETER MachineOnline
            Filters alerts by the stored online state.

        .PARAMETER Status
            Filters alerts by workflow status.

        .PARAMETER PsuJobId
            Filters alerts by PowerShell Universal job identifier.

        .PARAMETER CreatedOnBefore
            Returns alerts created before this timestamp.

        .PARAMETER CreatedOnAfter
            Returns alerts created after this timestamp.

        .PARAMETER UpdatedOnBefore
            Returns alerts updated before this timestamp.

        .PARAMETER UpdatedOnAfter
            Returns alerts updated after this timestamp.

        .EXAMPLE
            Get-PSUConfigSecurityAlert -ComputerName 'CH-GVA-*' -Status Detected

            Returns detected alerts for Geneva computers.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter()]
        [System.Int64]
        $Id,

        [Parameter()]
        [System.String]
        $VulnerabilityId,

        [Parameter()]
        [System.String]
        $Severity,

        [Parameter()]
        [System.String]
        $SoftwareName,

        [Parameter()]
        [System.String]
        $AffectedBeforeVersion,

        [Parameter()]
        [System.String]
        $MachineId,

        [Parameter()]
        [System.String]
        $ComputerName,

        [Parameter()]
        [System.Int32]
        $OwnerId,

        [Parameter()]
        [System.Nullable[System.Boolean]]
        $MachineOnline,

        [Parameter()]
        [ValidateSet('Detected', 'Investigating', 'Fixing', 'Completed', 'Deferred')]
        [System.String]
        $Status,

        [Parameter()]
        [System.String]
        $PsuJobId,

        [Parameter()]
        [System.DateTime]
        $CreatedOnBefore,

        [Parameter()]
        [System.DateTime]
        $CreatedOnAfter,

        [Parameter()]
        [System.DateTime]
        $UpdatedOnBefore,

        [Parameter()]
        [System.DateTime]
        $UpdatedOnAfter
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

    if ($PSBoundParameters.ContainsKey('MachineOnline'))
    {
        $PSBoundParameters.MachineOnline = [System.Int32][System.Boolean]$MachineOnline
    }

    $getRowParameters = @{
        SqliteDBConfig = Get-PSUConfigDatabaseConfiguration
        TableName      = 'securityAlert'
        ClauseData     = $PSBoundParameters
        Verbose        = $Verbose.IsPresent -or $VerbosePreference -in @('Continue', 'Inquire')
    }
    Get-PSSqliteRow @getRowParameters
}
