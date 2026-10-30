function Remove-PSUConfigMonitoringFinding
{
    <#
        .SYNOPSIS
            Removes a persisted monitoring finding summary.

        .DESCRIPTION
            Deletes every securityAlert row for one computer so the monitoring
            workflow can be demonstrated again without changing the bundled
            machine inventory.

        .PARAMETER ComputerName
            Specifies the computer whose persisted alert summaries are removed.

        .EXAMPLE
            Remove-PSUConfigMonitoringFinding -ComputerName CH-GVA-LT1001 -Confirm:$false

            Clears the persisted finding summary for CH-GVA-LT1001 while
            preserving the monitoring inventory.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ComputerName
    )

    $alerts = @(Get-PSUConfigSecurityAlert -ComputerName $ComputerName)

    if (-not $PSCmdlet.ShouldProcess($ComputerName, 'Remove persisted monitoring finding summary'))
    {
        return
    }

    foreach ($alert in $alerts)
    {
        Remove-PSUConfigSecurityAlert -Id $alert.id -Confirm:$false
    }

    [pscustomobject]@{
        ComputerName      = $ComputerName
        RemovedAlertCount = $alerts.Count
    }
}
