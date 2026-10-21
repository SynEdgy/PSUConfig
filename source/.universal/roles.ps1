New-PSURole -Name "Administrator" -Description "Administrators can manage settings, create and edit any entity and view all the entities with PowerShell Universal." -Policy {
    param(
        [Security.ClaimsPrincipal]$User
    )

    <#
  Policies should return $true or $false to determine whether the user has the particular
  claim that require them for that role.
#>

    $false
}

New-PSURole -Name "Execute" -Description "Execute scripts within PowerShell Universal." -Policy {
    param(
        [Security.ClaimsPrincipal]$User
    )

    <#
  Policies should return $true or $false to determine whether the user has the particular
  claim that require them for that role.
#>

    $false
}

New-PSURole -Name "Operator" -Description "Operators have access to manage and execute scripts, create other entities within PowerShell Universal but cannot manage PowerShell Universal itself." -Policy {
    param(
        [Security.ClaimsPrincipal]$User
    )

    <#
  Policies should return $true or $false to determine whether the user has the particular
  claim that require them for that role.
#>

    $false
}

New-PSURole -Name "Reader" -Description "Readers have read-only access to PowerShell Universal. They cannot make changes to any entity within the system." -Policy {
    param(
        [Security.ClaimsPrincipal]$User
    )

    <#
  Policies should return $true or $false to determine whether the user has the particular
  claim that require them for that role.
#>

    $false
}

New-PSURole -Name "User" -Description "Does not have access to the admin console but can be assigned resources like APIs, scripts, dashboards and pages." -Policy {
    param(
        [Security.ClaimsPrincipal]$User
    )

    <#
  Policies should return $true or $false to determine whether the user has the particular
  claim that require them for that role.
#>

    $false
}

New-PSURole -Name 'psuconfig_automation_bot' -Description 'Role for the PSUConfigDemo app to read/execute its own scripts and jobs via a scoped app token, instead of relying on -Integrated (which bypasses PSU authorization entirely).' -Policy {
    param(
        [Security.ClaimsPrincipal]$User
    )

    <#
  Policies should return $true or $false to determine whether the user has the particular
  claim that require them for that role.
#>

    return $false
} -Permission @(
    # NOTE: 'automation/read' is currently required to read job status/output at all -- there
    # is no scoped per-script job-read permission in PSU today (see ComsolCentral's
    # docs/bug/bug-psu-no-per-script-job-read-permission.md, submitted to Devolutions and
    # confirmed as being fixed). This means this token can read ALL jobs in the instance, not
    # just PSUConfigDemo's, until that fix ships -- narrow this permission once available.
    'automation/view'
    'automation/read'
    'automation.scripts/view'
    # NOTE: unverified -- ComsolCentral only demonstrates scoped permission strings
    # (automation.scripts.scripts\<name>/*) for -Path-registered scripts (e.g. user_trigger.ps1),
    # not for -Module/-Command registered scripts like Get-myUser. Confirm the correct permission
    # string once the token is created and tested; this may need to reference 'PSUConfig\Get-myUser'
    # or a different qualifier entirely.
    'automation.scripts.scripts\Get-myUser/*'
)
