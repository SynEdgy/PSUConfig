BeforeAll {
    $script:moduleName = 'PSUConfig'

    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
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

Describe 'Get-PSUConfigSetting' {
    BeforeAll {
        $script:databaseConfig = [synedgy.PSSqlite.SqliteDBConfig]::new($TestDrive, 'PSUConfig.db')
        Mock -CommandName Get-PSSqliteDBConfig -MockWith {
            $script:databaseConfig
        }

        Set-Content -Path (Join-Path -Path $TestDrive -ChildPath 'PSUConfig.PSSqliteConfig.yml') -Value 'version: 0.1.0'
        Set-Content -Path (Join-Path -Path $TestDrive -ChildPath 'PSUConfig.config.yml') -Value @'
SharedSetting: shared
Environments:
  DEV:
    UniversalServerUrl: http://localhost:5000
  QA:
    UniversalServerUrl: https://psuconfig-qa.synedgy.com/
  PROD:
    UniversalServerUrl: https://psuconfig.synedgy.com/
'@
    }

    BeforeEach {
        InModuleScope $script:moduleName {
            $script:MyModuleConfig = $null
        }
    }

    It 'Should merge general and selected environment configuration' {
        $result = PSUConfig\Get-PSUConfigSetting -Environment QA -ConfigFolder $TestDrive -Force

        $result.CurrentEnvironment | Should -Be 'QA'
        $result.SharedSetting | Should -Be 'shared'
        $result.UniversalServerUrl | Should -Be 'https://psuconfig-qa.synedgy.com/'
        $result.SqliteDBConfig | Should -Be $script:databaseConfig
    }

    It 'Should cache the merged configuration until forced' {
        PSUConfig\Get-PSUConfigSetting -Environment DEV -ConfigFolder $TestDrive
        PSUConfig\Get-PSUConfigSetting -Environment DEV -ConfigFolder $TestDrive

        Should -Invoke -CommandName Get-PSSqliteDBConfig -Exactly -Times 1 -Scope It
    }
}
