---
description: 'Private function authoring instructions'
applyTo: 'source/Private/**/*.ps1'
---

# Private Function Development Guidelines

Private functions are not exported. They follow the same baseline rules as public functions.

## Baseline structure

- One function per file; filename matches function name.
- Comment-based help with at least `.SYNOPSIS`, `.DESCRIPTION`, one `.EXAMPLE`, `.PARAMETER` for every parameter.
- `[CmdletBinding()]` and `[OutputType(...)]` where a return type exists.
- Explicit .NET parameter types.
- Keep parameter names and defaults stable while consumed by public functions.

## Module-scoped state

- Module-level cache variables are declared in `source/prefix.ps1` (e.g. `$script:MyModuleDBConfig = $null`). Do not declare them inside function files.
- Read and write cache via `$script:<Name>`. Provide a `-Force` switch on any function that may need to bypass the cache (see `Get-myModuleConfig`).

## Composition rules

- Never prompt the user from a private helper.
- Do not call `Import-Module` from inside helpers; module dependencies are declared in `source/PSUConfig.psd1` `RequiredModules`.
- When wrapping a `synedgy.PSSqlite` / `synedgy.universal.helper` cmdlet, forward `-Verbose`/`-Debug`/`-Force` rather than re-implementing the behaviour.
