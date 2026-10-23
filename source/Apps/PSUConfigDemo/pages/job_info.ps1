New-UDPage -Name 'Job execution' -Url '/job/:id' -Content {
    $jobId = [long]$id
    $appToken = [string]$secret:psuconfig_automation_bot_token
    $moduleConfig = Get-PSUConfigSetting
    $serverUrl = [string]$moduleConfig.UniversalServerUrl
    $defaultUILanguage = $moduleConfig.DefaultUILanguage
    if ($null -eq $defaultUILanguage)
    {
        $defaultUILanguage = 'en'
    }

    $languageParameters = @{
        ModuleBase        = (Get-PSUConfigModule).ModuleBase
        Name              = 'PSUConfigDemo'
        PreferredLanguage = [System.String] $Cookies['PSUConfigLanguage']
        AcceptLanguage    = [System.String] $Headers['Accept-Language']
        DefaultUILanguage = $defaultUILanguage
    }
    $language = Resolve-PSULocalizationLanguage @languageParameters
    if ($null -eq $Cache:PSUConfigLocalization)
    {
        $Cache:PSUConfigLocalization = [System.Collections.Hashtable]::Synchronized(@{})
    }

    $psuConfigDemoStringsParameters = @{
        Language = $language
        Cache    = $Cache:PSUConfigLocalization
    }
    $psuConfigDemoStrings = Get-PSUConfigLocalizedData @psuConfigDemoStringsParameters

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
        # "PowerShell Universal job '$jobId' was not found."
        throw ($psuConfigDemoStrings.JobNotFound -f $jobId)
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
            # 'SYNEDGY · MODULE-FIRST JOB EXECUTION'
            New-UDTypography -Text $psuConfigDemoStrings.JobPageEyebrow -Variant overline -Style @{
                color         = '#38A7DF'
                fontWeight    = 800
                letterSpacing = '0.14em'
            }
            # 'PowerShell Universal job #{0}'
            New-UDTypography -Text ($psuConfigDemoStrings.JobPageTitle -f $jobId) -Variant h3 -Style @{
                fontWeight    = 850
                letterSpacing = '-0.035em'
                marginBottom  = '8px'
            }
            # 'A module-backed command executed by PSU with live, authenticated output retrieval.'
            New-UDTypography -Text $psuConfigDemoStrings.JobPageDescription -Sx @{
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
                $headerParameters = @{
                    Job               = $job
                    Language          = $language
                    DefaultUILanguage = $defaultUILanguage
                }
                New-UDPsuJobHeader @headerParameters

                $terminalParameters = @{
                    JobId                  = $jobId
                    JobStatus              = [string]$job.Status
                    JobOutputSnapshot      = @($job.Output)
                    IncludeStructuredTable = $true
                    AutoRefreshInterval    = 2
                    Language               = $language
                    DefaultUILanguage      = $defaultUILanguage
                }
                if (-not [string]::IsNullOrWhiteSpace($appToken))
                {
                    $terminalParameters.AppToken = $appToken
                    $terminalParameters.UniversalServerUrl = $serverUrl
                }

                New-UDPsuJobTerminalView @terminalParameters
            }

            $backButtonParameters = @{
                # 'Back to module-first demo'
                Text    = $psuConfigDemoStrings.JobBackButton
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
