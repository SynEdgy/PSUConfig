BeforeAll {
    $script:moduleName = 'PSUConfig'
    Import-Module -Name $script:moduleName -Force -ErrorAction Stop
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')
    Remove-Module -Name $script:moduleName -Force -ErrorAction SilentlyContinue
}

Describe 'Remove-PSUConfigMonitoringFinding' {
    BeforeEach {
        Mock Get-PSUConfigSecurityAlert {
            @(
                [pscustomobject]@{ id = 7; computerName = 'CH-GVA-LT1001' }
                [pscustomobject]@{ id = 9; computerName = 'CH-GVA-LT1001' }
            )
        }
        Mock Remove-PSUConfigSecurityAlert
    }

    It 'removes every persisted alert summary for the selected computer' {
        $result = Remove-PSUConfigMonitoringFinding -ComputerName 'CH-GVA-LT1001' -Confirm:$false

        $result.ComputerName | Should -Be 'CH-GVA-LT1001'
        $result.RemovedAlertCount | Should -Be 2
        Should -Invoke Get-PSUConfigSecurityAlert -Times 1 -Exactly -ParameterFilter {
            $ComputerName -eq 'CH-GVA-LT1001'
        }
        Should -Invoke Remove-PSUConfigSecurityAlert -Times 2 -Exactly
    }

    It 'does not remove summaries when WhatIf is used' {
        Remove-PSUConfigMonitoringFinding -ComputerName 'CH-GVA-LT1001' -WhatIf

        Should -Invoke Remove-PSUConfigSecurityAlert -Times 0 -Exactly
    }
}
