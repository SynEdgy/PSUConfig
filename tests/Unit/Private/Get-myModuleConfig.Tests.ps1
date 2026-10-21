BeforeAll {
    $script:moduleName = 'PSUConfig'

    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    Import-Module -Name $script:moduleName -Force -ErrorAction 'Stop'

    $typeAcceleratorsClass = [psobject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
    if (-not $typeAcceleratorsClass::Get.ContainsKey('SQLiteDBConfig'))
    {
        $typeAcceleratorsClass::Add('SQLiteDBConfig', [synedgy.PSSqlite.SqliteDBConfig])
    }

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

Describe 'Get-myModuleConfig' {
    BeforeAll {
        Mock -CommandName Get-PSSqliteDBConfigFile -MockWith {
            'PSUConfig.PSSqliteConfig.yml'
        }
        Mock -CommandName Get-PSSqliteDBConfig -MockWith {
            [synedgy.PSSqlite.SqliteDBConfig]::new($TestDrive, 'PSUConfig.db')
        }
    }

    BeforeEach {
        InModuleScope $script:moduleName {
            $script:MyModuleDBConfig = $null
        }
    }

    It 'Should resolve and cache the default database configuration' {
        $result = InModuleScope $script:moduleName {
            Get-myModuleConfig
            Get-myModuleConfig
        }

        @($result).Count | Should -Be 2
        Should -Invoke -CommandName Get-PSSqliteDBConfigFile -Exactly -Times 1 -Scope It
        Should -Invoke -CommandName Get-PSSqliteDBConfig -Exactly -Times 1 -Scope It
    }

    It 'Should reload an explicitly supplied configuration when forced' {
        InModuleScope $script:moduleName {
            Get-myModuleConfig -ConfigFile 'custom.yml' -Force
        }

        Should -Invoke -CommandName Get-PSSqliteDBConfig -Exactly -Times 1 -Scope It -ParameterFilter {
            $ConfigFile -eq 'custom.yml'
        }
    }
}
