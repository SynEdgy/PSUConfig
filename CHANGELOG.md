# Changelog for PSUConfig

The format is based on and uses the types of changes according to [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added English, French, and German localization for the Home page, navigation,
  Users page header, and job execution page header with a top-right language
  selector. The browser `Accept-Language` header provides the request preference,
  the active environment's `DefaultUILanguage` provides the fallback, and an
  explicit selection persists in the `PSUConfigLanguage` cookie and takes
  precedence.
- Added server-start localization cache initialization using a PSU
  `ServerStarted` trigger and the PSUConfig environment's shared `$Cache:`
  scope, with on-demand initialization when the cache is not yet available
  after deployment. Available languages are discovered from the module's
  culture resource folders instead of being duplicated in the initializer.
- Added a reusable language selector through
  `synedgy.universal.helper\New-UDLanguageSelector`. It discovers PSUConfig's
  resource-backed cultures from the caller module, persists the explicit
  selection in a cookie, and renders compact `EN`, `FR`, and `DE` labels in a
  styled app-bar control.
- Added a `PSUConfigDemo` app (`Apps/PSUConfigDemo`) and `New-PSUConfigDemoConsole`
  public function demonstrating the shared job UI components
  (`New-UDPsuJobHeader`, `New-UDPsuJobTerminalView`) from `synedgy.universal.helper`.
- Added `Get-PSUConfigAppPath` public function used by the `PSUConfigDemo` app
  to resolve its bundled app folder at runtime.
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

- Pinned `synedgy.universal.helper` to the released
  `0.3.0-preview0002` package and removed its local workspace override so builds
  and deployments use the published dependency.
- Moved generic language preference resolution and localization cache
  initialization into `synedgy.universal.helper`. Deferred dashboard callbacks
  now use `Get-PSUConfigModule` and pass `ModuleBase` explicitly instead of
  relying on module-owned resolver and selector wrappers.
- Added named localization bundle support to `Get-PSUConfigLocalizedData` and
  nested the app-wide cache by resource name and language so pages can load
  independent bundles such as `PSUConfig.Users`.
- Added English and French `PSUConfig.Users` resource bundles for the Users
  page heading and description.
- Localized `New-PSUConfigAddUserButton` through component-owned
  `PSUConfig.AddUserButton.strings.psd1` resources. The component receives the
  requested language, falls back through the module default and English, and
  stores the selected dictionary in page scope for deferred modal callbacks.
- Localized `New-PSUConfigUserForm` and `New-PSUConfigUserTable` through
  component-owned English and French resources. Field labels, submit and
  validation messages, table columns, edit/remove dialogs, and result toasts
  now follow the page-selected language through deferred callbacks.
- Passed the PSUConfig page-selected language and configured default to the
  shared localized `New-UDPsuJobHeader` and `New-UDPsuJobTerminalView`
  components on the job details page.
- Updated language resolution to use the active environment's configured
  `DefaultUILanguage` when neither the language cookie nor the request headers
  select a supported localization resource.
- Replaced permission-protected PSU server-cache commands with the execution
  environment's shared `$Cache:` scope for anonymous dashboard localization.
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
- Added a permanent Users navigation page backed by the reusable
  `New-PSUConfigUserTable` dashboard component and `Get-PSUConfigUser`.
- Added a floating add-user action and reusable `New-PSUConfigUserForm` modal
  that creates records through `New-PSUConfigUser` and refreshes the Users table.
- Added Edit and Remove columns to the PSUConfig Users table. Edit opens the
  shared user form with existing values and saves through `Set-PSUConfigUser`;
  Remove requires explicit modal confirmation before calling
  `Remove-PSUConfigUser`.

### Fixed

- Enabled free-text search across the PSUConfig Users table data columns by
  explicitly including them in Universal Dashboard search.
