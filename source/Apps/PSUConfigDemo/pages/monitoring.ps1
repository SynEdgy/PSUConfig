New-UDPage -Name 'Monitoring' -Url '/monitoring' -Content {
    $moduleBase = (Get-PSUConfigModule).ModuleBase
    $defaultUILanguage = (Get-PSUConfigSetting).DefaultUILanguage
    if ($null -eq $defaultUILanguage)
    {
        $defaultUILanguage = 'en'
    }

    $languageParameters = @{
        ModuleBase        = $moduleBase
        Name              = 'PSUConfig.Monitoring'
        PreferredLanguage = [System.String] $Cookies['PSUConfigLanguage']
        AcceptLanguage    = [System.String] $Headers['Accept-Language']
        DefaultUILanguage = $defaultUILanguage
    }
    $language = Resolve-PSULocalizationLanguage @languageParameters
    if ($null -eq $Cache:PSUConfigLocalization)
    {
        $Cache:PSUConfigLocalization = [System.Collections.Hashtable]::Synchronized(@{})
    }

    $psuConfigMonitoringStringsParameters = @{
        Name     = 'PSUConfig.Monitoring'
        Language = $language
        Cache    = $Cache:PSUConfigLocalization
    }
    $psuConfigMonitoringStrings = Get-PSUConfigLocalizedData @psuConfigMonitoringStringsParameters
    $Page:PSUConfigMonitoringStrings = $psuConfigMonitoringStrings

    $surfaceStyle = @{
        border       = '1px solid rgba(56,167,223,.24)'
        borderRadius = '18px'
        padding      = '24px'
        height       = '100%'
    }

    New-UDElement -Tag 'main' -Attributes @{
        style = @{
            minHeight = '100vh'
            margin    = '-24px'
            padding   = '48px 32px 72px'
        }
    } -Content {
        New-UDElement -Tag 'div' -Attributes @{
            style = @{
                maxWidth = '1440px'
                margin   = '0 auto'
            }
        } -Content {
            New-UDGrid -Container -Spacing 3 -AlignItems center -Children {
                New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 8 -Children {
                    # 'SYNEDGY - SECURITY OPERATIONS'
                    New-UDTypography -Text $psuConfigMonitoringStrings.PageEyebrow -Variant overline -Style @{
                        color         = '#38A7DF'
                        fontWeight    = 800
                        letterSpacing = '0.14em'
                    }
                    # 'SecureConnect monitoring'
                    New-UDTypography -Text $psuConfigMonitoringStrings.PageTitle -Variant h3 -Style @{
                        fontWeight    = 850
                        letterSpacing = '-0.035em'
                        marginBottom  = '8px'
                    }
                    # 'Detect affected machines, resolve their owners, verify live health, and remediate only after explicit approval.'
                    New-UDTypography -Text $psuConfigMonitoringStrings.PageDescription -Sx @{
                        color = 'text.secondary'
                    } -Style @{
                        maxWidth   = '900px'
                        lineHeight = 1.65
                    }
                }

                New-UDGrid -Item -ExtraSmallSize 12 -MediumSize 4 -Children {
                    New-UDStack -Direction row -Spacing 1 -JustifyContent flex-end -Children {
                        $startAlertButtonParameters = @{
                            # 'Start advisory workflow'
                            Text    = $psuConfigMonitoringStrings.StartAlertButton
                            Color   = 'primary'
                            Variant = 'contained'
                            Icon    = New-UDIcon -Icon 'Bell'
                            OnClick = {
                                try
                                {
                                    $job = Start-PSUConfigMonitoringAlert -Confirm:$false
                                    if (-not $job -or [System.Int64]$job.JobId -le 0)
                                    {
                                        # 'PowerShell Universal did not return an advisory job identifier.'
                                        throw $Page:PSUConfigMonitoringStrings.AlertJobIdMissing
                                    }

                                    # 'Advisory job #{0} started.'
                                    Show-UDToast -Message ($Page:PSUConfigMonitoringStrings.AlertJobStarted -f $job.JobId) -Duration 3000
                                    Invoke-UDRedirect -Url ('/job/{0}' -f $job.JobId)
                                }
                                catch
                                {
                                    Show-UDToast -Message $_.Exception.Message -Duration 7000 -BackgroundColor '#D64550'
                                }
                            }
                        }
                        New-UDButton @startAlertButtonParameters

                        $acknowledgeButtonParameters = @{
                            # 'Acknowledge clock notification'
                            Text    = $psuConfigMonitoringStrings.AcknowledgeButton
                            Variant = 'outlined'
                            Color   = 'secondary'
                            Icon    = New-UDIcon -Icon 'CheckCircle'
                            OnClick = {
                                try
                                {
                                    $null = Confirm-PSUConfigMonitoringNotification -Confirm:$false
                                    # 'Clock notification acknowledged.'
                                    Show-UDToast -Message $Page:PSUConfigMonitoringStrings.NotificationAcknowledged -Duration 3000
                                    Sync-UDElement -Id 'psuConfigMonitoringFindings'
                                }
                                catch
                                {
                                    Show-UDToast -Message $_.Exception.Message -Duration 7000 -BackgroundColor '#D64550'
                                }
                            }
                        }
                        New-UDButton @acknowledgeButtonParameters

                        $refreshButtonParameters = @{
                            # 'Refresh findings'
                            Text    = $psuConfigMonitoringStrings.RefreshButton
                            Variant = 'outlined'
                            Icon    = New-UDIcon -Icon 'Sync'
                            OnClick = {
                                Sync-UDElement -Id 'psuConfigMonitoringFindings'
                            }
                        }
                        New-UDButton @refreshButtonParameters
                    }
                }
            }

            New-UDPaper -Elevation 2 -Style @{
                border       = '1px solid rgba(56,167,223,.24)'
                borderRadius = '18px'
                padding      = '24px'
                marginTop    = '28px'
                marginBottom = '28px'
                display      = 'block'
                width        = '100%'
                boxSizing    = 'border-box'
            } -Children {
                New-UDElement -Tag 'div' -Attributes @{
                    style = @{
                        display   = 'block'
                        width     = '100%'
                        minWidth  = '0'
                        boxSizing = 'border-box'
                    }
                } -Content {
                    # 'Controlled response workflow'
                    New-UDTypography -Text $psuConfigMonitoringStrings.WorkflowTitle -Variant h5 -Style @{
                        fontWeight   = 800
                        marginBottom = '4px'
                    }
                    # 'Every stage keeps inventory, identity, health, and remediation decisions visible.'
                    New-UDTypography -Text $psuConfigMonitoringStrings.WorkflowDescription -Sx @{
                        color = 'text.secondary'
                    } -Style @{
                        marginBottom = '20px'
                    }

                    $workflowStages = @(
                        @{
                            Number      = '01'
                            Icon        = 'Search'
                            Label       = $psuConfigMonitoringStrings.DetectLabel
                            Title       = $psuConfigMonitoringStrings.DetectTitle
                            Description = $psuConfigMonitoringStrings.DetectDescription
                            Color       = '#D64550'
                        }
                        @{
                            Number      = '02'
                            Icon        = 'UserTag'
                            Label       = $psuConfigMonitoringStrings.EnrichLabel
                            Title       = $psuConfigMonitoringStrings.EnrichTitle
                            Description = $psuConfigMonitoringStrings.EnrichDescription
                            Color       = '#38A7DF'
                        }
                        @{
                            Number      = '03'
                            Icon        = 'Heartbeat'
                            Label       = $psuConfigMonitoringStrings.VerifyLabel
                            Title       = $psuConfigMonitoringStrings.VerifyTitle
                            Description = $psuConfigMonitoringStrings.VerifyDescription
                            Color       = '#2EAD74'
                        }
                        @{
                            Number      = '04'
                            Icon        = 'Tools'
                            Label       = $psuConfigMonitoringStrings.RemediateLabel
                            Title       = $psuConfigMonitoringStrings.RemediateTitle
                            Description = $psuConfigMonitoringStrings.RemediateDescription
                            Color       = '#F0A33A'
                        }
                    )

                    New-UDElement -Tag 'div' -Attributes @{
                        style = @{
                            display             = 'grid'
                            gridTemplateColumns = 'repeat(auto-fit, minmax(220px, 1fr))'
                            gap                 = '0'
                            width               = '100%'
                            minWidth            = '0'
                            boxSizing           = 'border-box'
                            border              = '1px solid rgba(56,167,223,.18)'
                            borderRadius        = '16px'
                            overflow            = 'hidden'
                        }
                    } -Content {
                        $stageIndex = 0
                        foreach ($stage in $workflowStages)
                        {
                            $stageIndex++
                            New-UDElement -Tag 'div' -Attributes @{
                                style = @{
                                    position     = 'relative'
                                    padding      = '22px'
                                    minWidth     = '0'
                                    minHeight    = '210px'
                                    borderRight  = if ($stageIndex -lt $workflowStages.Count)
                                    {
                                        '1px solid rgba(56,167,223,.18)'
                                    }
                                    else
                                    {
                                        'none'
                                    }
                                    background   = 'linear-gradient(145deg, rgba(56,167,223,.09), rgba(8,9,31,.02))'
                                }
                            } -Content {
                            New-UDStack -Direction row -JustifyContent space-between -AlignItems center -Children {
                                New-UDElement -Tag 'div' -Attributes @{
                                    style = @{
                                        width           = '48px'
                                        height          = '48px'
                                        borderRadius    = '14px'
                                        display         = 'flex'
                                        alignItems      = 'center'
                                        justifyContent  = 'center'
                                        color           = '#FFFFFF'
                                        backgroundColor = $stage.Color
                                        boxShadow       = '0 8px 20px rgba(0,0,0,.18)'
                                    }
                                } -Content {
                                    New-UDIcon -Icon $stage.Icon -Size 'lg'
                                }

                                New-UDTypography -Text $stage.Number -Style @{
                                    color         = 'rgba(125,175,215,.36)'
                                    fontSize      = '2rem'
                                    fontWeight    = 900
                                    letterSpacing = '-0.06em'
                                }
                            }

                            New-UDChip -Label $stage.Label -Size small -Variant outlined -Style @{
                                marginTop   = '18px'
                                borderColor = $stage.Color
                                color       = $stage.Color
                                fontWeight  = 750
                            }
                            New-UDTypography -Text $stage.Title -Variant h6 -Style @{
                                fontWeight   = 850
                                marginTop    = '10px'
                                marginBottom = '6px'
                            }
                            New-UDTypography -Text $stage.Description -Sx @{
                                color = 'text.secondary'
                            } -Style @{
                                lineHeight = 1.55
                            }

                            if ($stageIndex -lt $workflowStages.Count)
                            {
                                New-UDElement -Tag 'div' -Attributes @{
                                    style = @{
                                        position        = 'absolute'
                                        right           = '-13px'
                                        top             = '43px'
                                        zIndex          = 2
                                        width           = '26px'
                                        height          = '26px'
                                        borderRadius    = '50%'
                                        display         = 'flex'
                                        alignItems      = 'center'
                                        justifyContent  = 'center'
                                        color           = '#38A7DF'
                                        backgroundColor = '#08091F'
                                        border          = '1px solid rgba(56,167,223,.35)'
                                    }
                                } -Content {
                                    New-UDIcon -Icon 'ChevronRight' -Size 'sm'
                                    }
                                }
                            }
                        }
                    }
                }
            }

            New-UDDynamic -Id 'psuConfigMonitoringFindings' -Content {
                try
                {
                    Initialize-PSUConfigDB -Confirm:$false
                    $alerts = @(Get-PSUConfigSecurityAlert)
                    $alertComputerNames = @($alerts | Select-Object -ExpandProperty computerName -Unique)
                    $computers = if ($alertComputerNames.Count -eq 0)
                    {
                        @()
                    }
                    else
                    {
                        @(Get-PSUConfigMonitoringComputer |
                            Where-Object ComputerName -In $alertComputerNames)
                    }
                    $onlineCount = @($computers | Where-Object Online).Count
                    $ownerCount = @($computers | Where-Object OwnerAssigned).Count
                    $offlineCount = $computers.Count - $onlineCount

                    $metrics = @(
                        @{ Label = $Page:PSUConfigMonitoringStrings.MetricVulnerable; Value = $computers.Count; Color = '#D64550' }
                        @{ Label = $Page:PSUConfigMonitoringStrings.MetricOnline; Value = $onlineCount; Color = '#2EAD74' }
                        @{ Label = $Page:PSUConfigMonitoringStrings.MetricOwners; Value = $ownerCount; Color = '#38A7DF' }
                        @{ Label = $Page:PSUConfigMonitoringStrings.MetricBlocked; Value = $offlineCount; Color = '#F0A33A' }
                    )

                    New-UDGrid -Container -Spacing 2 -Children {
                        foreach ($metric in $metrics)
                        {
                            New-UDGrid -Item -ExtraSmallSize 12 -SmallSize 6 -LargeSize 3 -Children {
                                New-UDPaper -Elevation 2 -Style $surfaceStyle -Children {
                                    New-UDTypography -Text ([System.String]$metric.Value) -Variant h3 -Style @{
                                        color      = $metric.Color
                                        fontWeight = 850
                                    }
                                    New-UDTypography -Text $metric.Label -Sx @{
                                        color = 'text.secondary'
                                    } -Style @{
                                        fontWeight = 700
                                    }
                                }
                            }
                        }
                    }

                    $rows = @(
                        foreach ($computer in $computers)
                        {
                            [pscustomobject]@{
                                ComputerName    = $computer.ComputerName
                                SoftwareVersion = $computer.SoftwareVersion
                                Owner           = if ($computer.OwnerAssigned)
                                {
                                    $computer.OwnerDisplayName
                                }
                                else
                                {
                                    $Page:PSUConfigMonitoringStrings.UnknownOwner
                                }
                                State            = if ($computer.Online)
                                {
                                    $Page:PSUConfigMonitoringStrings.Online
                                }
                                else
                                {
                                    $Page:PSUConfigMonitoringStrings.Offline
                                }
                                Uptime          = $Page:PSUConfigMonitoringStrings.UptimeHours -f $computer.UptimeHours
                                Online          = $computer.Online
                            }
                        }
                    )

                    $columns = @(
                        # 'Computer'
                        New-UDTableColumn -Property ComputerName -Title $Page:PSUConfigMonitoringStrings.ColumnComputer -IncludeInSearch
                        # 'Version'
                        New-UDTableColumn -Property SoftwareVersion -Title $Page:PSUConfigMonitoringStrings.ColumnVersion -IncludeInSearch
                        # 'Owner'
                        New-UDTableColumn -Property Owner -Title $Page:PSUConfigMonitoringStrings.ColumnOwner -IncludeInSearch
                        # 'State'
                        New-UDTableColumn -Property State -Title $Page:PSUConfigMonitoringStrings.ColumnState -IncludeInSearch
                        # 'Uptime'
                        New-UDTableColumn -Property Uptime -Title $Page:PSUConfigMonitoringStrings.ColumnUptime
                        # 'Action'
                        New-UDTableColumn -Property Action -Title $Page:PSUConfigMonitoringStrings.ColumnAction -Render {
                            New-UDStack -Direction row -Spacing 1 -AlignItems center -Children {
                                if (-not [System.Boolean]$EventData.Online)
                                {
                                    # 'Offline - patching blocked'
                                    New-UDChip -Label $Page:PSUConfigMonitoringStrings.OfflineBlocked -Color 'default' -Variant 'outlined'
                                }
                                else
                                {
                                    $reviewButtonParameters = @{
                                        Id      = 'reviewMonitoring-{0}' -f $EventData.ComputerName
                                        # 'Review'
                                        Text    = $Page:PSUConfigMonitoringStrings.ReviewButton
                                        Color   = 'primary'
                                        Variant = 'outlined'
                                        Icon    = New-UDIcon -Icon 'ShieldAlt'
                                        OnClick = {
                                            $Page:PSUConfigMonitoringOwnerNotified = $false
                                            $Page:PSUConfigMonitoringOperatorApproved = $false
                                            Show-UDModal -Content {
                                                # 'Approve remediation'
                                                New-UDTypography -Text $Page:PSUConfigMonitoringStrings.ModalTitle -Variant h5 -Style @{
                                                    fontWeight   = 800
                                                    marginBottom = '8px'
                                                }
                                                # 'Review the target and confirm both safeguards before starting the patch job.'
                                                New-UDTypography -Text $Page:PSUConfigMonitoringStrings.ModalDescription -Sx @{
                                                    color = 'text.secondary'
                                                } -Style @{
                                                    marginBottom = '20px'
                                                }
                                                New-UDStack -Spacing 1 -Children {
                                                    # 'Computer: {0}'
                                                    New-UDTypography -Text ($Page:PSUConfigMonitoringStrings.ComputerLabel -f $EventData.ComputerName)
                                                    # 'SecureConnect: {0}'
                                                    New-UDTypography -Text ($Page:PSUConfigMonitoringStrings.VersionLabel -f $EventData.SoftwareVersion)
                                                    # 'Owner: {0}'
                                                    New-UDTypography -Text ($Page:PSUConfigMonitoringStrings.OwnerLabel -f $EventData.Owner)
                                                    # 'Health: {0}'
                                                    New-UDTypography -Text ($Page:PSUConfigMonitoringStrings.StatusLabel -f $EventData.State)
                                                }

                                                New-UDElement -Tag 'div' -Attributes @{
                                                    style = @{
                                                        marginTop = '20px'
                                                    }
                                                } -Content {
                                                    # 'I have notified the owner about the reboot.'
                                                    New-UDCheckbox -Id 'monitoringOwnerNotified' -Label $Page:PSUConfigMonitoringStrings.OwnerNotifiedLabel -OnChange {
                                                        $Page:PSUConfigMonitoringOwnerNotified = [System.Boolean]$EventData
                                                    }
                                                    # 'I explicitly approve patching this machine.'
                                                    New-UDCheckbox -Id 'monitoringOperatorApproved' -Label $Page:PSUConfigMonitoringStrings.OperatorApprovedLabel -OnChange {
                                                        $Page:PSUConfigMonitoringOperatorApproved = [System.Boolean]$EventData
                                                    }
                                                }
                                            } -Footer {
                                                # 'Cancel'
                                                New-UDButton -Text $Page:PSUConfigMonitoringStrings.CancelButton -OnClick {
                                                    Hide-UDModal
                                                }

                                                # 'Approve and patch'
                                                New-UDButton -Text $Page:PSUConfigMonitoringStrings.StartPatchButton -Color 'primary' -Variant 'contained' -OnClick {
                                                    try
                                                    {
                                                        $ownerNotified = [System.Boolean]$Page:PSUConfigMonitoringOwnerNotified
                                                        $approved = [System.Boolean]$Page:PSUConfigMonitoringOperatorApproved
                                                        if (-not $ownerNotified -or -not $approved)
                                                        {
                                                            # 'Owner notification and explicit operator approval are both required.'
                                                            Show-UDToast -Message $Page:PSUConfigMonitoringStrings.ApprovalRequired -Duration 5000 -BackgroundColor '#D64550'
                                                            return
                                                        }

                                                        $patchParameters = @{
                                                            ComputerName  = [System.String]$EventData.ComputerName
                                                            OwnerNotified = $ownerNotified
                                                            Approved      = $approved
                                                            Confirm       = $false
                                                        }
                                                        $job = Invoke-PSUConfigMonitoringPatch @patchParameters
                                                        if (-not $job -or [System.Int64]$job.JobId -le 0)
                                                        {
                                                            # 'PowerShell Universal did not return a patch job identifier.'
                                                            throw $Page:PSUConfigMonitoringStrings.PatchJobIdMissing
                                                        }

                                                        Hide-UDModal
                                                        # 'Patch job #{0} started for {1}.'
                                                        Show-UDToast -Message ($Page:PSUConfigMonitoringStrings.PatchJobStarted -f $job.JobId, $EventData.ComputerName) -Duration 3000
                                                        Invoke-UDRedirect -Url ('/job/{0}' -f $job.JobId)
                                                    }
                                                    catch
                                                    {
                                                        Show-UDToast -Message $_.Exception.Message -Duration 7000 -BackgroundColor '#D64550'
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    New-UDButton @reviewButtonParameters
                                }

                                $deleteFindingButtonParameters = @{
                                    Id      = 'deleteMonitoringFinding-{0}' -f $EventData.ComputerName
                                    # 'Delete'
                                    Text    = $Page:PSUConfigMonitoringStrings.DeleteFindingButton
                                    Color   = 'error'
                                    Variant = 'text'
                                    Icon    = New-UDIcon -Icon 'TrashAlt'
                                    OnClick = {
                                        try
                                        {
                                            $computerName = [System.String]$EventData.ComputerName
                                            $null = Remove-PSUConfigMonitoringFinding -ComputerName $computerName -Confirm:$false
                                            # 'Finding summary deleted for {0}.'
                                            Show-UDToast -Message ($Page:PSUConfigMonitoringStrings.FindingDeleted -f $computerName) -Duration 3000
                                            Sync-UDElement -Id 'psuConfigMonitoringFindings'
                                        }
                                        catch
                                        {
                                            Show-UDToast -Message $_.Exception.Message -Duration 7000 -BackgroundColor '#D64550'
                                        }
                                    }
                                }
                                New-UDButton @deleteFindingButtonParameters
                            }
                        }
                    )

                    New-UDPaper -Elevation 3 -Style @{
                        border       = '1px solid rgba(56,167,223,.24)'
                        borderRadius = '18px'
                        padding      = '20px'
                        marginTop    = '20px'
                        display      = 'block'
                        width        = '100%'
                        boxSizing    = 'border-box'
                    } -Children {
                        New-UDElement -Tag 'div' -Attributes @{
                            style = @{
                                display   = 'block'
                                width     = '100%'
                                minWidth  = '0'
                                boxSizing = 'border-box'
                            }
                        } -Content {
                            # 'SecureConnect findings'
                            New-UDTypography -Text $Page:PSUConfigMonitoringStrings.FindingsTitle -Variant h5 -Style @{
                                fontWeight   = 800
                                marginBottom = '4px'
                            }
                            # 'Live workflow data from PSUConfig''s bundled inventory and cached owner profiles.'
                            New-UDTypography -Text $Page:PSUConfigMonitoringStrings.FindingsDescription -Sx @{
                                color = 'text.secondary'
                            } -Style @{
                                marginBottom = '18px'
                            }

                            $tableParameters = @{
                                Id             = 'psuConfigMonitoringTable'
                                Data           = $rows
                                Columns        = $columns
                                Dense          = $true
                                ShowSearch     = $true
                                ShowPagination = $true
                                PageSize       = 10
                                RemoveCard     = $true
                            }
                            New-UDTable @tableParameters
                        }
                    }
                }
                catch
                {
                    # 'Monitoring data could not be loaded: {0}'
                    New-UDAlert -Severity error -Text ($Page:PSUConfigMonitoringStrings.LoadingError -f $_.Exception.Message)
                }
            }
        }
    }
}
