BeforeAll {
    $script:moduleName = 'PSUConfig'

    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        & "$PSScriptRoot/../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    Import-Module -Name $script:moduleName -Force -ErrorAction 'Stop'

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    Remove-Module -Name $script:moduleName
}

Describe 'Set-PSUConfigSetting' {
    BeforeAll {
        Mock -CommandName Get-CurrentEnvironment
        Mock -CommandName Get-PSUConfigSetting
    }

    It 'Should reload the selected environment configuration' {
        PSUConfig\Set-PSUConfigSetting -Environment QA -Confirm:$false

        Should -Invoke -CommandName Get-CurrentEnvironment -Exactly -Times 1 -Scope It -ParameterFilter {
            $Environment -eq 'QA' -and $Force
        }
        Should -Invoke -CommandName Get-PSUConfigSetting -Exactly -Times 1 -Scope It -ParameterFilter {
            $Environment -eq 'QA' -and $Force
        }
    }

    It 'Should not reload configuration when WhatIf is used' {
        PSUConfig\Set-PSUConfigSetting -Environment QA -WhatIf

        Should -Invoke -CommandName Get-CurrentEnvironment -Exactly -Times 0 -Scope It
        Should -Invoke -CommandName Get-PSUConfigSetting -Exactly -Times 0 -Scope It
    }
}
