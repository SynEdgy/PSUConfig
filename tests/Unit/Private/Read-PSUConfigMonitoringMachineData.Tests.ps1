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

Describe 'Read-PSUConfigMonitoringMachineData' {
    It 'loads machine objects from the resolved JSON file' {
        $dataPath = Join-Path -Path $TestDrive -ChildPath 'machines.json'
        '{"machines":[{"id":"LT-1001","hostname":"CH-GVA-LT1001"}]}' |
            Set-Content -Path $dataPath -Encoding utf8NoBOM
        Mock Get-PSUConfigMonitoringMachineDataPath { $dataPath }

        $result = InModuleScope $script:moduleName {
            Read-PSUConfigMonitoringMachineData
        }

        $result.machines.Count | Should -Be 1
        $result.machines[0].hostname | Should -Be 'CH-GVA-LT1001'
    }
}
