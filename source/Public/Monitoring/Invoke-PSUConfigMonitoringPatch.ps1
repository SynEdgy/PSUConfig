function Invoke-PSUConfigMonitoringPatch
{
    <#
        .SYNOPSIS
            Starts approved patching for an online vulnerable computer.

        .DESCRIPTION
            Rechecks the PSUConfig monitoring inventory and starts patching only
            when the computer is vulnerable and online, its owner was notified,
            and the operator explicitly approved remediation.

        .PARAMETER ComputerName
            Specifies the vulnerable computer to patch.

        .PARAMETER OwnerNotified
            Confirms that the computer owner was notified of the imminent reboot.

        .PARAMETER Approved
            Confirms that the operator explicitly approved patching.

        .EXAMPLE
            Invoke-PSUConfigMonitoringPatch -ComputerName CH-GVA-LT1001 -OwnerNotified $true -Approved $true -Confirm:$false

            Rechecks computer health and starts the approved monitoring patch job.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ComputerName,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $OwnerNotified,

        [Parameter(Mandatory = $true)]
        [System.Boolean]
        $Approved
    )

    if (-not $OwnerNotified)
    {
        throw 'The computer owner must be notified before patching.'
    }

    if (-not $Approved)
    {
        throw 'Patching requires explicit operator approval.'
    }

    $machine = Get-PSUConfigMonitoringMachineByName -ComputerName $ComputerName
    $secureConnect = @($machine.installedSoftware |
        Where-Object name -eq 'SecureConnect') |
        Select-Object -First 1
    if (-not $secureConnect -or [System.Version]$secureConnect.version -ge [System.Version]'5.4')
    {
        throw "Computer '$($machine.hostname)' is not vulnerable to the SecureConnect advisory."
    }

    if (-not [System.Boolean]$machine.health.online)
    {
        throw "Patching cannot be started because '$ComputerName' is offline."
    }

    if (-not $PSCmdlet.ShouldProcess($ComputerName, 'Start monitoring patching workflow'))
    {
        return
    }

    $alert = @(Get-PSUConfigSecurityAlert -ComputerName $machine.hostname |
        Where-Object status -in @('Detected', 'Investigating') |
        Sort-Object id -Descending) |
        Select-Object -First 1

    $connection = Get-PSUConfigServerConnectionParameter
    $scriptPath = 'PSUConfig\Invoke-PSUConfigMonitoringJob'
    $script = Get-PSUScript -Name $scriptPath @connection
    if (-not $script)
    {
        throw "PowerShell Universal script '$scriptPath' was not found."
    }

    $invokeParameters = @{
        Script     = $script
        Parameters = @{
            JobType            = 'Fix'
            TargetComputerName = [System.String]$machine.hostname
            AlertId            = if ($alert) { [System.Int64]$alert.id } else { 0 }
        }
    }
    foreach ($entry in $connection.GetEnumerator())
    {
        $invokeParameters[$entry.Key] = $entry.Value
    }

    $job = Invoke-PSUScript @invokeParameters
    if (-not $job -or [System.Int64]$job.Id -le 0)
    {
        throw "PowerShell Universal did not start the patch job for '$($machine.hostname)'."
    }

    if ($alert)
    {
        Set-PSUConfigSecurityAlert -Id $alert.id -Status Fixing -PsuJobId ([System.String]$job.Id) -Confirm:$false
    }

    [pscustomobject]@{
        ComputerName   = [System.String]$machine.hostname
        Action         = 'Patching'
        OwnerNotified  = $OwnerNotified
        RebootRequired = $true
        JobId          = [System.Int64]$job.Id
        Simulated      = $true
        Status         = 'Started'
    }
}
