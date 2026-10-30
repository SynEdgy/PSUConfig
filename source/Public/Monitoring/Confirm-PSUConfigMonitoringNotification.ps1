function Confirm-PSUConfigMonitoringNotification
{
    <#
        .SYNOPSIS
            Acknowledges the active monitoring notification.

        .DESCRIPTION
            Clears the held AWTRIX notification and transitions any detected
            security alerts to investigating without changing completed alerts.

        .EXAMPLE
            Confirm-PSUConfigMonitoringNotification -Confirm:$false

            Clears the active clock notification and acknowledges detected alerts.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param ()

    $device = Get-PSUConfigAwtrixDevice
    if (-not $PSCmdlet.ShouldProcess($device, 'Acknowledge active AWTRIX notification'))
    {
        return
    }

    $null = Remove-AwtrixNotification -Device $device -Confirm:$false -ErrorAction Stop

    $alerts = @(Get-PSUConfigSecurityAlert -Status Detected)
    foreach ($alert in $alerts)
    {
        Set-PSUConfigSecurityAlert -Id $alert.id -Status Investigating -Confirm:$false
    }

    [pscustomobject]@{
        Device            = $device
        Status            = 'Acknowledged'
        UpdatedAlertCount = $alerts.Count
    }
}
