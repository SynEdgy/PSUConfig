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

Describe 'Invoke-PSUConfigMonitoringPatch' {
    BeforeEach {
        Mock Get-PSUConfigMonitoringMachineByName {
            [pscustomobject]@{
                hostname = 'CH-GVA-LT1001'
                health = [pscustomobject]@{ online = $true }
                installedSoftware = @(
                    [pscustomobject]@{ name = 'SecureConnect'; version = '5.2' }
                )
            }
        }
        Mock Get-PSUConfigSecurityAlert { [pscustomobject]@{ id = 7; status = 'Detected' } }
        Mock Get-PSUConfigServerConnectionParameter { @{} }
        Mock Get-PSUScript { [pscustomobject]@{ Name = 'PSUConfig\Invoke-PSUConfigMonitoringJob' } }
        Mock Invoke-PSUScript { [pscustomobject]@{ Id = 43 } }
        Mock Set-PSUConfigSecurityAlert
    }

    It 'starts an approved patch job and updates the alert' {
        $result = Invoke-PSUConfigMonitoringPatch -ComputerName 'CH-GVA-LT1001' `
            -OwnerNotified $true -Approved $true -Confirm:$false

        $result.JobId | Should -Be 43
        Should -Invoke Invoke-PSUScript -Times 1 -Exactly -ParameterFilter {
            $Parameters.JobType -eq 'Fix' -and
            $Parameters.TargetComputerName -eq 'CH-GVA-LT1001' -and
            $Parameters.AlertId -eq 7
        }
        Should -Invoke Set-PSUConfigSecurityAlert -Times 1 -Exactly -ParameterFilter {
            $Id -eq 7 -and $Status -eq 'Fixing' -and $PsuJobId -eq '43'
        }
    }

    It 'requires owner notification and explicit approval' {
        {
            Invoke-PSUConfigMonitoringPatch -ComputerName 'CH-GVA-LT1001' `
                -OwnerNotified $false -Approved $true -Confirm:$false
        } | Should -Throw '*owner must be notified*'

        {
            Invoke-PSUConfigMonitoringPatch -ComputerName 'CH-GVA-LT1001' `
                -OwnerNotified $true -Approved $false -Confirm:$false
        } | Should -Throw '*explicit operator approval*'
    }

    It 'rejects offline computers before starting a job' {
        Mock Get-PSUConfigMonitoringMachineByName {
            [pscustomobject]@{
                hostname = 'CH-ZRH-LT1004'
                health = [pscustomobject]@{ online = $false }
                installedSoftware = @(
                    [pscustomobject]@{ name = 'SecureConnect'; version = '5.1' }
                )
            }
        }

        {
            Invoke-PSUConfigMonitoringPatch -ComputerName 'CH-ZRH-LT1004' `
                -OwnerNotified $true -Approved $true -Confirm:$false
        } | Should -Throw '*offline*'

        Should -Invoke Invoke-PSUScript -Times 0 -Exactly
    }
}
