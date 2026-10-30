Describe 'Set-PSUConfigSecurityAlert command contract' {
    It 'is exported and requires a target identifier' {
        $command = Get-Command -Name Set-PSUConfigSecurityAlert -Module PSUConfig
        $command.Parameters.Id.Attributes.Mandatory | Should -Contain $true
        $command.Parameters.Keys | Should -Contain 'WhatIf'
    }
}
