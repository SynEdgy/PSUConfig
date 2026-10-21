---
name: validate-changes
description: Run targeted PSUConfig validation first, then broaden to the full suite or deployment checks when the changed surface requires it.
argument-hint: What files or areas changed, and how much validation is required?
---

# Validate PSUConfig Changes

## Use this skill when

- Public or private PowerShell functions changed.
- Classes or enums changed.
- PSU resource scripts under `source/.universal` changed.
- SQLite schema YAML changed.
- Module state, manifest, build logic, or dependency wiring changed.
- A PR-bound change needs confidence checks.

## Inputs

- `changed_paths`: changed files or directories.
- `target_test`: optional focused test path.
- `validate_db_init`: optionally initialize a scratch SQLite database.
- `run_quality_gate`: optionally run HQRM checks.

## Mandatory execution rules

- Run build and test operations only through `./build.ps1`.
- Do not call `Invoke-Pester`, `Build-Module`, or `Invoke-Build` directly.
- Do not manually modify `PSModulePath`.
- Bootstrap dependencies with:
  ```powershell
  ./build.ps1 -ResolveDependency -Tasks noop
  ```

## Decision flow

1. Run the smallest relevant test scope.
   ```powershell
   ./build.ps1 -Tasks test -PesterPath '<target_test>' -CodeCoverageThreshold 0
   ```
2. For public/private function changes, run matching unit tests.
3. For build wiring changes, run:
   ```powershell
   ./build.ps1 -ResolveDependency -Tasks build,test
   ```
4. For schema changes, run tests and optionally initialize a scratch database.
5. For `.universal` changes, build and pack, then deploy only to a development PSU using the repository deployment workflow.
6. For workflow-impacting changes, run relevant integration tests.
7. Before declaring a PR-bound change complete, run:
   ```powershell
   ./build.ps1 -Tasks test
   ```
8. If requested, run:
   ```powershell
   ./build.ps1 -Tasks hqrmtest
   ```

## Scratch database validation

After a successful build:

```powershell
$built = Get-ChildItem output/PSUConfig/*/PSUConfig.psd1 |
    Sort-Object FullName -Descending |
    Select-Object -First 1
Import-Module $built.FullName -Force
$tmp = Join-Path $env:TEMP ('psuconfig-validate-{0}' -f [guid]::NewGuid())
$null = New-Item -ItemType Directory -Path $tmp
$configPath = Join-Path (Split-Path $built.FullName) 'config'
$configPath = Join-Path $configPath 'PSUConfig.PSSqliteConfig.yml'
$cfg = Get-PSSqliteDBConfig -ConfigFile $configPath
$cfg.DatabasePath = $tmp
Initialize-PSSqliteDatabase -DatabaseConfig $cfg -Force -Verbose
Remove-Item $tmp -Recurse -Force
```

## Long-running commands

Tee output to `output/agentic/` so logs survive Clean:

```powershell
$null = New-Item -Path 'output/agentic' -ItemType Directory -Force

./build.ps1 -Tasks test -PesterPath '<paths>' -CodeCoverageThreshold 0 2>&1 |
    Tee-Object -FilePath 'output/agentic/test.log'
```

Inspect progress with:

```powershell
Get-Content output/agentic/test.log -Tail 20
```

Do not rerun a still-running build.

## Diagnose failures

Read the latest NUnit XML under `output/testResults/`:

```powershell
$latest = Get-ChildItem output/testResults/NUnitXml_*.xml |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
[xml]$result = Get-Content $latest.FullName
$result.SelectNodes('//test-case[@result="Failure"]') | ForEach-Object {
    "==FAIL==`n$($_.name)`n$($_.failure.message)`n"
}
```

- Quote assertion messages from XML when reporting failures.
- Do not infer failures only from a build-log tail.

## Completion checks

- Selected commands exit successfully.
- Relevant focused tests pass.
- Full tests pass for PR-bound changes.
- Scratch database initialization passes when requested.
- User-visible behavior changes have an `Unreleased` changelog entry.

## Report

- List commands run.
- Report pass or fail for each scope.
- List failing test paths and XML messages.
- Suggest the next command only when failures remain.
