BeforeAll {
    $script:moduleName = 'PSUConfig'

    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        & "$PSScriptRoot/../../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
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

Describe 'Get-PSUConfigUser' {
    BeforeAll {
        $script:databaseConfig = [synedgy.PSSqlite.SqliteDBConfig]::new($TestDrive, 'PSUConfig.db')
        Mock -CommandName Get-PSUConfigDatabaseConfiguration -MockWith { $script:databaseConfig }
        Mock -CommandName Get-PSSqliteRow -MockWith {
            [pscustomobject]@{ username = 'ada' }
        }
    }

    It 'Should forward filters to the PSSqlite row query' {
        $result = PSUConfig\Get-PSUConfigUser -username 'ada*' -createdOnAfter ([datetime]'2026-01-01')

        $result.username | Should -Be 'ada'
        Should -Invoke -CommandName Get-PSSqliteRow -Exactly -Times 1 -Scope It -ParameterFilter {
            $TableName -eq 'psuConfigUser' -and
            $ClauseData.username -eq 'ada*' -and
            $ClauseData.createdOnAfter -eq [datetime]'2026-01-01'
        }
    }
}
