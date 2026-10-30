BeforeAll {
    $script:moduleName = 'PSUConfig'
    Import-Module -Name $script:moduleName -Force -ErrorAction Stop
    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    Remove-Module -Name $script:moduleName -Force -ErrorAction SilentlyContinue
}

Describe 'Get-PSUConfigMonitoringMachineDataPath' {
    It 'seeds a missing writable inventory file' {
        $previousPath = $env:PSUCONFIG_MONITORING_MACHINE_DATA_PATH
        try
        {
            $env:PSUCONFIG_MONITORING_MACHINE_DATA_PATH = Join-Path -Path $TestDrive -ChildPath 'machines.json'

            $result = InModuleScope $script:moduleName {
                Get-PSUConfigMonitoringMachineDataPath
            }

            $result | Should -Be $env:PSUCONFIG_MONITORING_MACHINE_DATA_PATH
            Test-Path -Path $result | Should -BeTrue
        }
        finally
        {
            $env:PSUCONFIG_MONITORING_MACHINE_DATA_PATH = $previousPath
        }
    }
}
