BeforeAll {
    $script:moduleName = 'PSUConfig'
    Import-Module -Name $script:moduleName -Force -ErrorAction Stop
    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName

    $moduleBase = (Get-Module -Name $script:moduleName).ModuleBase
    $configPath = Join-Path -Path $moduleBase -ChildPath 'config\PSUConfig.PSSqliteConfig.yml'
    $script:databaseConfig = Get-PSSqliteDBConfig -ConfigFile $configPath
    $script:databaseConfig.DatabasePath = $TestDrive
    $script:databaseConfig.DatabaseFile = 'PSUConfigMonitoring.db'
    $script:databaseConfig.ConnectionString = 'Data Source={0};' -f (
        Join-Path -Path $TestDrive -ChildPath $script:databaseConfig.DatabaseFile
    )
    InModuleScope $script:moduleName -Parameters @{ DatabaseConfig = $script:databaseConfig } {
        $script:PSUConfigDatabaseConfiguration = $DatabaseConfig
    }
    Initialize-PSUConfigDB -SqliteDBConfig $script:databaseConfig -Confirm:$false
}

AfterAll {
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    Remove-Module -Name $script:moduleName -Force -ErrorAction SilentlyContinue
}

Describe 'PSUConfig monitoring SQLite CRUD' {
    BeforeEach {
        foreach ($tableName in 'securityAlert', 'userProfile')
        {
            Remove-PSSqliteRow -SqliteDBConfig $script:databaseConfig `
                -TableName $tableName -ClauseData @{}
        }
    }

    It 'creates and filters normalized alerts' {
        $newAlertParameters = @{
            VulnerabilityId       = 'CVE-TEST'
            Severity              = 'Critical'
            SoftwareName          = 'SecureConnect'
            AffectedBeforeVersion = '5.4'
            MachineId             = 'LT-1001'
            ComputerName          = 'CH-GVA-LT1001'
            OwnerId               = 13
            MachineOnline         = $true
            Confirm               = $false
        }
        New-PSUConfigSecurityAlert @newAlertParameters

        $result = @(Get-PSUConfigSecurityAlert -ComputerName 'CH-GVA-*' `
                -Severity Critical -MachineOnline $true)

        $result.Count | Should -Be 1
        $result[0].machineOnline | Should -Be 1
        $result[0].status | Should -Be 'Detected'
    }

    It 'updates only requested alert fields and preserves false Boolean values' {
        New-PSUConfigSecurityAlert -VulnerabilityId CVE-TEST -Severity Critical `
            -SoftwareName SecureConnect -AffectedBeforeVersion 5.4 `
            -MachineId LT-1001 -ComputerName CH-GVA-LT1001 `
            -MachineOnline $true -Confirm:$false
        $id = @(Get-PSUConfigSecurityAlert)[0].id

        Set-PSUConfigSecurityAlert -Id $id -Status Fixing -MachineOnline $false -Confirm:$false

        $result = @(Get-PSUConfigSecurityAlert -Id $id)[0]
        $result.status | Should -Be 'Fixing'
        $result.machineOnline | Should -Be 0
        $result.softwareName | Should -Be 'SecureConnect'
    }

    It 'removes only the selected alert' {
        foreach ($computerName in 'CH-GVA-LT1001', 'CH-ZRH-LT1004')
        {
            New-PSUConfigSecurityAlert -VulnerabilityId CVE-TEST -Severity Critical `
                -SoftwareName SecureConnect -AffectedBeforeVersion 5.4 `
                -MachineId $computerName -ComputerName $computerName `
                -MachineOnline $true -Confirm:$false
        }
        $id = @(Get-PSUConfigSecurityAlert -ComputerName 'CH-GVA-LT1001')[0].id

        Remove-PSUConfigSecurityAlert -Id $id -Confirm:$false

        @(Get-PSUConfigSecurityAlert).Count | Should -Be 1
        @(Get-PSUConfigSecurityAlert -Id $id).Count | Should -Be 0
    }

    It 'creates, filters, upserts, and removes owner profiles' {
        New-PSUConfigUserProfile -Id 13 -FirstName Noah -LastName Hernandez `
            -Email noah@example.test -Department Engineering -Title DBA -Confirm:$false

        @(Get-PSUConfigUserProfile -DisplayName 'Noah*' -Department Engineering).Count |
            Should -Be 1

        Set-PSUConfigUserProfile -Id 13 -FirstName Noah -LastName Hernandez `
            -Email noah@example.test -Department IT -Title 'Principal DBA' -Confirm:$false

        $updated = @(Get-PSUConfigUserProfile -Id 13)[0]
        $updated.department | Should -Be 'IT'
        $updated.title | Should -Be 'Principal DBA'

        Remove-PSUConfigUserProfile -Id 13 -Confirm:$false
        @(Get-PSUConfigUserProfile -Id 13).Count | Should -Be 0
    }
}
