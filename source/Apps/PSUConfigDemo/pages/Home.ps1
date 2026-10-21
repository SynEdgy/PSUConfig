New-UDPage -Name 'Module-first PSU configuration' -Url '/' -Content {
    $moduleBase = (Get-Module -Name 'PSUConfig').ModuleBase
    $Cache:PSUConfigHeroImagePath = Join-Path -Path $moduleBase -ChildPath 'Apps'
    $Cache:PSUConfigHeroImagePath = Join-Path -Path $Cache:PSUConfigHeroImagePath -ChildPath 'PSUConfigDemo'
    $Cache:PSUConfigHeroImagePath = Join-Path -Path $Cache:PSUConfigHeroImagePath -ChildPath 'assets'
    $Cache:PSUConfigHeroImagePath = Join-Path -Path $Cache:PSUConfigHeroImagePath -ChildPath 'powershell-cube.jpg'

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
                        New-UDTypography -Text 'SYNEDGY · MODULE-FIRST AUTOMATION' -Variant overline -Style @{
                            color         = '#72D6FF'
                            fontWeight    = 800
                            letterSpacing = '0.16em'
                        }
                        New-UDTypography -Text 'PowerShell Universal, managed as code.' -Variant h2 -Style @{
                            color         = '#FFFFFF'
                            fontSize      = 'clamp(2.5rem, 5vw, 4.6rem)'
                            fontWeight    = 850
                            letterSpacing = '-0.045em'
                            lineHeight    = 1.02
                            maxWidth      = '800px'
                            marginTop     = '12px'
                        }
                        New-UDTypography -Text 'One PowerShell module defines the commands, data model, APIs, AI tools, jobs, environments, roles, and application deployed to PSU.' -Variant h5 -Style @{
                            color      = '#DCEEFF'
                            fontWeight = 500
                            lineHeight = 1.45
                            maxWidth   = '760px'
                            marginTop  = '20px'
                        }
                        New-UDTypography -Text 'Sampler turns that repository into a repeatable build, test, package, and deployment pipeline created by SynEdgy.' -Style @{
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
                            Text    = 'Run DB Analysis job'
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
                                        throw 'PowerShell Universal did not return a job identifier.'
                                    }

                                    Show-UDToast -Message ("Database analysis job #{0} started." -f $job.Id) -Duration 3000
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
                        @{ Value = [string]$settings.CurrentEnvironment; Label = 'Active environment'; Icon = 'Sliders'; Color = '#38A7DF' }
                        @{ Value = [string]$settings.SqliteDBConfig.Version; Label = 'Schema version'; Icon = 'Database'; Color = '#2167AE' }
                        @{ Value = $users.Count; Label = 'Internal users'; Icon = 'Users'; Color = '#218A67' }
                        @{ Value = '4'; Label = 'Delivery stages'; Icon = 'CodeBranch'; Color = '#E89A2D' }
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
                New-UDTypography -Text 'From repository to running platform' -Variant h3 -Style $headingStyle
                New-UDTypography -Text 'The module is the source of truth. Sampler provides the repeatable path into PowerShell Universal.' -Style $textStyle -Sx $textSx

                $stages = @(
                    @{ Number = '01'; Title = 'Author'; Text = 'PowerShell commands, YAML schemas, app pages, and .universal resource declarations live together.'; Icon = 'Code' }
                    @{ Number = '02'; Title = 'Build and test'; Text = 'ModuleBuilder assembles the module while Pester and Playwright validate behavior and deployment surfaces.'; Icon = 'Vial' }
                    @{ Number = '03'; Title = 'Package'; Text = 'Sampler produces an offline PSU automation repository with the module and its required dependencies.'; Icon = 'BoxOpen' }
                    @{ Number = '04'; Title = 'Deploy'; Text = 'The repository is pushed to PSU, configuration is reconciled, and the demo token is provisioned.'; Icon = 'CloudArrowUp' }
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
                        New-UDTypography -Text 'One module, every PSU surface' -Variant h4 -Style $headingStyle
                        New-UDTypography -Text 'The same versioned module supplies commands and the configuration that exposes them.' -Style $textStyle -Sx $textSx

                        $capabilities = @(
                            @{ Label = 'Commands'; Detail = 'Typed PowerShell functions and SQLite CRUD'; Icon = 'Terminal' }
                            @{ Label = 'Configuration'; Detail = 'Apps, APIs, jobs, roles, environments, and variables'; Icon = 'Gear' }
                            @{ Label = 'Interfaces'; Detail = 'PowerShell, REST, dashboard, and AI tools'; Icon = 'ShareNodes' }
                            @{ Label = 'Operations'; Detail = 'Job output, deployment notifications, and smoke tests'; Icon = 'ChartLine' }
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
                        New-UDTypography -Text 'Active target' -Variant h4 -Style $headingStyle
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
                            New-UDTypography -Text ('Environment: {0}' -f $settings.CurrentEnvironment)
                            New-UDTypography -Text ('UniversalServerUrl: {0}' -f $settings.UniversalServerUrl)
                            New-UDTypography -Text ('Schema: {0}' -f $settings.SqliteDBConfig.Version)
                        }
                        New-UDTypography -Text 'Switch DEV, QA, or PROD through the environment-aware YAML configuration without changing application code.' -Style $textStyle -Sx $textSx
                    }
                }
            }
        }
    }
}
