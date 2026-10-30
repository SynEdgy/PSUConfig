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

Describe 'Get-PSUConfigMonitoringMachineByName' {
    BeforeEach {
        Mock Read-PSUConfigMonitoringMachineData {
            [pscustomobject]@{
                machines = @(
                    [pscustomobject]@{ id = 'LT-1001'; hostname = 'CH-GVA-LT1001' }
                )
            }
        }
    }

    It 'resolves a machine by hostname or identifier' {
        (InModuleScope $script:moduleName {
                Get-PSUConfigMonitoringMachineByName -ComputerName 'CH-GVA-LT1001'
            }).id |
            Should -Be 'LT-1001'
        (InModuleScope $script:moduleName {
                Get-PSUConfigMonitoringMachineByName -ComputerName 'LT-1001'
            }).hostname |
            Should -Be 'CH-GVA-LT1001'
    }

    It 'throws for an unknown machine' {
        {
            InModuleScope $script:moduleName {
                Get-PSUConfigMonitoringMachineByName -ComputerName 'UNKNOWN'
            }
        } |
            Should -Throw '*was not found*'
    }
}
