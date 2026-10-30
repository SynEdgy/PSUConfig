function Invoke-PSUConfigMonitoringJob
{
    <#
        .SYNOPSIS
            Runs the background jobs used by the PSUConfig monitoring workflow.

        .DESCRIPTION
            Dispatches vulnerability detection and simulated patch jobs, persists
            their alert state in the PSUConfig database, and writes progress to
            the PowerShell Universal job output stream.

        .PARAMETER JobType
            Selects the alert-detection or fix workflow.

        .PARAMETER DelaySeconds
            Specifies the simulated notification delay for an alert job.

        .PARAMETER TargetComputerName
            Specifies the computer handled by a fix job.

        .PARAMETER AlertId
            Specifies the persisted security-alert identifier for a fix job.

        .EXAMPLE
            Invoke-PSUConfigMonitoringJob -JobType Alert -DelaySeconds 5

            Discovers vulnerable computers and persists alert records.
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param
    (
        [Parameter()]
        [ValidateSet('Alert', 'Fix')]
        [System.String]
        $JobType = 'Alert',

        [Parameter()]
        [ValidateRange(0, 300)]
        [System.Int32]
        $DelaySeconds = 5,

        [Parameter()]
        [System.String]
        $TargetComputerName,

        [Parameter()]
        [System.Int64]
        $AlertId = 0
    )

    Initialize-PSUConfigDB -Confirm:$false

    switch ($JobType)
    {
        'Alert'
        {
            Write-Information 'SecureConnect vulnerability advisory received.' -InformationAction Continue
            Write-Information ("Waiting {0} seconds before notifying operations." -f $DelaySeconds) -InformationAction Continue
            Start-Sleep -Seconds $DelaySeconds

            $vulnerableComputers = @(Get-PSUConfigMonitoringComputer)
            foreach ($computer in $vulnerableComputers)
            {
                $openAlerts = @(Get-PSUConfigSecurityAlert -ComputerName $computer.ComputerName |
                    Where-Object status -ne 'Completed')
                if ($openAlerts.Count -eq 0)
                {
                    $newAlertParameters = @{
                        VulnerabilityId       = 'CVE-2026-PSUCONFIG-001'
                        Severity              = 'Critical'
                        SoftwareName          = $computer.SoftwareName
                        AffectedBeforeVersion = '5.4'
                        MachineId             = $computer.Id
                        ComputerName          = $computer.ComputerName
                        OwnerId               = $computer.OwnerId
                        MachineOnline         = $computer.Online
                        Confirm               = $false
                    }
                    New-PSUConfigSecurityAlert @newAlertParameters
                }
            }

            $device = Get-PSUConfigAwtrixDevice
            Remove-AwtrixNotification -Device $device -Confirm:$false -ErrorAction SilentlyContinue
            $notificationParameters = @{
                Device   = $device
                Text     = 'CRITICAL: SecureConnect vulnerability'
                Color    = '#FF0000'
                Hold     = $true
                Wakeup   = $true
                Property = [AwtrixNotification]@{
                    sound = 'beep'
                    stack = $false
                }
                Confirm  = $false
            }
            Send-AwtrixNotification @notificationParameters

            Write-Information ("Created or retained alert records for {0} vulnerable computers." -f $vulnerableComputers.Count) -InformationAction Continue
            Write-Information 'Persistent critical notification displayed on the AWTRIX clock.' -InformationAction Continue
            [pscustomobject]@{
                Status             = 'Completed'
                VulnerableComputer = $vulnerableComputers.Count
            }
        }

        'Fix'
        {
            if ([System.String]::IsNullOrWhiteSpace($TargetComputerName))
            {
                throw 'TargetComputerName is required for a Fix job.'
            }

            $machine = Get-PSUConfigMonitoringMachineByName -ComputerName $TargetComputerName
            if (-not [System.Boolean]$machine.health.online)
            {
                throw "Computer '$($machine.hostname)' is offline."
            }

            if ($AlertId -gt 0)
            {
                Set-PSUConfigSecurityAlert -Id $AlertId -Status Fixing -Confirm:$false
            }

            $device = Get-PSUConfigAwtrixDevice
            $notificationProperty = [AwtrixNotification]@{ stack = $false }
            Remove-AwtrixNotification -Device $device -Confirm:$false -ErrorAction SilentlyContinue
            $fixingNotificationParameters = @{
                Device   = $device
                Text     = 'Fixing {0}' -f $machine.hostname
                Color    = '#FFB000'
                Duration = 10
                Wakeup   = $true
                Property = $notificationProperty
                Confirm  = $false
            }
            Send-AwtrixNotification @fixingNotificationParameters

            Write-Information ("Patching {0}" -f $machine.hostname) -InformationAction Continue
            Start-Sleep -Seconds 10
            Write-Information 'Patching completed. A reboot is required.' -InformationAction Continue

            if ($AlertId -gt 0)
            {
                Set-PSUConfigSecurityAlert -Id $AlertId -Status Completed -Confirm:$false
            }

            Remove-AwtrixNotification -Device $device -Confirm:$false -ErrorAction SilentlyContinue
            $doneNotificationParameters = @{
                Device   = $device
                Text     = 'Done'
                Color    = '#00FF00'
                Hold     = $true
                Wakeup   = $true
                Property = $notificationProperty
                Confirm  = $false
            }
            Send-AwtrixNotification @doneNotificationParameters

            [pscustomobject]@{
                ComputerName   = [System.String]$machine.hostname
                Status         = 'Completed'
                RebootRequired = $true
                Simulated      = $true
            }
        }
    }
}
