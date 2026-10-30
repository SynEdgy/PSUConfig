Describe 'Get-PSUConfigUserProfile command contract' {
    It 'is exported with wildcard and synchronization filters' {
        $command = Get-Command -Name Get-PSUConfigUserProfile -Module PSUConfig
        $command.Parameters.Keys | Should -Contain 'DisplayName'
        $command.Parameters.Keys | Should -Contain 'SyncedOnAfter'
    }

    It 'declares the user profile API endpoint in the PSUConfig environment' {
        $command = Get-Command -Name Get-PSUConfigUserProfile -Module PSUConfig
        $attribute = $command.ScriptBlock.Attributes |
            Where-Object { $_.TypeId.Name -eq 'APIEndpoint' }

        $attribute.Name | Should -Be 'getPSUConfigUserProfile'
        $attribute.Path | Should -Be '/userProfile'
        $attribute.Method | Should -Be @('GET')

        $endpoint = Get-ModuleApiEndpoint -Module PSUConfig -Environment PSUConfig -ApiPrefix api |
            Where-Object { $_.FunctionInfo.Name -eq 'Get-PSUConfigUserProfile' }

        $endpoint.Environment | Should -Be 'PSUConfig'
        $endpoint.Url | Should -Be 'api/userprofile'
    }

    It 'hides the strongly typed SQLite configuration from the generated endpoint contract' {
        $command = Get-Command -Name Get-PSUConfigUserProfile -Module PSUConfig
        $parameterAttribute = $command.Parameters['SqliteDBConfig'].Attributes |
            Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }

        $parameterAttribute.DontShow | Should -BeTrue

        $endpoint = Get-ModuleApiEndpoint -Module PSUConfig -Environment PSUConfig -ApiPrefix api |
            Where-Object { $_.FunctionInfo.Name -eq 'Get-PSUConfigUserProfile' }
        $scriptBlock = Get-ModuleApiEndpointScriptblock -ModuleApiEndpoint $endpoint
        $scriptBlockText = $scriptBlock.ToString()

        $scriptBlockText | Should -Match '\$displayName'
        $scriptBlockText | Should -Match '\$syncedOnAfter'
        $scriptBlockText | Should -Not -Match 'SqliteDBConfig'
        $scriptBlockText | Should -Not -Match 'DontShow'
    }
}
