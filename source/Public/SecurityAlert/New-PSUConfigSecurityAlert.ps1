function New-PSUConfigSecurityAlert
{
    <#
        .SYNOPSIS
            Creates a monitoring security alert.

        .DESCRIPTION
            Inserts a normalized securityAlert row with workflow status, machine
            state, and generated creation and modification timestamps.

        .PARAMETER VulnerabilityId
            Specifies the vulnerability identifier.

        .PARAMETER Severity
            Specifies the alert severity.

        .PARAMETER SoftwareName
            Specifies the affected software.

        .PARAMETER AffectedBeforeVersion
            Specifies the first non-vulnerable version.

        .PARAMETER MachineId
            Specifies the inventory machine identifier.

        .PARAMETER ComputerName
            Specifies the affected computer name.

        .PARAMETER OwnerId
            Specifies the optional directory owner identifier.

        .PARAMETER MachineOnline
            Specifies whether the computer is currently online.

        .PARAMETER Status
            Specifies the initial workflow status.

        .EXAMPLE
            New-PSUConfigSecurityAlert -VulnerabilityId CVE-TEST -Severity Critical -SoftwareName SecureConnect -AffectedBeforeVersion 5.4 -MachineId LT-1001 -ComputerName CH-GVA-LT1001 -MachineOnline $true

            Creates a detected security alert for the supplied computer.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $VulnerabilityId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Severity,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SoftwareName,

        [Parameter(Mandatory = $true)]
        [System.String]
        $AffectedBeforeVersion,

        [Parameter(Mandatory = $true)]
        [System.String]
        $MachineId,

        [Parameter(Mandatory = $true)]
        [System.String]
        $ComputerName,

        [Parameter()]
        [System.Nullable[System.Int32]]
        $OwnerId,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $MachineOnline,

        [Parameter()]
        [ValidateSet('Detected', 'Investigating', 'Fixing', 'Completed', 'Deferred')]
        [System.String]
        $Status = 'Detected'
    )

    if ($PSCmdlet.ShouldProcess($ComputerName, 'Create monitoring security alert'))
    {
        $now = [System.DateTime]::UtcNow.ToString('o')
        $newRowParameters = @{
            SqliteDBConfig = Get-PSUConfigDatabaseConfiguration
            TableName      = 'securityAlert'
            RowData        = @{
                vulnerabilityId       = $VulnerabilityId
                severity              = $Severity
                softwareName          = $SoftwareName
                affectedBeforeVersion = $AffectedBeforeVersion
                machineId             = $MachineId
                computerName          = $ComputerName
                ownerId               = $OwnerId
                machineOnline         = [System.Int32]$MachineOnline
                status                = $Status
                createdOn             = $now
                updatedOn             = $now
            }
            Verbose        = $Verbose.IsPresent -or $VerbosePreference -in @('Continue', 'Inquire')
        }
        New-PSSqliteRow @newRowParameters
    }
}
