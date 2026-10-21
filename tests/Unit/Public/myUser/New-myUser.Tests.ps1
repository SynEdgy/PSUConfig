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

Describe 'New-myUser' {
    BeforeAll {
        $script:databaseConfig = [synedgy.PSSqlite.SqliteDBConfig]::new($TestDrive, 'PSUConfig.db')
        Mock -CommandName Get-myModuleConfig -MockWith { $script:databaseConfig }
        Mock -CommandName New-PSSqliteRow
    }

    It 'Should insert the supplied user data with a creation timestamp' {
        $parameters = @{
            FirstName = 'Ada'
            LastName  = 'Lovelace'
            Username  = 'ada'
            Email     = 'ada@example.com'
            Confirm   = $false
        }

        PSUConfig\New-myUser @parameters

        Should -Invoke -CommandName New-PSSqliteRow -Exactly -Times 1 -Scope It -ParameterFilter {
            $TableName -eq 'myUser' -and
            $RowData.FirstName -eq 'Ada' -and
            $RowData.ContainsKey('createdOn')
        }
    }

    It 'Should not insert a row when WhatIf is used' {
        PSUConfig\New-myUser -FirstName 'Ada' -LastName 'Lovelace' -Username 'ada' -Email 'ada@example.com' -WhatIf

        Should -Invoke -CommandName New-PSSqliteRow -Exactly -Times 0 -Scope It
    }
}
