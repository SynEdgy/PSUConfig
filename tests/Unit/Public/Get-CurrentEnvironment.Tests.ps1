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

Describe 'Get-CurrentEnvironment' {
    BeforeEach {
        InModuleScope $script:moduleName {
            $script:PSUConfigEnvironment = $null
        }
        $env:ServerEnvironment = $null
    }

    AfterEach {
        $env:ServerEnvironment = $null
    }

    It 'Should use an explicitly supplied environment' {
        PSUConfig\Get-CurrentEnvironment -Environment QA -Force | Should -Be 'QA'
    }

    It 'Should use ServerEnvironment when no environment is supplied' {
        $env:ServerEnvironment = 'PROD'

        PSUConfig\Get-CurrentEnvironment -Force | Should -Be 'PROD'
    }

    It 'Should return the cached environment until forced' {
        PSUConfig\Get-CurrentEnvironment -Environment QA -Force | Should -Be 'QA'

        PSUConfig\Get-CurrentEnvironment -Environment DEV | Should -Be 'QA'
    }
}
