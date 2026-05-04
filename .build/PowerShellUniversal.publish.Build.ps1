<#
    .SYNOPSIS
        Tasks for publishing the built module to a PowerShell Universal server.

    .DESCRIPTION
        Provides two InvokeBuild tasks targeting a PowerShell Universal (PSU)
        server REST API:
        - publish_packed_module_to_universal_server: uploads the packed .nupkg
          directly to the PSU deployment endpoint.
        - publish_module_from_psresource_repos_to_universal_server: registers (or reconciles)
          a PSResourceRepository on the PSU server, then triggers a module
          install from that repository.

    .PARAMETER ProjectName
        The project (module) name. Resolved from build metadata when omitted.

    .PARAMETER SourcePath
        Path to the module source. Resolved from build metadata when omitted.

    .PARAMETER OutputDirectory
        Base output directory. Defaults to '<BuildRoot>/output'.

    .PARAMETER BuiltModuleSubdirectory
        Subdirectory under OutputDirectory holding the built module.

    .PARAMETER VersionedOutputDirectory
        Whether the built module is placed under a version folder.

    .PARAMETER BuildModuleOutput
        Resolved path to the built module folder.

    .PARAMETER ModuleVersion
        The module version that was built.

    .PARAMETER UniversalServerUrl
        Base URL of the PowerShell Universal server (e.g. http://localhost:5000).
        Falls back to BuildInfo.UniversalServer.UniversalServerUrl from build.yaml.

    .PARAMETER UniversalServerAppToken
        Bearer token used to authenticate against the PSU REST API. Typically
        loaded from secrets.local.ps1. Falls back to
        BuildInfo.UniversalServer.UniversalServerAppToken.

    .PARAMETER UniversalPSResourceRepositoryName
        Name of the PSResourceRepository to register/reconcile on the PSU server.

    .PARAMETER UniversalPSResourceRepositoryUrl
        URL or local filesystem path backing the PSResourceRepository. Non-URI
        values are resolved to an absolute path relative to $BuildRoot and the
        directory is created when missing.

    .PARAMETER UniversalPSResourceRepositoryAutoRemove
        When $true (default), an existing PSResourceRepository whose url/trusted
        differs from the desired config is deleted and re-created. When $false,
        the existing repository is left in place and used as-is.

    .PARAMETER BuildInfo
        Hashtable of build metadata loaded from build.yaml.
#>

param
(
    [Parameter()]
    [System.String]
    $ProjectName = (property ProjectName ''),

    [Parameter()]
    [System.String]
    $SourcePath = (property SourcePath ''),

    [Parameter()]
    [System.String]
    $OutputDirectory = (property OutputDirectory (Join-Path $BuildRoot 'output')),

    [Parameter()]
    [System.String]
    $BuiltModuleSubdirectory = (property BuiltModuleSubdirectory ''),

    [Parameter()]
    [System.Management.Automation.SwitchParameter]
    $VersionedOutputDirectory = (property VersionedOutputDirectory $true),

    [Parameter()]
    [System.String]
    $BuildModuleOutput = (property BuildModuleOutput (Join-Path $OutputDirectory $BuiltModuleSubdirectory)),

    [Parameter()]
    [System.String]
    $ModuleVersion = (property ModuleVersion ''),

    [Parameter()]
    [System.String]
    $UniversalServerUrl = (property UniversalServerUrl 'http://localhost:5000'),

    [Parameter()]
    [System.String]
    $UniversalServerAppToken = (property UniversalServerAppToken ''),

    [Parameter()]
    [System.String]
    $UniversalPSResourceRepositoryName = (property UniversalPSResourceRepositoryName 'output'),

    [Parameter()]
    [System.String]
    $UniversalPSResourceRepositoryUrl = (property UniversalPSResourceRepositoryUrl './output/'),

    [Parameter()]
    [System.Boolean]
    $UniversalPSResourceRepositoryAutoRemove = (property UniversalPSResourceRepositoryAutoRemove $true),

    [Parameter()]
    [System.Collections.Hashtable]
    $BuildInfo = (property BuildInfo @{ })
)

# Synopsis: Upload the packed .nupkg directly to the PowerShell Universal deployment endpoint.
task publish_packed_module_to_universal_server {
    . Set-SamplerTaskVariable
    "`tBuilt Module Subdirectory  = '{0}'" -f $OutputDirectory
    $builtNupkgPath = Join-Path -Path $OutputDirectory -ChildPath ('{0}.{1}.nupkg' -f $ProjectName, $ModuleVersion)
    "`tExpected nupkg file  = '{0}'" -f $builtNupkgPath
    if (Test-Path -Path $builtNupkgPath)
    {
        Write-Build -Color 'Green' -Text ("`tnukpg found at path: {0}" -f $builtNupkgPath)
    }
    else
    {
        Write-Error -Message ("`tModule nupkg not found at path: {0}" -f $builtNupkgPath)
        return
    }

    $UniversalServer = $BuildInfo.UniversalServer
    if ([string]::IsNullOrEmpty($UniversalServer) -and $UniversalServer.UniversalServerUrl)
    {
       $UniversalServerUrl = $UniversalServer.UniversalServerUrl.TrimEnd('/')
    }

    if ([string]::IsNullOrEmpty($UniversalServerAppToken) -and $UniversalServer.UniversalServerAppToken)
    {
       $UniversalServerAppToken = $UniversalServer.UniversalServerAppToken
    }

    Write-Build -Color 'DarkGray' -Text "Publishing module to Universal Automation"
    # $response = Invoke-WebRequest -Uri "$universalServerUrl/api/v1/deployment?asModule=true" -Headers @{
    #     "Authorization" = "Bearer $UniversalServerAppToken"
    # } -InFile $builtNupkgPath -Method Put -ContentType "application/octet-stream"
    # $endpointUrl = "$UniversalServerUrl/api/v1/deployment/module/$ProjectName/$ModuleVersion?repository=output&synchronous=true"
    $endpointUrl = '{0}/api/v1/deployment/module/{1}/{2}?repository=output&synchronous=true' -f $UniversalServerUrl, $ProjectName, $ModuleVersion
    $publishParams = @{
        Uri         = $endpointUrl
        Headers     = @{
            'Authorization' = 'Bearer {0}' -f $UniversalServerAppToken
        }
        InFile      = $builtNupkgPath
        Method      = 'Put'
        ContentType = 'application/octet-stream; charset=utf-8'
    }

    $response = Invoke-WebRequest @publishParams

    if ($response.StatusCode -ne 200)
    {
        Write-Error -Message ('Failed to publish module to Universal Automation. Status code: [{0}] {1}' -f $response.StatusCode, $response.StatusDescription)
        return
    }

    Write-Build -Color 'Green' -Text ("`tnukpg published to PowerShell Universal Server with version: {0}" -f $ModuleVersion)
}

# Synopsis: Reconcile a PSResourceRepository on the PSU server, then trigger a module install from it.
task publish_module_from_psresource_repos_to_universal_server {
    . Set-SamplerTaskVariable

    $UniversalServer = $BuildInfo.UniversalServer
    if ([string]::IsNullOrEmpty($UniversalServerUrl) -and $UniversalServer.UniversalServerUrl)
    {
        $UniversalServerUrl = $UniversalServer.UniversalServerUrl
    }

    $UniversalServerUrl = $UniversalServerUrl.TrimEnd('/')

    if ([string]::IsNullOrEmpty($UniversalServerAppToken) -and $UniversalServer.UniversalServerAppToken)
    {
        $UniversalServerAppToken = $UniversalServer.UniversalServerAppToken
    }

    if ([string]::IsNullOrEmpty($UniversalServerAppToken))
    {
        Write-Error -Message "UniversalServerAppToken is not set. Define it in `$Env:UniversalServerAppToken = '<token>' or in build.yaml UniversalServer.UniversalServerAppToken."
        return
    }

    if ([string]::IsNullOrEmpty($UniversalPSResourceRepositoryName) -and $UniversalServer.UniversalPSResourceRepositoryName)
    {
        $UniversalPSResourceRepositoryName = $UniversalServer.UniversalPSResourceRepositoryName
    }

    if ([string]::IsNullOrEmpty($UniversalPSResourceRepositoryUrl) -and $UniversalServer.UniversalPSResourceRepositoryUrl)
    {
        $UniversalPSResourceRepositoryUrl = $UniversalServer.UniversalPSResourceRepositoryUrl
    }

    if ($null -ne $UniversalServer.UniversalPSResourceRepositoryAutoRemove -and -not $PSBoundParameters.ContainsKey('UniversalPSResourceRepositoryAutoRemove'))
    {
        $UniversalPSResourceRepositoryAutoRemove = [System.Convert]::ToBoolean($UniversalServer.UniversalPSResourceRepositoryAutoRemove)
    }

    if ([string]::IsNullOrEmpty($UniversalPSResourceRepositoryName) -or [string]::IsNullOrEmpty($UniversalPSResourceRepositoryUrl))
    {
        Write-Error -Message 'UniversalPSResourceRepositoryName and UniversalPSResourceRepositoryUrl are required. Set them under build.yaml UniversalServer or pass them as parameters.'
        return
    }

    $resolvedRepoUrl = $UniversalPSResourceRepositoryUrl
    $isHttpUri = ($resolvedRepoUrl -match '^[a-z][a-z0-9+.-]*://')
    if (-not $isHttpUri)
    {
        $candidatePath = Get-SamplerAbsolutePath -Path $resolvedRepoUrl -RelativeTo $BuildRoot

        if (-not (Test-Path -Path $candidatePath))
        {
            $null = New-Item -Path $candidatePath -ItemType Directory -Force
        }

        $resolvedRepoUrl = $candidatePath
        Write-Build -Color 'DarkGray' -Text ("`tResolved PSResourceRepository url '{0}' to absolute path '{1}'." -f $UniversalPSResourceRepositoryUrl, $resolvedRepoUrl)
    }

    $headers = @{
        Authorization = 'Bearer {0}' -f $UniversalServerAppToken
        Accept        = 'application/json'
    }

    Write-Build -Color 'DarkGray' -Text ("`tQuerying PSResource repositories on {0}" -f $UniversalServerUrl)
    $listUrl = '{0}/api/v1/resourceRepository' -f $UniversalServerUrl
    $existingRepos = @(Invoke-RestMethod -Uri $listUrl -Headers $headers -Method Get)

    $existing = $existingRepos | Where-Object { $_.name -eq $UniversalPSResourceRepositoryName } | Select-Object -First 1

    $needsCreate = $true
    if ($existing)
    {
        $sameUrl     = [string]::Equals([string]$existing.url, [string]$resolvedRepoUrl, [System.StringComparison]::OrdinalIgnoreCase)
        $sameTrusted = [bool]$existing.trusted -eq $true

        if ($sameUrl -and $sameTrusted)
        {
            Write-Build -Color 'Green' -Text ("`tPSResourceRepository '{0}' already matches desired config; skipping re-create." -f $UniversalPSResourceRepositoryName)
            $needsCreate = $false
        }
        else
        {
            if ($UniversalPSResourceRepositoryAutoRemove)
            {
                Write-Build -Color 'Yellow' -Text ("`tPSResourceRepository '{0}' differs (url/trusted); deleting and re-creating." -f $UniversalPSResourceRepositoryName)
                $deleteUrl = '{0}/api/v1/resourceRepository/{1}' -f $UniversalServerUrl, [uri]::EscapeDataString($UniversalPSResourceRepositoryName)
                $null = Invoke-RestMethod -Uri $deleteUrl -Headers $headers -Method Delete
            }
            else
            {
                Write-Build -Color 'Yellow' -Text ("`tPSResourceRepository '{0}' differs (url/trusted) but UniversalPSResourceRepositoryAutoRemove is disabled; using existing repo as-is." -f $UniversalPSResourceRepositoryName)
                $needsCreate = $false
            }
        }
    }
    else
    {
        Write-Build -Color 'DarkGray' -Text ("`tPSResourceRepository '{0}' not found; creating." -f $UniversalPSResourceRepositoryName)
    }

    if ($needsCreate)
    {
        $body = @{
            name    = $UniversalPSResourceRepositoryName
            url     = $resolvedRepoUrl
            trusted = $true
            id      = 0
        }

        $registerParams = @{
            Uri         = $listUrl
            Headers     = $headers
            Method      = 'Post'
            Body        = ($body | ConvertTo-Json -Depth 5)
            ContentType = 'application/json; charset=utf-8'
        }

        $null = Invoke-RestMethod @registerParams
        Write-Build -Color 'Green' -Text ("`tPSResourceRepository '{0}' registered (url={1})." -f $UniversalPSResourceRepositoryName, $resolvedRepoUrl)
    }

    Write-Build -Color 'DarkGray' -Text ("`tTriggering module install '{0}' v{1} from repository '{2}'" -f $ProjectName, $ModuleVersion, $UniversalPSResourceRepositoryName)
    $deployUrl = '{0}/api/v1/deployment/module/{1}/{2}?repository={3}&synchronous=true' -f $UniversalServerUrl, $ProjectName, $ModuleVersion, [uri]::EscapeDataString($UniversalPSResourceRepositoryName)
    $deployParams = @{
        Uri         = $deployUrl
        Headers     = $headers
        Method      = 'Put'
        ContentType = 'application/octet-stream; charset=utf-8'
    }

    try
    {
        $deployResponse = Invoke-WebRequest @deployParams

        if ($deployResponse.StatusCode -ne 200)
        {
            Write-Error -Message ('Failed to install module from repository. Status code: [{0}] {1}' -f $deployResponse.StatusCode, $deployResponse.StatusDescription)
            return
        }

        Write-Build -Color 'Green' -Text ("`tModule '{0}' v{1} installed on PSU from repository '{2}'." -f $ProjectName, $ModuleVersion, $UniversalPSResourceRepositoryName)
    }
    finally
    {
        # Cleanup: Remove the PSResourceRepository if it was auto-created or differs from existing config and auto-remove is enabled.
        if ($UniversalPSResourceRepositoryAutoRemove)
        {
            Write-Build -Color 'DarkGray' -Text ("`tUniversalPSResourceRepositoryAutoRemove enabled; removing PSResourceRepository '{0}' from PSU." -f $UniversalPSResourceRepositoryName)
            $cleanupUrl = '{0}/api/v1/resourceRepository/{1}' -f $UniversalServerUrl, [uri]::EscapeDataString($UniversalPSResourceRepositoryName)

            try
            {
                $null = Invoke-RestMethod -Uri $cleanupUrl -Headers $headers -Method Delete
                Write-Build -Color 'Green' -Text ("`tPSResourceRepository '{0}' removed from PSU." -f $UniversalPSResourceRepositoryName)
            }
            catch
            {
                Write-Warning -Message ("Failed to remove PSResourceRepository '{0}' from PSU: {1}" -f $UniversalPSResourceRepositoryName, $_.Exception.Message)
            }
        }
    }
}
