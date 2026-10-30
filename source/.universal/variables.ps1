New-PSUVariable -Name "Variable" -Value 'foobar' -Description "TestVariable"
New-PSUVariable -Name 'psuconfig_automation_bot_token' -Vault 'Database' -Description 'App token for the PSUConfigDemo app, bound to the psuconfig_automation_bot role, used as the primary (non--Integrated) way to read job status/output for the job info page.' -Scope Global

$awtrixVariableParameters = @{
    Name        = 'PSUCONFIG_AWTRIX_DEVICE'
    Value       = 'http://clock.local'
    Description = 'Hostname, IP address, or URI of the AWTRIX notification display.'
    Scope       = 'Global'
}

New-PSUVariable @awtrixVariableParameters