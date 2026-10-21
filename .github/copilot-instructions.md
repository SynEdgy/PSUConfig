# PSUConfig

PowerShell module that ships a PowerShell Universal (PSU) instance configuration. Built with the Sampler scaffold and ModuleBuilder.

## Build / Test / Deploy

- Use `./build.ps1` as the only entry point for build, test, and environment setup.
- Do not call `Build-Module`, `Invoke-Pester`, or `Invoke-Build` directly.
- Do not manually modify `PSModulePath`.
- Resolve dependencies and run the default workflow: `./build.ps1 -ResolveDependency`
- Bootstrap dependencies only: `./build.ps1 -ResolveDependency -Tasks noop`
- Build only: `./build.ps1 -Tasks build`
- Run all Pester tests: `./build.ps1 -Tasks test`
- Run a focused test: `./build.ps1 -Tasks test -PesterPath 'tests/Unit/Public/MyFunction.Tests.ps1' -CodeCoverageThreshold 0`
- Run the quality gate: `./build.ps1 -Tasks hqrmtest`
- Pack explicitly before deployment:
  ```powershell
  . ./secrets.local.ps1
  ./build.ps1 -Tasks pack
  ./build.ps1 -Tasks deploy
  ```
- `secrets.local.ps1` is gitignored and must set `$Env:UniversalServerUrl` and `$Env:UniversalServerAppToken`.
- Code coverage is configured in `build.yaml` under `Pester.CodeCoverageThreshold`.

## Git workflow

- Never commit, push, tag, or publish on behalf of the user.

## Architecture

- `source/` is the ModuleBuilder source. `PSUConfig.psm1` is generated; do not edit it directly.
- Use `source/prefix.ps1` for module-scoped state such as `$script:MyModuleDBConfig`.
- Public functions in `source/Public/` are auto-exported. Private helpers in `source/Private/` are not.
- The built module is emitted beneath `output/PSUConfig/<version>/`.
- `build.yaml` `CopyPaths` copies runtime assets from `source/` into the built module.
- Runtime dependencies are declared as ordinary `RequiredModules`; local workspace dependencies are linked during builds.
- `source/.universal/` contains PSU configuration scripts consumed after deployment, not during module import.
- `source/.universal/endpoints.ps1` imports attributed endpoints through `Import-PSUEndpoint -Module PSUConfig`.
- SQLite configuration lives in `source/config/PSUConfig.PSSqliteConfig.yml`.
- `Get-myModuleConfig` loads and caches the SQLite config; `Initialize-PSUConfigDB` applies it.

## Deployment safety

- Never modify PSU's live Repository folder directly.
- Only `./build.ps1 -Tasks deploy` may update the live repository.
- Run `./build.ps1 -Tasks pack` explicitly before deploy; do not rely only on deploy prerequisites.
- `deploy` uses `publish_psu_push_repository` and validates PSU deployment notifications.
- See `.github/instructions/powershell-universal.instructions.md` for deployment details.

## Conventions

- Versioning is driven by GitVersion; do not manually bump `source/PSUConfig.psd1`.
- Tests run against the built module, not directly against `source/`.
- Update `CHANGELOG.md` only for user-visible behavior changes under `## [Unreleased]`.
- Do not add changelog entries for CI, pipeline, or tooling-only changes.
- Use ASCII in `.ps1` files and `CHANGELOG.md`.
- Prefer splatting over backtick continuation.
- Use `$null = <expression>` rather than piping to `Out-Null`.
- Use explicit .NET types and DSC Community parameter layout.
- Build multi-level paths with chained `Join-Path` calls; do not embed separators in `-ChildPath`.
- Follow `.github/instructions/ai-instruction-authoring.instructions.md` when editing AI guidance.

## Long-running commands

- Tee build output to `output/agentic/`, which survives the Clean task:
  ```powershell
  $null = New-Item -Path 'output/agentic' -ItemType Directory -Force
  ./build.ps1 -Tasks test 2>&1 |
      Tee-Object -FilePath 'output/agentic/test.log'
  ```
- Inspect progress with `Get-Content output/agentic/test.log -Tail 20`; do not rerun a still-running build.

## External references

- PowerShell Universal: https://docs.powershelluniversal.com/
- PSU docs source: https://github.com/ironmansoftware/universal-docs/tree/v5
- Confirm PSU cmdlet signatures and resource semantics from the documentation before changing `.universal` scripts.

## Scoped instruction files

- `source/Public/**/*.ps1` -> `.github/instructions/public-functions.instructions.md`
- `source/Private/**/*.ps1` -> `.github/instructions/private-functions.instructions.md`
- `source/.universal/*.ps1` -> `.github/instructions/universal-scripts.instructions.md`
- `source/config/*.PSSqliteConfig.y*ml` -> `.github/instructions/sqlite-config.instructions.md`
- `source/{Public,Private}/**/*.ps1` -> `.github/instructions/data-access.instructions.md`
- `tests/**/*.Tests.ps1` -> `.github/instructions/test-writing.instructions.md`
- `**/*.ps1` -> `.github/instructions/http-conventions.instructions.md`
- `**/*.ps1` -> `.github/instructions/powershell-style.instructions.md`
- Build task files -> `.github/instructions/build-task-files.instructions.md` and `.github/instructions/build-tasks.instructions.md`
- Classes and enums -> `.github/instructions/classes-and-type-accelerators.instructions.md`
- PSU resources -> `.github/instructions/powershell-universal.instructions.md`
- Wiki publishing -> `.github/instructions/wiki-publishing.instructions.md`

## Skills

- `.github/skills/validate-changes/SKILL.md` defines targeted and full validation workflows. Follow it before opening or updating a PR.
