---
description: 'Pester test authoring instructions'
applyTo: 'tests/**/*.Tests.ps1'
---

# Pester Test Development Guidelines

Tests run against the built module under `output/PSUConfig/<version>/`, not against `source/`. Build before invoking Pester directly.

## Blueprint structure

Begin every test file with the following pair. Do not omit or reorder.

```powershell
BeforeAll {
    $script:moduleName = 'PSUConfig'

    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    Import-Module -Name $script:moduleName -Force -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName']          = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName']        = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Remove-Module -Name $script:moduleName
}
```

- Use `BeforeDiscovery` (outside `Describe`) for `-ForEach` data sets.
- Place case-specific mocks in a `BeforeAll` inside the `Describe`/`Context`, not at file top.
- Mock only external boundaries (`synedgy.PSSqlite`, `synedgy.universal.helper`, PSU cmdlets). Do not mock internal pure helpers.
- Call functions under test with module-qualified names (`PSUConfig\Get-Something`) to avoid stale-mock collisions.

## `It` block naming

- Start every `It` description with `Should` + plain-English outcome:
  ```powershell
  It 'Should return the input data unchanged' { ... }
  It 'Should write an error when configuration is missing' { ... }
  ```
- Data-driven cases use `-ForEach` with `<VariableName>` interpolation:
  ```powershell
  It 'Should accept method <Method>' -ForEach $methodCases { ... }
  ```
- Platform-conditional tests use `-Skip:(...)`; never comment them out.

## Assertion style

| Scenario | Preferred assertion |
|---|---|
| Exact value | `Should -Be 'value'` |
| Case-sensitive | `Should -BeExactly 'Value'` |
| Regex | `Should -Match 'pattern'` |
| Boolean | `Should -BeTrue` / `Should -BeFalse` |
| Null/empty | `Should -BeNullOrEmpty` |
| Throws | `{ ... } \| Should -Throw` |
| Does not throw | `{ ... } \| Should -Not -Throw` |
| Mock invoked | `Should -Invoke -CommandName X -Exactly -Times 1 -Scope It` |
| Type | `$x \| Should -BeOfType [Type]` |

- Always scope mock-call assertions with `-Scope It`.

## Layout

- Unit tests for `source/Public/<F>.ps1` go in `tests/Unit/Public/<F>.Tests.ps1`; same for `Private`.
- QA tests (already present under `tests/QA/`) cover module-manifest contract; do not duplicate them per function.
- PSU runtime tests bundled with the module live in `source/tests/` (copied into the built module via `CopyPaths`); they run inside the deployed PSU instance, not in CI.
