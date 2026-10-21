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

Describe 'Get-PSUConfigDatabaseConfiguration' {
    BeforeAll {
        $script:databaseConfig = [synedgy.PSSqlite.SqliteDBConfig]::new($TestDrive, 'PSUConfig.db')
        Mock -CommandName Get-PSUConfigSetting -MockWith {
            @{
                SqliteDBConfig = $script:databaseConfig
            }
        }
        Mock -CommandName Get-PSSqliteDBConfig -MockWith {
            [synedgy.PSSqlite.SqliteDBConfig]::new($TestDrive, 'PSUConfig.db')
        }
    }

    BeforeEach {
        InModuleScope $script:moduleName {
            $script:PSUConfigDatabaseConfiguration = $null
        }
    }

    It 'Should return the database configuration from the merged module configuration' {
        $result = InModuleScope $script:moduleName { Get-PSUConfigDatabaseConfiguration }

        $result | Should -Be $script:databaseConfig
        Should -Invoke -CommandName Get-PSUConfigSetting -Exactly -Times 1 -Scope It
    }

    It 'Should reload an explicitly supplied configuration when forced' {
        InModuleScope $script:moduleName {
            Get-PSUConfigDatabaseConfiguration -ConfigFile 'custom.yml' -Force
        }

        Should -Invoke -CommandName Get-PSSqliteDBConfig -Exactly -Times 1 -Scope It -ParameterFilter {
            $ConfigFile -eq 'custom.yml'
        }
    }
}
