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

Describe 'Get-PSUConfigDatabaseAnalysis' {
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
        PSUConfig\Initialize-PSUConfigDB -SqliteDBConfig $script:databaseConfig -Confirm:$false
    }

    It 'Should report each table count and the stored schema version' {
        $rowData = @{
            firstName = 'Ada'
            lastName  = 'Lovelace'
            username  = 'ada'
            email     = 'ada@example.com'
            createdOn = Get-Date
        }
        $newRowParameters = @{
            SqliteDBConfig = $script:databaseConfig
            TableName      = 'psuConfigUser'
            RowData        = $rowData
        }
        $null = New-PSSqliteRow @newRowParameters

        $result = @(PSUConfig\Get-PSUConfigDatabaseAnalysis -SqliteDBConfig $script:databaseConfig)

        $result.TableName | Should -Contain '_metadata'
        $result.TableName | Should -Contain 'psuConfigUser'
        ($result | Where-Object -Property TableName -EQ 'psuConfigUser').RecordCount | Should -Be 1
        ($result | Where-Object -Property TableName -EQ '_metadata').RecordCount | Should -Be 1
        $result.SchemaVersion | Select-Object -Unique | Should -Be '0.0.3'
    }

    It 'Should emit the startup verbose message before analysis results' {
        $output = @(PSUConfig\Get-PSUConfigDatabaseAnalysis -SqliteDBConfig $script:databaseConfig 4>&1)

        $output[0] | Should -BeOfType [System.Management.Automation.VerboseRecord]
        $output[0].Message | Should -Be 'Starting PSUConfig database analysis.'
    }

    It 'Should throw when the configured database file does not exist' {
        $missingDatabaseConfig = [synedgy.PSSqlite.SqliteDBConfig]::new($TestDrive, 'missing.db')

        { PSUConfig\Get-PSUConfigDatabaseAnalysis -SqliteDBConfig $missingDatabaseConfig } |
            Should -Throw -ExpectedMessage '*database file was not found*'
    }
}
