BeforeAll {
    $script:moduleName = 'PSUConfig'
    Import-Module -Name $script:moduleName -Force -ErrorAction Stop
    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')
    Remove-Module -Name $script:moduleName -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-PSUConfigMonitoringDirectoryRequest' {
    It 'requests the selected owner fields from the configured base URI' {
        $previousBaseUri = $env:PSUCONFIG_DUMMYJSON_BASEURI
        try
        {
            $env:PSUCONFIG_DUMMYJSON_BASEURI = 'https://directory.example.test'
            Mock Invoke-RestMethod { [pscustomobject]@{ id = 13 } }

            $result = InModuleScope $script:moduleName {
                Invoke-PSUConfigMonitoringDirectoryRequest -Path 'users/13'
            }

            $result.id | Should -Be 13
            Should -Invoke Invoke-RestMethod -Times 1 -Exactly -ParameterFilter {
                $Uri -eq 'https://directory.example.test/users/13' -and
                $Method -eq 'Get' -and $TimeoutSec -eq 15
            }
        }
        finally
        {
            $env:PSUCONFIG_DUMMYJSON_BASEURI = $previousBaseUri
        }
    }
}
