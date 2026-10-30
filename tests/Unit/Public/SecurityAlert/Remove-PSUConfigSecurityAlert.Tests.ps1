Describe 'Remove-PSUConfigSecurityAlert command contract' {
    It 'is exported and confirms destructive removal' {
        $command = Get-Command -Name Remove-PSUConfigSecurityAlert -Module PSUConfig
        $command.Parameters.Id.Attributes.Mandatory | Should -Contain $true
        $command.Parameters.Keys | Should -Contain 'Confirm'
    }
}
