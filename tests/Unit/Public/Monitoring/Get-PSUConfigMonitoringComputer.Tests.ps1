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

Describe 'Get-PSUConfigMonitoringComputer' {
    BeforeEach {
        Mock Read-PSUConfigMonitoringMachineData {
            [pscustomobject]@{
                machines = @(
                    [pscustomobject]@{
                        id = 'LT-1001'
                        hostname = 'CH-GVA-LT1001'
                        model = 'Surface Laptop 7'
                        ownerId = 13
                        operatingSystem = [pscustomobject]@{ name = 'Windows 11 Enterprise' }
                        health = [pscustomobject]@{
                            online = $true
                            uptimeHours = 37.5
                            lastRebootTime = '2026-09-28T08:15:00Z'
                        }
                        installedSoftware = @(
                            [pscustomobject]@{ name = 'SecureConnect'; version = '5.2' }
                        )
                    }
                    [pscustomobject]@{
                        id = 'LT-1002'
                        hostname = 'CH-GVA-LT1002'
                        model = 'Surface Laptop 7'
                        ownerId = $null
                        operatingSystem = [pscustomobject]@{ name = 'Windows 11 Enterprise' }
                        health = [pscustomobject]@{
                            online = $false
                            uptimeHours = 0
                            lastRebootTime = '2026-09-26T15:40:00Z'
                        }
                        installedSoftware = @(
                            [pscustomobject]@{ name = 'SecureConnect'; version = '5.4' }
                        )
                    }
                )
            }
        }
        Mock Invoke-PSUConfigMonitoringDirectoryRequest {
            [pscustomobject]@{
                id = 13
                firstName = 'Noah'
                lastName = 'Hernandez'
                email = 'noah@example.test'
                company = [pscustomobject]@{
                    department = 'Engineering'
                    title = 'Database Administrator'
                }
            }
        }
        Mock Set-PSUConfigUserProfile
    }

    It 'returns only vulnerable computers enriched with owner and health data' {
        $result = @(Get-PSUConfigMonitoringComputer)

        $result.Count | Should -Be 1
        $result[0].ComputerName | Should -Be 'CH-GVA-LT1001'
        $result[0].SoftwareVersion | Should -Be '5.2'
        $result[0].OwnerDisplayName | Should -Be 'Noah Hernandez'
        $result[0].Online | Should -BeTrue
        Should -Invoke Set-PSUConfigUserProfile -Times 1 -Exactly
    }
}
