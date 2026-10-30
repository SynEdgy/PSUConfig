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

Describe 'Start-PSUConfigMonitoringAlert' {
    BeforeEach {
        Mock Get-PSUConfigServerConnectionParameter { @{} }
        Mock Get-PSUScript { [pscustomobject]@{ Name = 'PSUConfig\Invoke-PSUConfigMonitoringJob' } }
        Mock Invoke-PSUScript { [pscustomobject]@{ Id = 42 } }
    }

    It 'starts the module-backed alert job' {
        $result = Start-PSUConfigMonitoringAlert -DelaySeconds 3 -Confirm:$false

        $result.JobId | Should -Be 42
        Should -Invoke Invoke-PSUScript -Times 1 -Exactly -ParameterFilter {
            $Parameters.JobType -eq 'Alert' -and $Parameters.DelaySeconds -eq 3
        }
    }

    It 'supports WhatIf' {
        Start-PSUConfigMonitoringAlert -WhatIf

        Should -Invoke Invoke-PSUScript -Times 0 -Exactly
    }
}
