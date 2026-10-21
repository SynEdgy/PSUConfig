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
- Added `[AiTool()]` attributes to `Find-UserByCity` and `New-myUser`, and replaced
  `source/.universal/mcpTools.ps1` (which called the non-existent `New-PsuMcpTool`
  cmdlet) with a single `Import-PSUAiTool -Module PSUConfig -Environment "PSUConfig"`
  call, mirroring the existing `[APIEndpoint()]` / `Import-PSUEndpoint` pattern.
- Initial changelog created.

### Changed

- Moved the SQLite database outside PSU's deployed repository so full repository
  deployments do not replace runtime data.
- Removed bundled `NestedModule` packaging of `powershell-yaml`, `synedgy.PSSqlite`,
  and `synedgy.universal.helper` from `build.yaml`. These are now resolved solely
  as ordinary `RequiredModules` dependencies (see `source/PSUConfig.psd1`), which
  also allows `synedgy.universal.helper` to be linked live from the workspace via
  `WorkspaceModules` during local builds.
