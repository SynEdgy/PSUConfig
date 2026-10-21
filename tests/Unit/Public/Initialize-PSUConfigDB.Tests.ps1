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

Describe 'Initialize-PSUConfigDB' {
    BeforeEach {
        $module = Get-Module -Name $script:moduleName
        $configDirectory = Join-Path -Path $module.ModuleBase -ChildPath 'config'
        $configPath = Join-Path -Path $configDirectory -ChildPath 'PSUConfig.PSSqliteConfig.yml'
        $script:databaseConfig = Get-PSSqliteDBConfig -ConfigFile $configPath
        $script:databaseFile = Join-Path -Path $TestDrive -ChildPath 'PSUConfig.db'
        if (Test-Path -Path $script:databaseFile)
        {
            Remove-Item -Path $script:databaseFile -Force
        }

        $script:databaseConfig.DatabasePath = $TestDrive
        $script:databaseConfig.DatabaseFile = 'PSUConfig.db'
        $script:databaseConfig.ConnectionString = 'Data Source={0};' -f $script:databaseFile
    }

    It 'Should initialize the supplied database configuration' {
        PSUConfig\Initialize-PSUConfigDB -SqliteDBConfig $script:databaseConfig -Confirm:$false

        Test-Path -Path $script:databaseFile | Should -BeTrue
    }

    It 'Should not initialize the database when WhatIf is used' {
        PSUConfig\Initialize-PSUConfigDB -SqliteDBConfig $script:databaseConfig -WhatIf

        Test-Path -Path $script:databaseFile | Should -BeFalse
    }
}
