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
    [System.Collections.Hashtable]
    $BuildInfo = (property BuildInfo @{ })
)

task publish_packed_module_to_universal_server {
    . Set-SamplerTaskVariable
    "`tBuilt Module Subdirectory  = '$OutputDirectory'"
    $builtNupkgPath = Join-Path -Path $OutputDirectory -ChildPath "$ProjectName.$ModuleVersion.nupkg"
    "`tExpected nupkg file  = '$builtNupkgPath'"
    if (Test-Path -Path $builtNupkgPath)
    {
        Write-Build -Color 'Green' -Text "`tnukpg found at path: $builtNupkgPath"
    }
    else
    {
        Write-Error -Message "`tModule nupkg not found at path: $builtNupkgPath"
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
    $response = Invoke-WebRequest -Uri "$universalServerUrl/api/v1/deployment?asModule=true" -Headers @{
        "Authorization" = "Bearer $UniversalServerAppToken"
    } -InFile $builtNupkgPath -Method Put -ContentType "application/octet-stream"

    if ($response.StatusCode -ne 200)
    {
        Write-Error -Message "Failed to publish module to Universal Automation. Status code: [$($response.StatusCode)] $($response.StatusDescription)"
        return
    }

    Write-Build -Color 'Green' -Text "`tnukpg published to PowerShell Universal Server with version: $ModuleVersion"
}
