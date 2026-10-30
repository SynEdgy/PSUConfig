Describe 'Set-PSUConfigUserProfile command contract' {
    It 'is exported as a keyed upsert command' {
        $command = Get-Command -Name Set-PSUConfigUserProfile -Module PSUConfig
        $command.Parameters.Id.Attributes.Mandatory | Should -Contain $true
        $command.Parameters.Keys | Should -Contain 'WhatIf'
    }
}
