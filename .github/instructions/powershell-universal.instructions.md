---
description: "PowerShell Universal authoring instructions"
applyTo: "{source/.universal/**/*.ps1,source/PSUConfig.psd1,build.yaml,RequiredModules.psd1}"
---

## PowerShell Universal configuration and deployment

- Keep `.universal` loaders simple and deterministic.
- In `source/.universal/*.ps1`, import modules by module name or `$ModuleFile`; avoid dynamic manifest discovery logic unless explicitly requested.
- Keep the module manifest dependency contract in `source/PSUConfig.psd1`:
  - put runtime dependencies in `RequiredModules`
  - keep `PrivateData.PSData.ExternalModuleDependencies` empty unless an external gallery dependency is intentionally required.
- Use the `Sampler.PowerShellUniversalTasks` build-task module for PSU packaging and deployment orchestration; keep workflow composition in `build.yaml` and do not spread deployment logic into runtime module code.
- Keep `pack` focused on packaging; keep PSU deployment steps in `deploy`.
- Always run `./build.ps1 -Tasks pack` explicitly before `./build.ps1 -Tasks deploy` (or immediately
  before it in the same session) so the standard module package is also validated.
- The `deploy` workflow builds the module, runs `publish_psu_push_repository`, and fails when PSU
  reports a deployment error notification. It does not require or register an `output`
  PSResourceRepository on the server.
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
  `'PSUConfig\Get-PSUConfigUser'`), not just the command name -- scripts registered via
  `New-PSUScript -Module ... -Command ...` are named `<Module>\<Command>`.
- `Invoke-PSUScript -Integrated -Wait` reliably returns a job object with an empty `Id` on this
  PSU version (100% reproducible across 130 test invocations); omit `-Wait` when the job `Id` is
  needed immediately (e.g. to redirect to a job detail page) -- without `-Wait`, `Id` is reliably
  populated. See `bug-psu-invoke-psuscript-wait-empty-job-id.md` in ComsolCentral's `docs/bug/`
  for details and reproduction statistics.
- `$Env:UniversalServerAppToken` and `$Env:UniversalServerUrl` are build/deploy-only variables (used for local publish via `secrets.local.ps1` and post-deploy checks). Never use them in PSU runtime code (scripts, apps, dashboards). In runtime, use a `$secret:` variable or another PSU-declared variable from `source/.universal/variables.ps1`.
- Use `Invoke-RestMethod` for PSU API checks; do not use `curl`.

## Job/script access authorization (AppToken vs -Integrated)

- Prefer an app token via the Management API (`-AppToken`/`-ComputerName`) as the **primary** way
  to read jobs/scripts from dashboard pages that display job info (e.g. `New-UDPsuJobHeader`,
  `New-UDPsuJobTerminalView`). Use `-Integrated` only as a **fallback** when no token is
  configured (e.g. quick local setup without secrets).
- `-Integrated` bypasses PSU's Management API -- and therefore its role/permission checks --
  entirely. Code using `-Integrated` can read/execute **any** job or script in the instance,
  regardless of any role configuration. An app token, by contrast, is bound to whatever role it is
  assigned, is revocable, and is auditable.
- Caveat: today, the only permission that grants job-read access at all (`automation/read`) is
  itself unscoped -- it grants read access to every job in the instance, not just jobs from a
  specific script (see ComsolCentral's `docs/bug/bug-psu-no-per-script-job-read-permission.md`,
  submitted to Devolutions and confirmed as being fixed). So switching to an app token does not
  yet achieve per-script job scoping, but it is still the right default: it keeps access inside
  PSU's authorization model (auditable, revocable, and forward-compatible once the scoped
  job-read fix ships), whereas `-Integrated` sits outside that model entirely and would remain
  unaffected even after that fix.
- See `source/.universal/roles.ps1` (`psuconfig_automation_bot` role) and
  `source/.universal/variables.ps1` (`psuconfig_automation_bot_token` secret variable) for the
  scoped-token pattern, mirroring ComsolCentral's `comsol_automation_bot` role and
  `comsol_automation_bot_token` secret.

## Database schema migrations

- Schema migrations in INCREMENTAL mode only add missing tables or columns; they do not remove or
  rename existing columns, so a normal deploy is non-destructive for additive changes.
- When a schema change involves **removing, renaming, or significantly altering** table columns
  (not just adding), the `Initialize-PSUConfigDB` script must be run with `-Force` to overwrite and
  rebuild the schema. `-Force` deletes the existing db file and creates a new one.
- Invoke the `Initialize-PSUConfigDB` script from the PSU GUI or via API (e.g.
  `Invoke-PSUScript -Name 'PSUConfig\Initialize-PSUConfigDB'`) after deploying such schema changes;
  do not rely on automatic INCREMENTAL migration.
