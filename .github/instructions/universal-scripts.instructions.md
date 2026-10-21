---
description: 'PowerShell Universal configuration script instructions'
applyTo: 'source/.universal/*.ps1'
---

# PSU Configuration Script Guidelines

Files in `source/.universal/` are not module code. They are copied verbatim into the built module (`build.yaml` `CopyPaths`) and executed by the target PSU instance to configure it on deploy.

## Reference

- Authoritative PSU documentation: https://docs.powershelluniversal.com/. Consult it before adding or changing PSU resource calls; verify cmdlet name, parameter set, and idempotency contract against the docs for that resource (APIs, Endpoints, Environments, Variables, Roles, Schedules, Triggers, Scripts, Settings).
- Docs source (often more searchable / current than the rendered site): https://github.com/ironmansoftware/universal-docs/tree/v5. Use it for grep-style lookups across PSU topics.
- When a behavior is unclear, fetch the relevant docs page (e.g. `https://docs.powershelluniversal.com/api/<topic>` or `https://docs.powershelluniversal.com/config/<topic>`) instead of guessing.

## Scope per file

- One concern per file, named after the PSU resource type: `authentication.ps1`, `endpoints.ps1`, `environments.ps1`, `eventHubs.ps1`, `mcpTools.ps1`, `publishedFolders.ps1`, `roles.ps1`, `schedules.ps1`, `scripts.ps1`, `settings.ps1`, `triggers.ps1`, `variables.ps1`.
- Do not add new top-level files unless they map to a distinct PSU resource type.
- Use only PSU cmdlets (`Set-PSU*`, `New-PSU*`, `Import-PSU*`) and `synedgy.universal.helper` cmdlets. Do not call into `PSUConfig` private helpers from these scripts.

## Idempotency

- Scripts re-run on every PSU startup. Make them idempotent: prefer `Set-PSU*` over `New-PSU*`, or guard `New-PSU*` with an existence check.
- Never delete unrelated PSU resources; scripts must only own what they create.

## Endpoint registration

- `endpoints.ps1` is the single entry point that imports the module and publishes `[APIEndpoint(...)]`-decorated functions:
  ```powershell
  Import-Module -Name powershell-yaml -ErrorAction Ignore
  Import-Module -Name synedgy.PSSqlite, synedgy.universal.helper, PSUConfig
  Import-PSUEndpoint -Module PSUConfig -Environment 'PSUConfig' -ApiPrefix 'api' -Authentication:$false
  ```
- Do not register endpoints individually here; add the `[APIEndpoint]` attribute on the function in `source/Public/` instead.
- Keep the `-Environment` value aligned with the environment defined in `environments.ps1`.

## Authentication & roles

- `authentication.ps1` and `roles.ps1` are deployment-environment-sensitive. Avoid hard-coding secrets; reference PSU variables defined in `variables.ps1`.
- Role names referenced by `[APIEndpoint(Role = ...)]` must exist in `roles.ps1`.
