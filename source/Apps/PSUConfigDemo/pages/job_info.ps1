New-UDPage -Name 'Job Info' -Url '/job/:id' -Content {
    $jobId = [Int64]$id

    # Prefer a scoped app token (Management API) over -Integrated, which bypasses PSU
    # authorization entirely and would allow reading any job in the instance. -Integrated
    # is only used as a fallback when no token is configured (e.g. quick local setup).
    $appToken = [string]$secret:psuconfig_automation_bot_token
    $getJobParams = @{ Id = $jobId }
    if (-not [string]::IsNullOrWhiteSpace($appToken))
    {
        $getJobParams['AppToken'] = $appToken
    }
    else
    {
        $getJobParams['Integrated'] = $true
    }

    $job = Get-PSUJob @getJobParams

    New-UDPsuJobHeader -Job $job

    $terminalViewParams = @{
        JobId                  = $jobId
        JobStatus              = [string]$job.Status
        JobOutputSnapshot      = @($job.Output)
        IncludeStructuredTable = $true
    }
    if (-not [string]::IsNullOrWhiteSpace($appToken))
    {
        $terminalViewParams['AppToken'] = $appToken
    }

    New-UDPsuJobTerminalView @terminalViewParams
}
