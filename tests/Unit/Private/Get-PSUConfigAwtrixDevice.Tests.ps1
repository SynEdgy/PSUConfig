BeforeAll {
    $script:moduleName = 'PSUConfig'
    Import-Module -Name $script:moduleName -Force -ErrorAction Stop
    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    Remove-Module -Name $script:moduleName -Force -ErrorAction SilentlyContinue
}

Describe 'Get-PSUConfigAwtrixDevice' {
    It 'uses the environment override when no PSU variable exists' {
        $previousValue = $env:PSUCONFIG_AWTRIX_DEVICE
        try
        {
            $env:PSUCONFIG_AWTRIX_DEVICE = 'http://test-clock'
            $result = InModuleScope $script:moduleName {
                Remove-Variable -Name PSUCONFIG_AWTRIX_DEVICE -Scope Global -ErrorAction SilentlyContinue
                Get-PSUConfigAwtrixDevice
            }

            $result | Should -Be 'http://test-clock'
        }
        finally
        {
            $env:PSUCONFIG_AWTRIX_DEVICE = $previousValue
        }
    }

    It 'defaults to clock.local' {
        $previousValue = $env:PSUCONFIG_AWTRIX_DEVICE
        try
        {
            Remove-Item Env:\PSUCONFIG_AWTRIX_DEVICE -ErrorAction SilentlyContinue
            $result = InModuleScope $script:moduleName {
                Remove-Variable -Name PSUCONFIG_AWTRIX_DEVICE -Scope Global -ErrorAction SilentlyContinue
                Get-PSUConfigAwtrixDevice
            }

            $result | Should -Be 'http://clock.local'
        }
        finally
        {
            $env:PSUCONFIG_AWTRIX_DEVICE = $previousValue
        }
    }
}
