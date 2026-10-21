# PSU `Invoke-PSUScript`, `-Confirm`, and `ShouldProcess`

## Summary

PowerShell Universal module-backed scripts do not expose PowerShell common
parameters through `Invoke-PSUScript -Parameters`. This prevents callers from
passing `-Confirm:$false` to a command that supports `ShouldProcess`.

When such a command has `ConfirmImpact = 'High'`, the default
`$ConfirmPreference = 'High'` causes `ShouldProcess` to request confirmation.
A PSU automation job is non-interactive and cannot answer that prompt.

This behavior was reproduced locally with PSUConfig on PowerShell Universal
2026.3.3. The exact exception described below has not been confirmed as a
documented upstream PSU defect.

## Reproduction

`Initialize-PSUConfigDB` is registered as a module-backed PSU script:

```powershell
New-PSUScript `
    -Environment 'PSUConfig' `
    -Module 'PSUConfig' `
    -Command 'Initialize-PSUConfigDB'
```

The command declares `SupportsShouldProcess` with high confirmation impact:

```powershell
[CmdletBinding(
    SupportsShouldProcess = $true,
    ConfirmImpact = 'High'
)]
```

Attempting to suppress confirmation through the PSU invocation parameters:

```powershell
Invoke-PSUScript `
    -Script $script `
    -Parameters @{
        Force   = $true
        Confirm = $false
    } `
    -ComputerName $serverUrl `
    -AppToken $appToken
```

fails before starting the job:

```text
Unknown parameter Confirm. Parameters for this script are SqliteDBConfig,Force
```

`Confirm` is a common parameter added by `SupportsShouldProcess`; it is not an
explicit parameter in the function's `param` block. PSU validates the supplied
hashtable against the script metadata and excludes that common parameter.

Invoking the command without `Confirm` starts a job, but `ShouldProcess` tries
to request confirmation. In the reproduced PSU job runspace this failed with:

```text
Exception calling "ShouldProcess" with "2" argument(s):
"Index was out of range. Must be non-negative and less than the size of the
collection. (Parameter 'index')"
```

## Impact

- High-impact module commands cannot be invoked non-interactively through
  `Invoke-PSUScript -Parameters` while retaining their normal confirmation
  semantics.
- Lower-impact commands can exhibit the same problem whenever
  `$ConfirmPreference` requires a prompt.
- Dashboard callbacks and automation jobs cannot answer an interactive
  PowerShell confirmation prompt.
- Lowering `ConfirmImpact` avoids the prompt but weakens safety for interactive
  callers and is not an appropriate general workaround.

## Current workaround

Use an explicitly registered automation wrapper that exposes only the required
business parameters and suppresses confirmation when invoking the module
command:

```powershell
param
(
    [Parameter()]
    [switch]
    $Force
)

Initialize-PSUConfigDB -Force:$Force.IsPresent -Confirm:$false
```

The wrapper should only be exposed to an appropriately authorized PSU role.
The authorization boundary then replaces the interactive confirmation that
cannot be presented in the job runspace.

For local administration on the PSU host, invoking the module command directly
also works:

```powershell
Initialize-PSUConfigDB -Force -Confirm:$false
```

## Preferred future behavior

PSU or the helper registration layer should preserve supported common
parameters for module-backed scripts, or provide a first-class non-interactive
confirmation policy. Requiring a separate wrapper for every state-changing
module command duplicates parameter contracts and can drift from the underlying
command.
