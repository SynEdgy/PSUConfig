# PSUConfig Demo

This SynEdgy-branded app demonstrates module-first PowerShell Universal
configuration management. The PSUConfig module is the source of truth for
commands, SQLite schema, APIs, AI tools, jobs, roles, environments, variables,
and the application itself. Sampler builds, tests, packages, and deploys the
complete automation repository.

The app defaults to the dark SynEdgy presentation while retaining PSU's theme
toggle and a complete light palette. The reusable palettes, typography, shape,
and component overrides are defined in `theme.psd1`; pages use themed MUI
components rather than embedded theme CSS. Job pages use the shared
`New-UDPsuJobHeader` and `New-UDPsuJobTerminalView` components from
`synedgy.universal.helper`.

The Home hero supports English (`en`) and French (`fr`) through data-only PSD1
resources bundled in the module. The app first uses the browser's
`Accept-Language` header, including regional values such as `fr-FR` and
`fr-CH`, then falls back to `DefaultUILanguage` from the active environment in
`PSUConfig.config.yml`, or English when that setting is null. A language
selector in the top-right app header stores an explicit choice in the
`PSUConfigLanguage` browser cookie; that cookie takes precedence over later
browser header values.

The header uses `New-UDLanguageSelector` from `synedgy.universal.helper`.
Deferred dashboard callbacks obtain the deployed module through
`Get-PSUConfigModule` and pass its `ModuleBase` explicitly to shared
localization commands. This avoids relying on deferred callback call stacks.
The demo enables compact labels so the header displays `EN` and `FR`.
Component-local styling can be supplied through `Sx`, while `ClassName`
provides a stable hook for a site stylesheet.

Language preference parsing and resource validation are handled by
`Resolve-PSULocalizationLanguage`. Startup cache population is handled by
`Initialize-PSULocalizationCache`. Both shared commands require the
`PSUConfigDemo` resource name and receive PSUConfig's module base explicitly.
The startup initializer retains ownership of environment configuration and the
named `$Cache:PSUConfigLocalization` variable.

`Get-PSUConfigLocalizedData` accepts a resource `Name`, defaulting to
`PSUConfigDemo`. The shared cache is nested by resource name and then language,
so additional bundles such as `PSUConfig.Users.psd1` can reuse the same
cache safely:

```powershell
$usersStringsParameters = @{
    Name     = 'PSUConfig.Users'
    Language = $language
    Cache    = $Cache:PSUConfigLocalization
}
$usersStrings = Get-PSUConfigLocalizedData @usersStringsParameters
```

The `PSUConfigDemo.strings.psd1` Home resources are bundled in English,
French, and German.

The bundled `PSUConfig.Users.psd1` resources localize the Users page heading
and description in English and French.

Dashboard components own their component-specific strings. For example,
`New-PSUConfigAddUserButton` receives the page's resolved language and loads
`PSUConfig.AddUserButton.strings.psd1` from its owning module. It uses the
configured `DefaultUILanguage` when the requested language is unavailable and
English when the configured default has no resource. The resolved dictionary
is stored in page scope so deferred modal callbacks use the same localization
snapshot selected when the component was rendered. The reusable
`Get-PSUComponentLocalizedData` helper owns this resolution and caching policy
so other internal and external components can follow the same pattern.

`New-PSUConfigUserForm` uses `PSUConfig.UserForm.strings.psd1` for its field
labels, placeholders, submit captions, validation message, and create/update
toasts. `New-PSUConfigUserTable` uses
`PSUConfig.UserTable.strings.psd1` for its title, columns, edit/remove actions,
dialogs, and removal toast. The table passes its requested language to the
deferred edit form, while the add-user button does the same for its form.

For example, a compact selector can use:

```powershell
$selectorSx = @{
    alignSelf = 'center'
    height    = '36px'
    '& .MuiSelect-select' = @{
        paddingTop    = '2px'
        paddingBottom = '2px'
    }
}
```

Equivalent site CSS can target the supplied class:

```css
.site-language-selector {
    align-self: center;
    height: 36px;
}

.site-language-selector .MuiSelect-select {
    padding-top: 2px;
    padding-bottom: 2px;
}
```

Available dictionaries are discovered from culture folders containing a
`PSUConfigDemo.strings.psd1` resource and loaded into the PSUConfig execution
environment's shared `$Cache:` scope by a `ServerStarted` trigger. The app also
initializes the cache on demand after a deployment when the server has not yet
restarted.

This application-level resolver avoids PSU 2026.3.3's native translation
fallback issue, where the documented `fr-FR` to `fr` fallback selects the
server fallback instead. See
[`docs/psu-translation-locale-fallback.md`](../../../docs/psu-translation-locale-fallback.md)
for the native behavior and the custom workaround used here.

## Pages

- `Home` (`/psuconfig-demo`): presents the module-first/Sampler deployment model,
  active environment and schema details, and triggers
  `Get-PSUConfigDatabaseAnalysis` as a PSU job.
- `Users` (`/psuconfig-demo/users`): displays `Get-PSUConfigUser` results through
  the reusable `New-PSUConfigUserTable` dashboard component. A floating action
  opens the reusable `New-PSUConfigUserForm` in a modal and refreshes the table
  after `New-PSUConfigUser` creates the record. Each row provides an Edit action
  that opens the same form with existing values and saves through
  `Set-PSUConfigUser`, plus a Remove action with explicit modal confirmation
  before `Remove-PSUConfigUser` deletes the row.
- `Job Info` (`/psuconfig-demo/job/:id`): renders the job header and terminal
  output view for the given job id.

This app validates the repository architecture and shared components end to
end against a real PowerShell Universal instance.
