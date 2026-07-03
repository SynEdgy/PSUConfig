---
description: 'Public function authoring instructions'
applyTo: 'source/Public/**/*.ps1'
---

# Public Function Development Guidelines

Public functions are auto-exported and form the module API and, when attributed, the PSU REST surface.

## Baseline structure

- Use one function per file; match the filename to an approved verb-noun function name.
- Add comment-based help with `.SYNOPSIS`, `.DESCRIPTION`, one `.EXAMPLE`, and `.PARAMETER` for every parameter.
- Use `[CmdletBinding()]` and explicit `[OutputType(...)]`.
- Use explicit .NET parameter types.
- Follow DSC Community parameter layout: attribute, type, and variable on separate lines, with blank lines between parameters.
- Keep parameter names, types, and defaults stable unless intentionally making a breaking change.

## PowerShell style

- Prefer `$null = <expression>` over piping to `Out-Null`.
- Prefer splatting over backtick continuation.
- Use ASCII in `.ps1` files.
- Build multi-level paths with chained `Join-Path` calls; do not embed separators in `-ChildPath`.
- Do not hard-code platform-specific paths in user-facing messages.

## Configuration parameters

- Inject SQLite configuration through a hidden parameter:
  ```powershell
  [Parameter(DontShow)]
  [synedgy.PSSqlite.SqliteDBConfig]
  $SqliteDBConfig = (Get-myModuleConfig)
  ```
- Do not reload YAML inside a function; use the cached `Get-myModuleConfig` result.

## PSU endpoint exposure

- Place `[APIEndpoint(...)]` between `[CmdletBinding()]` and `[OutputType(...)]`.
- Keep endpoint paths unique.
- Use only supported HTTP methods.
- Register endpoints through `source/.universal/endpoints.ps1` and `Import-PSUEndpoint -Module PSUConfig`; do not register them manually.
- Use request parameter types that deserialize cleanly from JSON; prefer `[bool]` over `[switch]` for endpoint input.
- Treat endpoint path or method removal as a breaking change.

## State-changing functions

- State-changing functions must declare `SupportsShouldProcess = $true`.
- Set an appropriate `ConfirmImpact`.
- Gate mutations with `$PSCmdlet.ShouldProcess($target, $action)`.
- Forward `-Verbose`, `-Debug`, and `-Force` to nested calls.

## Validation model

- Prefer enums for reused or evolving option lists.
- Use `ValidateSet` only for narrow, local option lists.
- When shared options change, update function contracts, template conditions, and tests together.

## Compatibility and behavior

- Preserve backward compatibility by default.
- Add an `Unreleased` changelog entry for user-visible behavior changes.
- Prefer non-interactive use; accept enough parameters to avoid prompts.
- Keep any supported prompt flow deterministic and tested.

## Testing

- Add or update `tests/Unit/Public/<FunctionName>.Tests.ps1`.
- Cover happy paths, validation failures, and both prompted and non-interactive flows when applicable.
- Pass `-Confirm:$false` when testing execution behind `ShouldProcess`.
- Call public functions with module qualification, for example `PSUConfig\Get-Foo`.
- Follow `.github/instructions/test-writing.instructions.md`.
