# Changelog for PSUConfig

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added a `PSUConfigDemo` app (`Apps/PSUConfigDemo`) and `New-PSUConfigDemoConsole`
  public function demonstrating the shared job UI components
  (`New-UDPsuJobHeader`, `New-UDPsuJobTerminalView`) from `synedgy.universal.helper`.
- Added `Get-UDAppPath` public function used by the `PSUConfigDemo` app to resolve
  its bundled app folder at runtime.
- Added a `psuconfig_automation_bot` role and `psuconfig_automation_bot_token` secret
  variable (`source/.universal/roles.ps1`, `source/.universal/variables.ps1`) so the
  `PSUConfigDemo` app can read job status/output via a scoped app token (Management
  API) instead of `-Integrated`, which bypasses PSU's authorization model entirely.
  `-Integrated` remains a fallback when no token is configured.
- Added `[AiTool()]` attributes to `Find-UserByCity` and `New-PSUConfigUser`, and replaced
  `source/.universal/mcpTools.ps1` (which called the non-existent `New-PsuMcpTool`
  cmdlet) with a single `Import-PSUAiTool -Module PSUConfig -Environment "PSUConfig"`
  call, mirroring the existing `[APIEndpoint()]` / `Import-PSUEndpoint` pattern.
- Added environment-aware module configuration with DEV, QA, and PROD PowerShell
  Universal URLs, following the ComsolCentral cached YAML configuration pattern.
- Initial changelog created.

### Changed

- Moved the SQLite database outside PSU's deployed repository so full repository
  deployments do not replace runtime data.
- Removed bundled `NestedModule` packaging of `powershell-yaml`, `synedgy.PSSqlite`,
  and `synedgy.universal.helper` from `build.yaml`. These are now resolved solely
  as ordinary `RequiredModules` dependencies (see `source/PSUConfig.psd1`), which
  also allows `synedgy.universal.helper` to be linked live from the workspace via
  `WorkspaceModules` during local builds.
- Updated the PSUConfig demo to resolve its management API URL from the active
  environment configuration, including live job-output refreshes.
- Renamed the sample `myUser` table and CRUD surface to `psuConfigUser` and
  `*-PSUConfigUser` to reflect that the records are internal to PSUConfig.
- Redesigned the PSUConfig demo with SynEdgy branding and the SITF visual
  language, centered on module-first PSU configuration and Sampler delivery,
  with switchable dark and light themes.
- Extracted reusable light/dark palettes, typography, shape, and component
  overrides into a dedicated PSU MUI theme file.
- Fixed dashboard cards to use explicit vertical layouts so descriptions render
  below their titles at every responsive grid size.
- Added `Get-PSUConfigDatabaseAnalysis` and a dashboard action that runs it as a
  PSU job to report live table record counts and the stored SQLite schema version.
