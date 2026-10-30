Describe 'New-PSUConfigSecurityAlert command contract' {
    It 'is exported and supports ShouldProcess' {
        $command = Get-Command -Name New-PSUConfigSecurityAlert -Module PSUConfig
        $command.Parameters.Keys | Should -Contain 'WhatIf'
        $command.Parameters.Keys | Should -Contain 'Confirm'
    }
}
