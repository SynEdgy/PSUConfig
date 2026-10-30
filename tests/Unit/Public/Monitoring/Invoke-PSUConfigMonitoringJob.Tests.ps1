BeforeAll {
    $script:moduleName = 'PSUConfig'
    Import-Module -Name $script:moduleName -Force -ErrorAction Stop
    $typeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
    if (-not $typeAcceleratorsClass::Get.ContainsKey('SQLiteDBConfig'))
    {
        $typeAcceleratorsClass::Add('SQLiteDBConfig', [synedgy.PSSqlite.SqliteDBConfig])
    }
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')
    Remove-Module -Name $script:moduleName -Force -ErrorAction SilentlyContinue
}

Describe 'Invoke-PSUConfigMonitoringJob' {
    BeforeEach {
        Mock Initialize-PSUConfigDB
        Mock Start-Sleep
        Mock Get-PSUConfigMonitoringComputer {
            @(
                [pscustomobject]@{
                    Id = 'LT-1001'
                    ComputerName = 'CH-GVA-LT1001'
                    SoftwareName = 'SecureConnect'
                    OwnerId = 13
                    Online = $true
                }
                [pscustomobject]@{
                    Id = 'LT-1004'
                    ComputerName = 'CH-ZRH-LT1004'
                    SoftwareName = 'SecureConnect'
                    OwnerId = 1
                    Online = $false
                }
            )
        }
        Mock Get-PSUConfigSecurityAlert { @() }
        Mock New-PSUConfigSecurityAlert
        Mock Set-PSUConfigSecurityAlert
        Mock Get-PSUConfigAwtrixDevice { 'http://clock.local' }
        Mock Remove-AwtrixNotification
        Mock Send-AwtrixNotification
        Mock Get-PSUConfigMonitoringMachineByName {
            [pscustomobject]@{
                hostname = 'CH-GVA-LT1001'
                health = [pscustomobject]@{ online = $true }
            }
        }
    }

    It 'persists one alert for each vulnerable computer' {
        Invoke-PSUConfigMonitoringJob -JobType Alert -DelaySeconds 0

        Should -Invoke New-PSUConfigSecurityAlert -Times 2 -Exactly
        Should -Invoke Send-AwtrixNotification -Times 1 -Exactly -ParameterFilter {
            $Device -eq 'http://clock.local' -and
            $Text -eq 'CRITICAL: SecureConnect vulnerability' -and
            $Color -eq '#FF0000' -and $Hold -and $Wakeup -and
            $Property.stack -eq $false
        }
    }

    It 'completes a fix alert after the simulated patch' {
        $result = Invoke-PSUConfigMonitoringJob -JobType Fix `
            -TargetComputerName 'CH-GVA-LT1001' -AlertId 7

        $result.Status | Should -Be 'Completed'
        Should -Invoke Start-Sleep -Times 1 -Exactly -ParameterFilter { $Seconds -eq 10 }
        Should -Invoke Set-PSUConfigSecurityAlert -Times 1 -Exactly -ParameterFilter {
            $Id -eq 7 -and $Status -eq 'Completed'
        }
        Should -Invoke Send-AwtrixNotification -Times 1 -Exactly -ParameterFilter {
            $Text -eq 'Fixing CH-GVA-LT1001' -and
            $Color -eq '#FFB000' -and $Duration -eq 10
        }
        Should -Invoke Send-AwtrixNotification -Times 1 -Exactly -ParameterFilter {
            $Text -eq 'Done' -and $Color -eq '#00FF00' -and $Hold
        }
    }
}
