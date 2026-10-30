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

Describe 'Confirm-PSUConfigMonitoringNotification' {
    BeforeEach {
        Mock Get-PSUConfigAwtrixDevice { 'http://clock.local' }
        Mock Remove-AwtrixNotification
        Mock Get-PSUConfigSecurityAlert {
            @(
                [pscustomobject]@{ id = 7; status = 'Detected' }
                [pscustomobject]@{ id = 8; status = 'Detected' }
            )
        }
        Mock Set-PSUConfigSecurityAlert
    }

    It 'clears the clock and acknowledges detected alerts' {
        $result = Confirm-PSUConfigMonitoringNotification -Confirm:$false

        $result.Status | Should -Be 'Acknowledged'
        $result.Device | Should -Be 'http://clock.local'
        $result.UpdatedAlertCount | Should -Be 2
        Should -Invoke Remove-AwtrixNotification -Times 1 -Exactly -ParameterFilter {
            $Device -eq 'http://clock.local'
        }
        Should -Invoke Set-PSUConfigSecurityAlert -Times 2 -Exactly -ParameterFilter {
            $Status -eq 'Investigating'
        }
    }

    It 'does not clear the notification when WhatIf is used' {
        Confirm-PSUConfigMonitoringNotification -WhatIf

        Should -Invoke Remove-AwtrixNotification -Times 0 -Exactly
        Should -Invoke Set-PSUConfigSecurityAlert -Times 0 -Exactly
    }
}
