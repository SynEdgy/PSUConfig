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
