---
description: 'Public function authoring instructions'
applyTo: 'source/Public/**/*.ps1'
---

# Public Function Development Guidelines

Public functions are auto-exported and form the module's API surface (and, when decorated, the PSU REST surface).

## Baseline structure

- One function per file; filename matches function name (approved verb-noun).
- Comment-based help with at least: `.SYNOPSIS`, `.DESCRIPTION`, one `.EXAMPLE`, `.PARAMETER` for every parameter.
- `[CmdletBinding()]` and explicit `[OutputType(...)]`.
- Use explicit .NET parameter types (`[System.String]`, `[System.Boolean]`, `[System.Management.Automation.SwitchParameter]`).
- Mutating functions declare `SupportsShouldProcess = $true` with appropriate `ConfirmImpact`, and gate work with `$pscmdlet.ShouldProcess(...)`.
- Forward `-Verbose`/`-Debug`/`-Force` to nested calls with `:$Verbose.IsPresent` / `:$Debug.IsPresent` / `:$Force.IsPresent`.

## Configuration parameters

- Inject the SQLite config via a hidden parameter:
  ```powershell
  [Parameter(DontShow)]
  [synedgy.PSSqlite.SqliteDBConfig]
  $SqliteDBConfig = (Get-myModuleConfig)
  ```
- Never reload the YAML config inside the function body; rely on `Get-myModuleConfig`'s cached `$script:MyModuleDBConfig`.

## PSU endpoint exposure

- To publish a function as a PSU REST endpoint, add `[APIEndpoint(...)]` between `[CmdletBinding()]` and `[OutputType(...)]`:
  ```powershell
  [APIEndpoint(
      Name = 'GetSomething',
      Path = '/something',
      Description = 'Sample endpoint to return input data.',
      Method = 'GET',
      Authentication = $false,
      Role = ('admin','user'),
      Tag = 'Sample',
      Timeout = 30
  )]
  ```
- `Path` must be unique across the module. `Method` is one of `GET`, `POST`, `PUT`, `DELETE`, `PATCH`.
- Endpoints are imported by `source/.universal/endpoints.ps1` via `Import-PSUEndpoint -Module PSUConfig`. No manual registration.
- Parameters bound from the request must be primitives or types serialisable from JSON; avoid `[switch]` for endpoint inputs (use `[bool]`).

## Compatibility

- Preserve parameter names, types, and defaults; renames are breaking changes.
- Removing or renaming an `[APIEndpoint]` `Path` or `Method` is a breaking change for API consumers; bump version accordingly and add an `Unreleased` entry in `CHANGELOG.md`.
