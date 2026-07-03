---
description: 'Private function authoring instructions'
applyTo: 'source/Private/**/*.ps1'
---

# Private Function Development Guidelines

Private functions are not exported but follow the same baseline engineering rules as public functions.

## Baseline structure

- Use one function per file; match the filename to the function name.
- Add comment-based help with `.SYNOPSIS`, `.DESCRIPTION`, one `.EXAMPLE`, and `.PARAMETER` for every parameter.
- Use `[CmdletBinding()]` and `[OutputType(...)]`.
- Use explicit .NET parameter types.
- Follow DSC Community parameter layout: attribute, type, and variable on separate lines, with blank lines between parameters.
- Keep parameter names and defaults stable while consumed by public functions or build tasks.

## PowerShell style

- Prefer `$null = <expression>` over piping to `Out-Null`.
- Prefer splatting over backtick continuation.
- Use ASCII in `.ps1` files.
- Build multi-level paths with chained `Join-Path` calls; do not embed separators in `-ChildPath`.

## Module-scoped state

- Declare module-level cache variables in `source/prefix.ps1`.
- Read and write cache values through `$script:<Name>`.
- Provide `-Force` when a function needs to bypass a cache.

## Validation model

- Prefer enums for reused or evolving option lists.
- Use `ValidateSet` only for narrow, local option lists.
- When shared options change, update function contracts, template conditions, and tests together.

## Composition

- Keep helpers focused and composable.
- Never prompt from a private helper unless explicitly required by design.
- Do not import modules inside helpers; declare dependencies in `source/PSUConfig.psd1`.
- Forward `-Verbose`, `-Debug`, and `-Force` to wrapped cmdlets instead of reimplementing them.
- Treat private helpers that affect user-facing behavior with public-function compatibility rigor.

## Testing

- Add or update `tests/Unit/Private/<FunctionName>.Tests.ps1`.
- Cover happy paths and validation failures.
- Use `InModuleScope` only when directly testing private functions or module state.
- Follow `.github/instructions/test-writing.instructions.md`.
