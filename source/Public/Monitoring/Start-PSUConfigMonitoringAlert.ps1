function Start-PSUConfigMonitoringAlert
{
    <#
        .SYNOPSIS
            Starts the PSUConfig SecureConnect alert demonstration.

        .DESCRIPTION
            Starts PSUConfig's asynchronous vulnerability alert job and returns
            its PowerShell Universal job
            identifier for navigation to the shared job output page.

        .PARAMETER DelaySeconds
            Specifies the simulated delay used by the monitoring alert job.

        .EXAMPLE
            Start-PSUConfigMonitoringAlert -DelaySeconds 5 -Confirm:$false

            Starts the monitoring alert workflow with a five-second delay.
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter()]
        [ValidateRange(0, 300)]
        [System.Int32]
        $DelaySeconds = 5
    )

    if (-not $PSCmdlet.ShouldProcess('SecureConnect monitoring scenario', 'Start monitoring alert job'))
    {
        return
    }

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
            JobType      = 'Alert'
            DelaySeconds = $DelaySeconds
        }
    }
    foreach ($entry in $connection.GetEnumerator())
    {
        $invokeParameters[$entry.Key] = $entry.Value
    }

    $job = Invoke-PSUScript @invokeParameters
    if (-not $job -or [System.Int64]$job.Id -le 0)
    {
        throw 'PowerShell Universal did not start the monitoring alert job.'
    }

    [pscustomobject]@{
        Accepted     = $true
        JobId        = [System.Int64]$job.Id
        Status       = 'Queued'
        DelaySeconds = $DelaySeconds
    }
}
