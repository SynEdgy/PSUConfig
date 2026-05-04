# PSUConfig

PowerShell module that ships a PowerShell Universal (PSU) instance configuration. Built with the Sampler scaffold and ModuleBuilder.

## Build / Test / Deploy

- Resolve dependencies into `output/RequiredModules/` and run default workflow (`build`, `test`):
  - `./build.ps1 -ResolveDependency`
- Build only: `./build.ps1 -Tasks build`
- Run all Pester tests: `./build.ps1 -Tasks test`
- Run a single test file directly (after a build, so the module exists in `output/`):
  - `Invoke-Pester -Path ./tests/QA/module.tests.ps1 -Output Detailed`
- Pack as nupkg and deploy to a PSU instance:
  - `. ./secrets.local.ps1; ./build.ps1 -Tasks build,pack,deploy`
- `secrets.local.ps1` (gitignored) must set `$Env:UniversalServerUrl` and `$Env:UniversalServerAppToken` for `deploy`.
- Code-coverage threshold is set in `build.yaml` under `Pester.CodeCoverageThreshold` (currently `1`).

## Architecture

- `source/` is the ModuleBuilder source. `PSUConfig.psm1` is regenerated at build; do not put runtime code there. Use `source/prefix.ps1` for module-scoped state (e.g. `$script:MyModuleDBConfig`).
- Public functions in `source/Public/` are auto-exported. Private helpers in `source/Private/` are not. New files added here are picked up automatically.
- Built module is emitted to `output/<ModuleName>/<version>/module/` (`BuiltModuleSubdirectory: module`, `VersionedOutputDirectory: true`).
- `build.yaml` `CopyPaths` copies `en-US`, `.universal`, `images`, `config`, `scripts`, `tests` from `source/` into the built module verbatim.
- `NestedModule` in `build.yaml` bundles `powershell-yaml`, `synedgy.PSSqlite`, `synedgy.universal.helper`, and `pester` from `output/RequiredModules/` into `<built>/Modules/` and adds them to the manifest.
- `source/.universal/` holds PSU configuration scripts (`authentication.ps1`, `endpoints.ps1`, `environments.ps1`, `roles.ps1`, `scripts.ps1`, `triggers.ps1`, `variables.ps1`, etc.). These are consumed by the target PSU instance after deploy, not by the module at import time.
- `source/.universal/endpoints.ps1` imports the module then calls `Import-PSUEndpoint -Module PSUConfig` (from `synedgy.universal.helper`) to publish any function decorated with `[APIEndpoint(...)]` as a PSU REST endpoint. See `source/Public/Get-Something.ps1` for the attribute pattern.
- SQLite config lives in `source/config/PSUConfig.PSSqliteConfig.yml`. `Get-myModuleConfig` (Private) loads it via `synedgy.PSSqlite`'s `Get-PSSqliteDBConfigFile` / `Get-PSSqliteDBConfig`, caches it in `$script:MyModuleDBConfig`, and `Initialize-PSUConfigDB` applies it with `Initialize-PSSqliteDatabase`. New tables go in the YAML `schema.Tables` block.

## Conventions

- Versioning is driven by GitVersion (`GitVersion.yml`); do not bump `ModuleVersion` in `source/PSUConfig.psd1` manually.
- Tests run against the built module under `output/PSUConfig/<version>/`; always build before invoking Pester directly.
- AI instruction files under `.github/` follow `.github/instructions/ai-instruction-authoring.instructions.md`.

## External references

- PowerShell Universal: https://docs.powershelluniversal.com/. When working on `source/.universal/` scripts or anything that calls `Set-PSU*`/`New-PSU*`/`Import-PSU*`, fetch the relevant docs page to confirm cmdlet shape and PSU resource semantics rather than relying on memory.
- PSU docs source (markdown, grep-friendly): https://github.com/ironmansoftware/universal-docs/tree/v5.

## Scoped instruction files

- `source/Public/*.ps1` → `.github/instructions/public-functions.instructions.md` (covers `[APIEndpoint]`, `[Parameter(DontShow)]` config injection, `ShouldProcess`).
- `source/Private/*.ps1` → `.github/instructions/private-functions.instructions.md` (covers module-scoped state in `prefix.ps1`, cache patterns).
- `source/.universal/*.ps1` → `.github/instructions/universal-scripts.instructions.md` (PSU resource scripts: idempotency, endpoint registration, role alignment).
- `source/config/*.PSSqliteConfig.y*ml` → `.github/instructions/sqlite-config.instructions.md` (schema YAML mapping to `[SqliteTable]`/`[SqliteColumn]`, `_metadata` versioning, migration modes).
- `source/{Public,Private}/**/*.ps1` → `.github/instructions/data-access.instructions.md` (`synedgy.PSSqlite` CRUD usage: `ClauseData` semantics, wildcards, `Before`/`After` suffixes, connection lifetime).
- `tests/**/*.Tests.ps1` → `.github/instructions/test-writing.instructions.md` (Pester 5 blueprint, mocking, assertion style).

## Skills

- `.github/skills/validate-changes/SKILL.md` — decision flow for picking the smallest useful test scope, streaming `./build.ps1` output via `Tee-Object`, and parsing failures from `output/testResults/NUnitXml_PSUConfig_*.xml`. Follow it before opening or updating a PR.
