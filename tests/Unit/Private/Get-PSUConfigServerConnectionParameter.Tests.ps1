BeforeAll {
    $script:moduleName = 'PSUConfig'
    Import-Module -Name $script:moduleName -Force -ErrorAction Stop
    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    Remove-Module -Name $script:moduleName -Force -ErrorAction SilentlyContinue
}

Describe 'Get-PSUConfigServerConnectionParameter' {
    It 'uses the environment token and configured server URL' {
        $previousToken = $env:UniversalServerAppToken
        try
        {
            $env:UniversalServerAppToken = 'test-token'
            Mock Get-PSUConfigSetting {
                [ordered]@{ UniversalServerUrl = 'https://psu.example.test/' }
            }

            $result = InModuleScope $script:moduleName {
                Get-PSUConfigServerConnectionParameter
            }

            $result.AppToken | Should -Be 'test-token'
            $result.ComputerName | Should -Be 'https://psu.example.test/'
            $result.ContainsKey('Integrated') | Should -BeFalse
        }
        finally
        {
            $env:UniversalServerAppToken = $previousToken
        }
    }
}
