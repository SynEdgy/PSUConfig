New-UDPage -Name 'Home' -Url '/' -Content {
    New-UDMarkdown -Markdown (Get-Content -Raw -Path (Join-Path -Path (Get-UDAppPath) -ChildPath 'README.md'))

    New-UDButton -Text 'Run demo job (Get-myUser)' -OnClick {
        # Note: Invoke-PSUScript -Wait reliably returns a job object with an empty Id on
        # this PSU version (see docs/bug/bug-psu-invoke-psuscript-wait-empty-job-id.md in
        # ComsolCentral); omit -Wait, which reliably returns a populated Id immediately.
        #
        # Prefer a scoped app token (Management API) over -Integrated, which bypasses PSU
        # authorization entirely. -Integrated is only used as a fallback when no token is
        # configured (e.g. quick local setup).
        $appToken = [string]$secret:psuconfig_automation_bot_token
        $moduleConfig = Get-PSUConfigSetting
        $serverUrl = [string]$moduleConfig.UniversalServerUrl
        $commonParams = @{}
        if (-not [string]::IsNullOrWhiteSpace($appToken))
        {
            $commonParams['AppToken'] = $appToken
            $commonParams['ComputerName'] = $serverUrl
        }
        else
        {
            $commonParams['Integrated'] = $true
        }

        $script = Get-PSUScript -Name 'PSUConfig\Get-myUser' @commonParams
        $job = Invoke-PSUScript -Script $script @commonParams

        Invoke-UDRedirect -Url ('/job/{0}' -f $job.Id)
    }
}
