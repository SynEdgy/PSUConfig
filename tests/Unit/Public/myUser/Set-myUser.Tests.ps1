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

Describe 'Set-myUser' {
    BeforeAll {
        $script:databaseConfig = [synedgy.PSSqlite.SqliteDBConfig]::new($TestDrive, 'PSUConfig.db')
        Mock -CommandName Get-PSUConfigDatabaseConfiguration -MockWith { $script:databaseConfig }
        Mock -CommandName Set-PSSqliteRow
    }

    It 'Should update supplied fields and add an update timestamp' {
        PSUConfig\Set-myUser -id 42 -Email 'ada@example.com' -Confirm:$false

        Should -Invoke -CommandName Set-PSSqliteRow -Exactly -Times 1 -Scope It -ParameterFilter {
            $TableName -eq 'myUser' -and
            $ClauseData.id -eq 42 -and
            $RowData.Email -eq 'ada@example.com' -and
            $RowData.ContainsKey('updatedOn') -and
            -not $RowData.ContainsKey('id')
        }
    }

    It 'Should not update a row when WhatIf is used' {
        PSUConfig\Set-myUser -id 42 -Email 'ada@example.com' -WhatIf

        Should -Invoke -CommandName Set-PSSqliteRow -Exactly -Times 0 -Scope It
    }
}
