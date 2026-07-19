# PSUConfig Demo

This app is a local demonstration of the shared Universal Dashboard job
components from `synedgy.universal.helper` (`New-UDPsuJobHeader` and
`New-UDPsuJobTerminalView`), including their automatic light/dark theming
(follows PSU's own theme switch live) and preference for a scoped app token
(`psuconfig_automation_bot_token`) over `-Integrated` when reading job status.

## Pages

- `Home` (`/psuconfig-demo`): triggers the `Get-myUser` PSU script and links to
  its job detail page.
- `Job Info` (`/psuconfig-demo/job/:id`): renders the job header and terminal
  output view for the given job id.

This app exists to validate the shared components end-to-end against a real
PowerShell Universal instance from this repository.
