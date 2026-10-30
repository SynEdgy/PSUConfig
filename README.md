# PSUConfig

PSUConfig is a SynEdgy demonstration of module-first PowerShell Universal
configuration management and deployment. A single PowerShell module contains
the commands, data schema, application, APIs, AI tools, jobs, roles, variables,
environments, and PSU resource declarations, while Sampler provides the
repeatable build, test, package, and deployment framework.

## Usage

Create a file named `secrets.local.ps1` at the root of your project with the
following content.  
This file is ignored by git and can be used to store secrets for local
development for development purposes. You can set the Universal Server URL
and App Token in this file to allow the build script to publish modules directly
to your Universal Automation instance.

```powershell
# ./secrets.local.ps1
$Env:UniversalServerUrl = 'http://localhost:5000'
Write-Warning -Message ('Importing secret. Universal URL: {0}' -f $Env:UniversalServerUrl)
$Env:UniversalServerAppToken = 'e....4' # insert your token here

```

Once you have the `secrets.local.ps1` file created, you can run the build script
to build and publish your module to PowerShell Universal.

```powershell
. .\secrets.local.ps1 
.\build.ps1 -Tasks build,pack,deploy
```

## Environment configuration

Runtime URLs are defined in `source/config/PSUConfig.config.yml` for the `DEV`,
`QA`, and `PROD` environments. `Get-CurrentEnvironment` selects the environment
from an explicit parameter, `$Env:ServerEnvironment`, or machine defaults.
`Get-PSUConfigSetting` returns the merged settings for the active environment.

```powershell
Set-PSUConfigSetting -Environment QA -Confirm:$false
```

The cached configuration is shared by module commands and the PSUConfig demo.

## Generated resources

Public module commands decorated with `APIEndpoint` are discovered and
registered automatically through `synedgy.universal.helper`. The same
module-first approach is used for scripts and AI tools, keeping PSU resource
declarations close to the commands they expose.

See [Generated API endpoints](docs/api-endpoints.md) for dependency loading,
attribute discovery, AST-based wrapper generation, route registration, and
current limitations, including parser-safe enum, switch, and PowerShell class
parameters.

## Documentation

- [Documentation index](docs/README.md)
- [Generated API endpoints](docs/api-endpoints.md)
- [PSU `Invoke-PSUScript`, `-Confirm`, and `ShouldProcess`](docs/psu-invoke-psuscript-confirm-shouldprocess.md)
- [PSU translation locale fallback](docs/psu-translation-locale-fallback.md)
