---
description: 'Pester test authoring instructions'
applyTo: 'tests/**/*.Tests.ps1'
---

# Pester Test Development Guidelines

Tests run against the built module, not directly against `source/`.

## Required blueprint

Begin every test file with this structure:

```powershell
BeforeAll {
    $script:moduleName = 'PSUConfig'

    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    Import-Module -Name $script:moduleName -Force -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Remove-Module -Name $script:moduleName
}
```

## Structure and mocks

- Use `BeforeDiscovery` outside `Describe` for `-ForEach` data.
- Put case-specific mocks in `BeforeAll` inside the relevant `Describe` or `Context`.
- Mock only external boundaries, not internal pure helpers.
- Call public functions with module qualification.
- Use `InModuleScope` only for private functions or module-internal state.
- Do not reference test-file `$script:` variables from inside `InModuleScope`.

## Naming and assertions

- Begin every `It` description with `Should`.
- Use `-ForEach` and `<VariableName>` in data-driven test names.
- Use `-Skip:(<condition>)` for platform-specific cases.
- Prefer the most specific assertion:
  - exact value: `Should -Be`
  - case-sensitive value: `Should -BeExactly`
  - regex: `Should -Match`
  - Boolean: `Should -BeTrue` or `Should -BeFalse`
  - null or empty: `Should -BeNullOrEmpty`
  - exception: `Should -Throw`
  - mock invocation: `Should -Invoke ... -Scope It`
  - type: `Should -BeOfType`
- Always scope mock invocation assertions with `-Scope It`.

## Paths and compatibility

- Use `$TestDrive` for absolute test fixture paths.
- Build expected paths with chained `Join-Path` calls.
- Do not use hardcoded Windows paths in cross-platform tests.
- Wrap pipeline results in `@()` before `.Count`, `.Length`, or indexing for Windows PowerShell 5.1 compatibility.
- Pass `-Confirm:$false` when exercising commands that support `ShouldProcess`.

## Layout

- Public unit tests belong in `tests/Unit/Public/<FunctionName>.Tests.ps1`.
- Private unit tests belong in `tests/Unit/Private/<FunctionName>.Tests.ps1`.
- QA tests cover module-manifest contracts; do not duplicate them per function.
- Tests under `source/tests/` run inside deployed PSU, not in CI.
