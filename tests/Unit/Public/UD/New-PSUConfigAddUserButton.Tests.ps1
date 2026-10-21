BeforeAll {
    $script:moduleName = 'PSUConfig'
    $projectPath = $PSScriptRoot

    while (-not (Test-Path -Path (Join-Path -Path $projectPath -ChildPath 'build.ps1')))
    {
        $parentPath = Split-Path -Path $projectPath -Parent

        if ($parentPath -eq $projectPath)
        {
            throw 'Could not locate repository root containing build.ps1.'
        }

        $projectPath = $parentPath
    }

    & (Join-Path -Path $projectPath -ChildPath 'build.ps1') -Tasks 'noop' > $null
    Import-Module -Name $script:moduleName -Force -ErrorAction Stop

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

Describe 'New-PSUConfigAddUserButton' {
    It 'Should be exported with ShouldProcess and refresh parameters' {
        $command = Get-Command -Name New-PSUConfigAddUserButton -Module $script:moduleName -ErrorAction Stop

        $command.Parameters.ContainsKey('Id') | Should -BeTrue
        $command.Parameters.ContainsKey('SyncElementId') | Should -BeTrue
        $command.Parameters.ContainsKey('WhatIf') | Should -BeTrue
        $command.Parameters.ContainsKey('Confirm') | Should -BeTrue
    }

    It 'Should open a modal containing the reusable user form' {
        $command = Get-Command -Name New-PSUConfigAddUserButton -Module $script:moduleName -ErrorAction Stop
        $commandSource = $command.ScriptBlock.ToString()

        $commandSource | Should -Match 'New-UDFloatingActionButton'
        $commandSource | Should -Match 'Show-UDModal'
        $commandSource | Should -Match "New-UDCard -Title 'Add PSUConfig user'"
        $commandSource | Should -Match 'New-PSUConfigUserForm @formParameters'
        $commandSource | Should -Match "New-UDButton -Text 'Cancel'"
    }

    It 'Should pass the sync element id through Page scope' {
        $command = Get-Command -Name New-PSUConfigAddUserButton -Module $script:moduleName -ErrorAction Stop
        $commandSource = $command.ScriptBlock.ToString()

        $commandSource | Should -Match '\$Page:PSUConfigAddUserButtonSyncElementId = \$resolvedSyncElementId'
        $commandSource | Should -Match 'SyncElementId = \$Page:PSUConfigAddUserButtonSyncElementId'
    }
}
