# Generated API endpoints

PSUConfig exposes selected public module functions as PowerShell Universal API
endpoints. The endpoint declarations stay next to the commands, while
`synedgy.universal.helper` performs discovery, wrapper generation, and PSU
registration.

## Dependency and type loading

`synedgy.universal.helper` is a runtime dependency in
`source/PSUConfig.psd1`. PowerShell imports manifest `RequiredModules` before it
parses and imports the PSUConfig root module.

During its own import, the helper runs `source/suffix.ps1` and registers
`APIEndpoint` as a type accelerator. This makes the attribute available when
PowerShell parses PSUConfig functions such as:

```powershell
[CmdletBinding()]
[APIEndpoint(
    Path = '/something',
    Description = 'Return the supplied data.',
    Method = 'GET',
    Authentication = $false,
    Tag = 'Sample',
    Timeout = 30
)]
param
(
    [Parameter(Mandatory = $true)]
    [System.String]
    $Data
)
```

The PSU configuration loader also imports `synedgy.universal.helper` before
calling `Import-PSUEndpoint`. The `PSUConfig` execution environment preloads
the helper and PSUConfig modules so the generated endpoint can invoke the
original command.

## Registration flow

`source/.universal/endpoints.ps1` contains one registration call, equivalent
to:

```powershell
$endpointParameters = @{
    Module         = 'PSUConfig'
    Environment    = 'PSUConfig'
    ApiPrefix      = 'api'
    Authentication = $false
}
Import-PSUEndpoint @endpointParameters
```

The helper processes that call as follows:

1. `Get-ModuleApiEndpoint` imports PSUConfig into the configuration runspace.
2. It examines the module's exported functions and selects functions whose
   script block has one or more active `APIEndpoint` attributes.
3. It reads the attribute properties and resolves endpoint metadata. Explicit
   `Import-PSUEndpoint` arguments override attribute values.
4. `Get-ModuleApiEndpointScriptblock` reads the function parameter AST and
   generates a parser-safe wrapper.
5. `Import-PSUEndpoint` removes metadata that the installed
   `New-PSUEndpoint` command does not accept.
6. It calls `New-PSUEndpoint` with the resolved URL, method, description,
   environment, authentication, role, tag, timeout, documentation, and
   generated endpoint script block.

Passing `-ApiPrefix api` intentionally produces `/api/<path>` URLs and omits
the attribute's version segment. Without that override, the default layout is
`/api/v1/<path>`.

The registration-wide overrides currently supported are `Environment`,
`ApiPrefix`, `Authentication`, `Role`, `LogLevel`, and `Documentation`.
Attribute `Tag` and `Timeout` values remain specific to each endpoint.

One function may declare multiple `APIEndpoint` attributes. Each attribute
produces an independent endpoint and keeps its own prefix, documentation,
method, roles, tags, and other metadata. This supports exposing one command
through multiple versions or HTTP contracts without duplicating the command.

Because PSUConfig currently passes `-Authentication:$false`, every generated
endpoint is anonymous and `Import-PSUEndpoint` removes role restrictions.
Remove that override and configure authentication before relying on attribute
roles.

## Generated parameter contract

The wrapper keeps ordinary PowerShell types and parameter validation, but
normalizes contracts that PSU cannot safely parse in a separate session:

| Module command parameter | Generated endpoint parameter |
|---|---|
| Custom enum | Validated `string` |
| Custom enum array | Validated `string[]` |
| `switch` | `bool` |
| PowerShell class | `object` |
| PowerShell class array | `object[]` |
| `Parameter(DontShow)` | Omitted |
| Untyped parameter | Preserved |

The first character of generated parameter names is lowercased for the HTTP
contract. Enum defaults that reference static enum members are rewritten as
their string names, and existing validation attributes are preserved. When an
enum has no `ValidateSet`, the helper adds one from the enum member names.

The wrapper splats `$PSBoundParameters` into the original module command.
PowerShell therefore converts validated strings back to enums, Booleans back
to switches, and deserialized objects or dictionaries back to data-oriented
PowerShell classes.

Commands supporting `ShouldProcess` receive `-Confirm:$false` because PSU API
runspaces cannot answer interactive confirmation prompts.

These transformations affect only the generated endpoint script block. Direct
PowerShell callers still see the original strongly typed command signature.

## Why custom types need normalization

PSU parses a generated endpoint in a session separate from the runspace that
imported PSUConfig. A type accelerator or PowerShell class exported while
loading the module is therefore not necessarily available to that parser.
Before normalization, an unresolved enum or class could make endpoint parsing
fail without a useful registration error; the PSU admin UI would then show no
parameters for the automation or endpoint resource.

Enums are safe as validated strings because the original function converts
them during parameter binding. PowerShell classes are safe as objects when
they are data-oriented classes that PowerShell can construct from the
deserialized request object. Their bindable properties must be writable, and
the request must submit an object or dictionary rather than a string containing
JSON.

## Adding an endpoint

1. Add `APIEndpoint` to an exported public PSUConfig function.
2. Define a unique path and supported HTTP method.
3. Prefer request types that deserialize predictably.
4. Mark internal injection parameters with `Parameter(DontShow)`.
5. Add the command to `tests/Unit/Public/ApiEndpoints.Tests.ps1`.
6. Parse the generated script block and verify that PSU displays the expected
   endpoint parameters.
7. Build, deploy, and exercise the route with representative request data.

No change to `source/.universal/endpoints.ps1` is required for each new
function.

## Current PSUConfig routes

| Method | Route | Command |
|---|---|---|
| GET | `/api/something` | `Get-Something` |
| GET | `/api/users/by-city` | `Find-UserByCity` |
| GET | `/api/userprofile` | `Get-PSUConfigUserProfile` |
| GET | `/api/psuconfiguser` | `Get-PSUConfigUser` |
| POST | `/api/psuconfiguser` | `New-PSUConfigUser` |
| PUT | `/api/psuconfiguser` | `Set-PSUConfigUser` |
| DELETE | `/api/psuconfiguser` | `Remove-PSUConfigUser` |

The helper normalizes generated URLs to lowercase.

## Current limitations

- `Name` is retained on the attribute for descriptive compatibility but
  `New-PSUEndpoint` does not expose a corresponding parameter.
- `AutoSerialization` is reserved and is not forwarded by the current helper.
- `ContentType` is retained on the attribute, but the installed
  `New-PSUEndpoint` command does not expose a corresponding parameter.
- The attribute's `Parameters` override is reserved but is not yet consumed by
  the wrapper generator.
- Class parameters are exposed as `object`, so their property schema is not
  represented in PSU's endpoint parameter UI. Validate class invariants in the
  original command.
- The HTTP binder must produce an object or dictionary for class parameters. A
  string containing JSON is not the same as a deserialized object.
- `Parameter(DontShow)` removes a parameter from the HTTP contract; the
  underlying command must supply its own default or resolve the value
  internally.
