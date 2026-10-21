New-UDPage -Name 'Job execution' -Url '/job/:id' -Content {
    $jobId = [long]$id
    $appToken = [string]$secret:psuconfig_automation_bot_token
    $moduleConfig = Get-PSUConfigSetting
    $serverUrl = [string]$moduleConfig.UniversalServerUrl

    $getJobParameters = @{
        Id = $jobId
    }
    if (-not [string]::IsNullOrWhiteSpace($appToken))
    {
        $getJobParameters.AppToken = $appToken
        $getJobParameters.ComputerName = $serverUrl
    }
    else
    {
        $getJobParameters.Integrated = $true
    }

    $job = Get-PSUJob @getJobParameters
    if ($null -eq $job)
    {
        throw "PowerShell Universal job '$jobId' was not found."
    }

    New-UDElement -Tag 'main' -Attributes @{
        style = @{
            minHeight       = '100vh'
            margin          = '-24px'
            padding         = '48px 32px 72px'
        }
    } -Content {
        New-UDElement -Tag 'div' -Attributes @{
            style = @{
                maxWidth = '1280px'
                margin   = '0 auto'
            }
        } -Content {
            New-UDTypography -Text 'SYNEDGY · MODULE-FIRST JOB EXECUTION' -Variant overline -Style @{
                color         = '#38A7DF'
                fontWeight    = 800
                letterSpacing = '0.14em'
            }
            New-UDTypography -Text ("PowerShell Universal job #{0}" -f $jobId) -Variant h3 -Style @{
                fontWeight    = 850
                letterSpacing = '-0.035em'
                marginBottom  = '8px'
            }
            New-UDTypography -Text 'A module-backed command executed by PSU with live, authenticated output retrieval.' -Sx @{
                color = 'text.secondary'
            } -Style @{
                marginBottom = '24px'
            }

            New-UDPaper -Elevation 3 -Style @{
                border       = '1px solid rgba(56,167,223,.24)'
                borderRadius = '18px'
                overflow     = 'hidden'
                padding      = '20px'
                display      = 'flex'
                flexDirection = 'column'
                gap          = '12px'
            } -Children {
                New-UDPsuJobHeader -Job $job

                $terminalParameters = @{
                    JobId                  = $jobId
                    JobStatus              = [string]$job.Status
                    JobOutputSnapshot      = @($job.Output)
                    IncludeStructuredTable = $true
                    AutoRefreshInterval    = 2
                }
                if (-not [string]::IsNullOrWhiteSpace($appToken))
                {
                    $terminalParameters.AppToken = $appToken
                    $terminalParameters.UniversalServerUrl = $serverUrl
                }

                New-UDPsuJobTerminalView @terminalParameters
            }

            $backButtonParameters = @{
                Text    = 'Back to module-first demo'
                Color   = 'primary'
                Variant = 'contained'
                Icon    = New-UDIcon -Icon 'ArrowLeft'
                Style   = @{
                    borderRadius = '10px'
                    fontWeight   = 700
                    marginTop    = '24px'
                }
                OnClick = {
                    Invoke-UDRedirect -Url '/'
                }
            }
            New-UDButton @backButtonParameters
        }
    }
}
