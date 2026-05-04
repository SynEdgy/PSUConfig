---
name: validate-changes
description: Run targeted PSUConfig test scopes to validate changes quickly and safely, then run the full test suite when needed for confidence before PRs.
argument-hint: What files or areas did you change, and how much validation do you want?
---

# Validate Changes with PSUConfig Tests

## Purpose

Run the right test scope for a change, fast first and broad only when needed.

## Use this skill when

- You changed PowerShell functions under `source/Public` or `source/Private`.
- You changed PSU resource scripts under `source/.universal`.
- You changed the SQLite schema YAML under `source/config`.
- You changed module-scoped state in `source/prefix.ps1` or the manifest `source/PSUConfig.psd1`.
- You changed build wiring (`build.yaml`, `RequiredModules.psd1`, `build.ps1`).
- You need a confidence check before opening or updating a PR.

## Inputs

- `changed_paths`: list of changed files or folders.
- `target_test`: optional single test file path for focused validation.
- `validate_db_init`: optional boolean to also run `Initialize-PSUConfigDB -Force` against a scratch database.

## Decision flow

> **Mandatory:** every command in this skill must be invoked through `./build.ps1`. Do not run `Invoke-Pester` directly, do not call `Build-Module` directly, and do not manually prepend anything to `PSModulePath`. Running `./build.ps1 -ResolveDependency -Tasks noop` (or any other `-Tasks` invocation) is what bootstraps dependencies and wires `PSModulePath` for the current shell so the freshly built module is the one being tested. Direct test/build invocations bypass that setup and may report false results against a stale or incomplete artifact.

1. Bootstrap dependencies if needed.
- Command:
```powershell
./build.ps1 -ResolveDependency -Tasks noop
```

2. Pick the smallest useful test scope first.
- If `target_test` is provided, run only that test file:
```powershell
./build.ps1 -Tasks test -PesterPath '<target_test>' -CodeCoverageThreshold 0
```
- Else if changes are only in a single function area, run the matching unit test file under `tests/Unit/**` (when one exists). The repo currently ships QA tests only — for early-stage modules, fall back to step 3.

3. Expand based on change type.
- Function/manifest/prefix changes → run the default test workflow (QA + any unit tests):
```powershell
./build.ps1 -Tasks test
```
- Schema YAML changes (`source/config/*.PSSqliteConfig.y*ml`) → run the test workflow, then optionally validate DB init end-to-end (see step 4).
- `.universal/*.ps1` changes → these scripts execute inside a deployed PSU instance, not in CI. Verify with `./build.ps1 -Tasks build,pack,deploy` against a dev PSU (requires `secrets.local.ps1`).
- Build wiring changes (`build.yaml`, `RequiredModules.psd1`, `build.ps1`) → re-run with `-ResolveDependency`:
```powershell
./build.ps1 -ResolveDependency -Tasks build,test
```

4. Optional schema validation (`validate_db_init = true`).
- After a successful `build`, apply the schema to a scratch DB to confirm it is well-formed:
```powershell
./build.ps1 -Tasks build
$built = Get-ChildItem output\PSUConfig\*\PSUConfig.psd1 |
    Sort-Object FullName -Descending | Select-Object -First 1
Import-Module $built.FullName -Force
$tmp = Join-Path $env:TEMP ('psuconfig-validate-{0}' -f [guid]::NewGuid())
New-Item -ItemType Directory -Path $tmp | Out-Null
$cfg = Get-PSSqliteDBConfig -ConfigFile (
    Join-Path (Split-Path $built.FullName) 'config\PSUConfig.PSSqliteConfig.yml'
)
$cfg.DatabasePath = $tmp
Initialize-PSSqliteDatabase -DatabaseConfig $cfg -Force -Verbose
Remove-Item $tmp -Recurse -Force
```

## Running these commands without hanging

Always tee `./build.ps1` output to a log file rather than wrapping the call in `| Select-Object -Last <N>` (or any other buffering filter). Inline `Select-Object` against a long-running pipeline forces full-stream buffering and the agent shell appears to hang — even after the build finishes — and would also swallow any unexpected prompt. Instead, stream freely and read the log:

```powershell
if (Test-Path output\validate-test.log) { Remove-Item output\validate-test.log -Force }

./build.ps1 -Tasks test -PesterPath '<paths>' -CodeCoverageThreshold 0 2>&1 |
    Tee-Object -FilePath output\validate-test.log

# Then poll/inspect the log without re-running:
Get-Content output\validate-test.log -Tail 20
Select-String -Path output\validate-test.log -Pattern 'Build (FAILED|succeeded)'
```

When invoked through the `powershell` tool, prefer `mode="async"` with `Tee-Object` and poll periodically — never tail with `| Select -Last N` against a still-running build.

## Diagnosing failures from XML output

Pester writes machine-readable NUnit XML at `output/testResults/NUnitXml_PSUConfig_<Version>.<OS>.PSv.<PSVersion>.xml`. Read those instead of grepping the build log — they tell you *which* tests failed and *why*. Each failing assertion is a `<test-case result="Failure">` node with the message under `<failure><message>`:

```powershell
$latest = Get-ChildItem output\testResults\NUnitXml_PSUConfig_*.xml |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
[xml]$x = Get-Content $latest.FullName
$x.SelectNodes('//test-case[@result="Failure"]') | ForEach-Object {
    "==FAIL==`n$($_.name)`n$($_.failure.message)`n"
}
```

- Always pick the **latest** result file (`Sort-Object LastWriteTime -Descending`); each invocation rewrites these XML files.
- When reporting a failure to the user, quote the XML's assertion message — do not paraphrase the build-log tail.

## Completion checks

- All selected test commands exit successfully.
- For schema YAML changes: optional `Initialize-PSSqliteDatabase` against a scratch DB succeeds.
- For function changes: relevant unit tests (when present) and QA tests pass.
- If behavior is user-visible (new/changed public function, `[APIEndpoint]` attribute, schema bump): ensure `CHANGELOG.md` has an `Unreleased` entry.

## Report format

Return a short summary with:
- Commands run
- Pass/fail per scope
- Any failing test file paths
- Suggested next command (if failures occurred)

## Example prompts

- "Validate my edits in `source/Public/Initialize-PSUConfigDB.ps1` quickly."
- "I added a `roles` table to `source/config/PSUConfig.PSSqliteConfig.yml`; run the right tests and validate DB init."
- "Run full validation for my current branch."
