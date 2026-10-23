New-UDPage -Name 'Module-first PSU configuration' -Url '/' -Content {
    $moduleBase = (Get-PSUConfigModule).ModuleBase
    $Cache:PSUConfigHeroImagePath = Join-Path -Path $moduleBase -ChildPath 'Apps'
    $Cache:PSUConfigHeroImagePath = Join-Path -Path $Cache:PSUConfigHeroImagePath -ChildPath 'PSUConfigDemo'
    $Cache:PSUConfigHeroImagePath = Join-Path -Path $Cache:PSUConfigHeroImagePath -ChildPath 'assets'
    $Cache:PSUConfigHeroImagePath = Join-Path -Path $Cache:PSUConfigHeroImagePath -ChildPath 'powershell-cube.jpg'
    $defaultUILanguage = (Get-PSUConfigSetting).DefaultUILanguage
    if ($null -eq $defaultUILanguage)
    {
        $defaultUILanguage = 'en'
    }

    $languageParameters = @{
        ModuleBase        = $moduleBase
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
    $Page:PSUConfigDemoStrings = $psuConfigDemoStrings

    $surfaceStyle = @{
        border       = '1px solid rgba(56,167,223,.24)'
        borderRadius = '18px'
        padding      = '24px'
        height       = '100%'
        display      = 'flex'
        flexDirection = 'column'
        alignItems   = 'stretch'
        gap          = '8px'
    }
    $headingStyle = @{
        fontWeight    = 800
        letterSpacing = '-0.025em'
    }
    $textStyle = @{
        lineHeight = 1.65
    }
    $textSx = @{
        color = 'text.secondary'
    }

    New-UDElement -Tag 'main' -Attributes @{
        style = @{
            minHeight       = '100vh'
            margin          = '-24px'
            paddingBottom   = '72px'
            overflowX       = 'hidden'
        }
    } -Content {
        New-UDElement -Tag 'section' -Attributes @{
            style = @{
                position        = 'relative'
                overflow        = 'hidden'
                minHeight       = '540px'
                backgroundColor = '#08091F'
                color           = '#FFFFFF'
                marginBottom    = '36px'
            }
        } -Content {
            New-UDElement -Tag 'div' -Attributes @{
                style = @{
                    position = 'absolute'
                    top      = 0
                    right    = 0
                    zIndex   = 0
                    opacity  = 0.9
                }
            } -Content {
                New-UDImage -Path $Cache:PSUConfigHeroImagePath -Width 930
            }

            New-UDElement -Tag 'div' -Attributes @{
                style = @{
                    position = 'relative'
                    zIndex   = 1
                    maxWidth = '1440px'
                    margin   = '0 auto'
                    padding  = '72px 48px'
                }
            } -Content {
                New-UDGrid -Container -Spacing 4 -AlignItems center -Children {
                    New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 8 -LargeSize 7 -Children {
                        # 'SYNEDGY · MODULE-FIRST AUTOMATION'
                        New-UDTypography -Text $psuConfigDemoStrings.HeroEyebrow -Variant overline -Style @{
                            color         = '#72D6FF'
                            fontWeight    = 800
                            letterSpacing = '0.16em'
                        }
                        # 'PowerShell Universal, managed as code.'
                        New-UDTypography -Text $psuConfigDemoStrings.HeroTitle -Variant h2 -Style @{
                            color         = '#FFFFFF'
                            fontSize      = 'clamp(2.5rem, 5vw, 4.6rem)'
                            fontWeight    = 850
                            letterSpacing = '-0.045em'
                            lineHeight    = 1.02
                            maxWidth      = '800px'
                            marginTop     = '12px'
                        }
                        # 'One PowerShell module defines the commands, data model, APIs, AI tools, jobs, environments, roles, and application deployed to PSU.'
                        New-UDTypography -Text $psuConfigDemoStrings.HeroLead -Variant h5 -Style @{
                            color      = '#DCEEFF'
                            fontWeight = 500
                            lineHeight = 1.45
                            maxWidth   = '760px'
                            marginTop  = '20px'
                        }
                        # 'Sampler turns that repository into a repeatable build, test, package, and deployment pipeline created by SynEdgy.'
                        New-UDTypography -Text $psuConfigDemoStrings.HeroDelivery -Style @{
                            color      = '#B7CCE3'
                            fontSize   = '1.05rem'
                            lineHeight = 1.7
                            maxWidth   = '720px'
                            marginTop  = '14px'
                        }

                        New-UDStack -Direction row -Spacing 1 -AlignItems center -Children {
                            foreach ($channel in 'MODULE', 'PSU', 'SAMPLER', 'SQLITE')
                            {
                                New-UDChip -Label $channel -Variant outlined -Style @{
                                    color       = '#DDF5FF'
                                    borderColor = 'rgba(114,214,255,0.55)'
                                    fontWeight  = 700
                                }
                            }
                        }

                        $analysisButtonParameters = @{
                            # 'Run DB Analysis job'
                            Text    = $psuConfigDemoStrings.RunAnalysisButton
                            Color   = 'primary'
                            Variant = 'contained'
                            Size    = 'large'
                            Icon    = New-UDIcon -Icon 'Database'
                            Style   = @{
                                borderRadius = '10px'
                                padding      = '10px 20px'
                                fontWeight   = 700
                                boxShadow    = '0 8px 20px rgba(33,103,174,.28)'
                            }
                            OnClick = {
                                try
                                {
                                    $appToken = [string]$secret:psuconfig_automation_bot_token
                                    $moduleConfig = Get-PSUConfigSetting
                                    $serverUrl = [string]$moduleConfig.UniversalServerUrl
                                    $commonParameters = @{}
                                    if (-not [string]::IsNullOrWhiteSpace($appToken))
                                    {
                                        $commonParameters.AppToken = $appToken
                                        $commonParameters.ComputerName = $serverUrl
                                    }
                                    else
                                    {
                                        $commonParameters.Integrated = $true
                                    }

                                    $script = Get-PSUScript -Name 'PSUConfig\Get-PSUConfigDatabaseAnalysis' @commonParameters
                                    $job = Invoke-PSUScript -Script $script @commonParameters
                                    if (-not $job -or [long]$job.Id -le 0)
                                    {
                                        # 'PowerShell Universal did not return a job identifier.'
                                        throw $Page:PSUConfigDemoStrings.AnalysisJobIdMissing
                                    }

                                    # 'Database analysis job #{0} started.'
                                    Show-UDToast -Message ($Page:PSUConfigDemoStrings.AnalysisJobStarted -f $job.Id) -Duration 3000
                                    Invoke-UDRedirect -Url ('/job/{0}' -f $job.Id)
                                }
                                catch
                                {
                                    Show-UDToast -Message $_.Exception.Message -Duration 7000 -BackgroundColor '#D64550'
                                }
                            }
                        }
                        New-UDButton @analysisButtonParameters
                    }
                }
            }
        }

        New-UDElement -Tag 'div' -Attributes @{
            style = @{
                maxWidth = '1440px'
                margin   = '0 auto'
                padding  = '0 32px'
            }
        } -Content {
            New-UDDynamic -Id 'psuconfig-runtime-summary' -Content {
                try
                {
                    $settings = Get-PSUConfigSetting
                    $users = @(Get-PSUConfigUser)
                    $metrics = @(
                        # 'Active environment'
                        @{ Value = [string]$settings.CurrentEnvironment; Label = $Page:PSUConfigDemoStrings.MetricActiveEnvironment; Icon = 'Sliders'; Color = '#38A7DF' }
                        # 'Schema version'
                        @{ Value = [string]$settings.SqliteDBConfig.Version; Label = $Page:PSUConfigDemoStrings.MetricSchemaVersion; Icon = 'Database'; Color = '#2167AE' }
                        # 'Internal users'
                        @{ Value = $users.Count; Label = $Page:PSUConfigDemoStrings.MetricInternalUsers; Icon = 'Users'; Color = '#218A67' }
                        # 'Delivery stages'
                        @{ Value = '4'; Label = $Page:PSUConfigDemoStrings.MetricDeliveryStages; Icon = 'CodeBranch'; Color = '#E89A2D' }
                    )

                    New-UDGrid -Container -Spacing 3 -Children {
                        foreach ($metric in $metrics)
                        {
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -LargeSize 3 -Children {
                                New-UDPaper -Elevation 3 -Style $surfaceStyle -Children {
                                    New-UDStack -Direction row -Spacing 2 -AlignItems center -Children {
                                        New-UDElement -Tag 'div' -Attributes @{
                                            style = @{
                                                width           = '48px'
                                                height          = '48px'
                                                borderRadius    = '14px'
                                                display         = 'flex'
                                                alignItems      = 'center'
                                                justifyContent  = 'center'
                                                color           = $metric.Color
                                                backgroundColor = "$($metric.Color)18"
                                            }
                                        } -Content {
                                            New-UDIcon -Icon $metric.Icon -Size lg
                                        }
                                        New-UDElement -Tag 'div' -Attributes @{
                                            style = @{
                                                display       = 'flex'
                                                flexDirection = 'column'
                                            }
                                        } -Content {
                                            New-UDTypography -Text ([string]$metric.Value) -Variant h4 -Style $headingStyle
                                            New-UDTypography -Text $metric.Label -Style $textStyle -Sx $textSx
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                catch
                {
                    New-UDAlert -Severity warning -Text $_.Exception.Message
                }
            }

            New-UDElement -Tag 'section' -Attributes @{ style = @{ marginTop = '42px' } } -Content {
                # 'From repository to running platform'
                New-UDTypography -Text $psuConfigDemoStrings.DeliverySectionTitle -Variant h3 -Style $headingStyle
                # 'The module is the source of truth. Sampler provides the repeatable path into PowerShell Universal.'
                New-UDTypography -Text $psuConfigDemoStrings.DeliverySectionDescription -Style $textStyle -Sx $textSx

                $stages = @(
                    # 'Author'
                    # 'PowerShell commands, YAML schemas, app pages, and .universal resource declarations live together.'
                    @{ Number = '01'; Title = $psuConfigDemoStrings.StageAuthorTitle; Text = $psuConfigDemoStrings.StageAuthorDescription; Icon = 'Code' }
                    # 'Build and test'
                    # 'ModuleBuilder assembles the module while Pester and Playwright validate behavior and deployment surfaces.'
                    @{ Number = '02'; Title = $psuConfigDemoStrings.StageBuildTitle; Text = $psuConfigDemoStrings.StageBuildDescription; Icon = 'Vial' }
                    # 'Package'
                    # 'Sampler produces an offline PSU automation repository with the module and its required dependencies.'
                    @{ Number = '03'; Title = $psuConfigDemoStrings.StagePackageTitle; Text = $psuConfigDemoStrings.StagePackageDescription; Icon = 'BoxOpen' }
                    # 'Deploy'
                    # 'The repository is pushed to PSU, configuration is reconciled, and the demo token is provisioned.'
                    @{ Number = '04'; Title = $psuConfigDemoStrings.StageDeployTitle; Text = $psuConfigDemoStrings.StageDeployDescription; Icon = 'CloudArrowUp' }
                )

                New-UDGrid -Container -Spacing 3 -Children {
                    foreach ($stage in $stages)
                    {
                        New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 6 -LargeSize 3 -Children {
                            New-UDPaper -Elevation 3 -Style $surfaceStyle -Children {
                                New-UDStack -Direction row -Spacing 1 -AlignItems center -Children {
                                    New-UDTypography -Text $stage.Number -Variant overline -Style @{
                                        color         = '#38A7DF'
                                        fontWeight    = 850
                                        letterSpacing = '0.12em'
                                    }
                                    New-UDIcon -Icon $stage.Icon -Size lg -Color '#2167AE'
                                }
                                New-UDTypography -Text $stage.Title -Variant h5 -Style $headingStyle
                                New-UDTypography -Text $stage.Text -Style $textStyle -Sx $textSx
                            }
                        }
                    }
                }
            }

            New-UDGrid -Container -Spacing 3 -Style @{ marginTop = '42px' } -Children {
                New-UDGrid -Item -ExtraSmallSize 12 -LargeSize 7 -Children {
                    New-UDPaper -Elevation 3 -Style $surfaceStyle -Children {
                        # 'One module, every PSU surface'
                        New-UDTypography -Text $psuConfigDemoStrings.SurfacesSectionTitle -Variant h4 -Style $headingStyle
                        # 'The same versioned module supplies commands and the configuration that exposes them.'
                        New-UDTypography -Text $psuConfigDemoStrings.SurfacesSectionDescription -Style $textStyle -Sx $textSx

                        $capabilities = @(
                            # 'Commands'
                            # 'Typed PowerShell functions and SQLite CRUD'
                            @{ Label = $psuConfigDemoStrings.CapabilityCommandsLabel; Detail = $psuConfigDemoStrings.CapabilityCommandsDetail; Icon = 'Terminal' }
                            # 'Configuration'
                            # 'Apps, APIs, jobs, roles, environments, and variables'
                            @{ Label = $psuConfigDemoStrings.CapabilityConfigurationLabel; Detail = $psuConfigDemoStrings.CapabilityConfigurationDetail; Icon = 'Gear' }
                            # 'Interfaces'
                            # 'PowerShell, REST, dashboard, and AI tools'
                            @{ Label = $psuConfigDemoStrings.CapabilityInterfacesLabel; Detail = $psuConfigDemoStrings.CapabilityInterfacesDetail; Icon = 'ShareNodes' }
                            # 'Operations'
                            # 'Job output, deployment notifications, and smoke tests'
                            @{ Label = $psuConfigDemoStrings.CapabilityOperationsLabel; Detail = $psuConfigDemoStrings.CapabilityOperationsDetail; Icon = 'ChartLine' }
                        )
                        foreach ($capability in $capabilities)
                        {
                            New-UDStack -Direction row -Spacing 2 -AlignItems center -Children {
                                New-UDIcon -Icon $capability.Icon -Color '#38A7DF'
                                New-UDElement -Tag 'div' -Attributes @{
                                    style = @{
                                        display       = 'flex'
                                        flexDirection = 'column'
                                    }
                                } -Content {
                                    New-UDTypography -Text $capability.Label -Variant h6 -Style @{
                                        fontWeight = 750
                                    }
                                    New-UDTypography -Text $capability.Detail -Style $textStyle -Sx $textSx
                                }
                            }
                        }
                    }
                }

                New-UDGrid -Item -ExtraSmallSize 12 -LargeSize 5 -Children {
                    New-UDPaper -Elevation 3 -Style $surfaceStyle -Children {
                        # 'Active target'
                        New-UDTypography -Text $psuConfigDemoStrings.TargetSectionTitle -Variant h4 -Style $headingStyle
                        $settings = Get-PSUConfigSetting
                        New-UDPaper -Elevation 0 -Style @{
                            border       = '1px solid rgba(56,167,223,.24)'
                            borderRadius = '12px'
                            padding      = '18px'
                            marginTop    = '18px'
                            fontFamily   = 'Consolas, monospace'
                            display      = 'flex'
                            flexDirection = 'column'
                            gap          = '4px'
                        } -Children {
                            # 'Environment: {0}'
                            New-UDTypography -Text ($psuConfigDemoStrings.TargetEnvironment -f $settings.CurrentEnvironment)
                            # 'UniversalServerUrl: {0}'
                            New-UDTypography -Text ($psuConfigDemoStrings.TargetUniversalServerUrl -f $settings.UniversalServerUrl)
                            # 'Schema: {0}'
                            New-UDTypography -Text ($psuConfigDemoStrings.TargetSchema -f $settings.SqliteDBConfig.Version)
                        }
                        # 'Switch DEV, QA, or PROD through the environment-aware YAML configuration without changing application code.'
                        New-UDTypography -Text $psuConfigDemoStrings.TargetDescription -Style $textStyle -Sx $textSx
                    }
                }
            }
        }
    }
}
