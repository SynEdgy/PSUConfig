---
description: "PowerShell Universal authoring instructions"
applyTo: "{source/.universal/**/*.ps1,source/PSUConfig.psd1,build.yaml,.build/PowerShellUniversal.publish.Build.ps1}"
---

## PowerShell Universal configuration and deployment

- Keep `.universal` loaders simple and deterministic.
- In `source/.universal/*.ps1`, import modules by module name or `$ModuleFile`; avoid dynamic manifest discovery logic unless explicitly requested.
- Keep the module manifest dependency contract in `source/PSUConfig.psd1`:
  - put runtime dependencies in `RequiredModules`
  - keep `PrivateData.PSData.ExternalModuleDependencies` empty unless an external gallery dependency is intentionally required.
- Keep PSU publish orchestration in `build.yaml` workflows and `.build/PowerShellUniversal.publish.Build.ps1`; do not spread deployment logic into runtime module code.
- Keep `pack` focused on packaging; keep PSU deployment steps in `deploy`.
- Always run `./build.ps1 -Tasks pack` explicitly before `./build.ps1 -Tasks deploy` (or immediately
  before it in the same session), even though `deploy` lists `pack` as a prerequisite step.
  Invoke-Build's incremental build detection can silently skip `pack` if it believes outputs are
  already up to date, leaving stale or missing `output/*.nupkg` files. This causes the PSU
  deployment call to succeed (HTTP 200) while doing nothing, or to fail server-side with errors
  like "Unable to find repository with Name 'output'" or "Error loading module ... as root module.
  Module not found" that only show up in the PSU admin UI / server logs, not in the build task
  output.
- Never directly modify, delete, or otherwise touch files under PSU's live Repository folder
  (e.g. `C:\ProgramData\UniversalAutomation\Repository` / its `Modules` subfolder). Only
  `./build.ps1 -Tasks deploy` should ever change files there. Manually deleting/editing files while
  PSU holds file locks can corrupt the running instance (including unrelated modules) and require a
  full service restart to recover.
- If a deployment does not appear to have taken effect (new resources/pages not showing up), re-run
  `pack` then `deploy` and check the PSU admin UI / system log for errors rather than editing the
  Repository directly. If the server appears stuck (stale logs, deploys completing suspiciously
  fast, resources not registering), ask the user to restart the PowerShellUniversal service --
  do not attempt to restart Windows services yourself without explicit user action.
- `Get-PSUScript -Name` requires the full `<ModuleName>\<Command>` path (e.g.
  `'PSUConfig\Get-myUser'`), not just the command name -- scripts registered via
  `New-PSUScript -Module ... -Command ...` are named `<Module>\<Command>`.
- `Invoke-PSUScript -Integrated -Wait` reliably returns a job object with an empty `Id` on this
  PSU version (100% reproducible across 130 test invocations); omit `-Wait` when the job `Id` is
  needed immediately (e.g. to redirect to a job detail page) -- without `-Wait`, `Id` is reliably
  populated. See `bug-psu-invoke-psuscript-wait-empty-job-id.md` in ComsolCentral's `docs/bug/`
  for details and reproduction statistics.
- `$Env:UniversalServerAppToken` and `$Env:UniversalServerUrl` are build/deploy-only variables (used for local publish via `secrets.local.ps1` and post-deploy checks). Never use them in PSU runtime code (scripts, apps, dashboards). In runtime, use a `$secret:` variable or another PSU-declared variable from `source/.universal/variables.ps1`.
- Use `Invoke-RestMethod` for PSU API checks; do not use `curl`.

## Database schema migrations

- Schema migrations in INCREMENTAL mode only add missing tables or columns; they do not remove or
  rename existing columns, so a normal deploy is non-destructive for additive changes.
- When a schema change involves **removing, renaming, or significantly altering** table columns
  (not just adding), the `Initialize-PSUConfigDB` script must be run with `-Force` to overwrite and
  rebuild the schema. `-Force` deletes the existing db file and creates a new one.
- Invoke the `Initialize-PSUConfigDB` script from the PSU GUI or via API (e.g.
  `Invoke-PSUScript -Name 'PSUConfig\Initialize-PSUConfigDB'`) after deploying such schema changes;
  do not rely on automatic INCREMENTAL migration.
