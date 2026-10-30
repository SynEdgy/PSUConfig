Describe 'Remove-PSUConfigUserProfile command contract' {
    It 'is exported and requires confirmation support' {
        $command = Get-Command -Name Remove-PSUConfigUserProfile -Module PSUConfig
        $command.Parameters.Id.Attributes.Mandatory | Should -Contain $true
        $command.Parameters.Keys | Should -Contain 'Confirm'
    }
}
