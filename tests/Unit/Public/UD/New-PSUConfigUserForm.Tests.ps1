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

Describe 'New-PSUConfigUserForm' {
    It 'Should be exported with ShouldProcess, refresh, and edit parameters' {
        $command = Get-Command -Name New-PSUConfigUserForm -Module $script:moduleName -ErrorAction Stop

        $command.Parameters.ContainsKey('FormId') | Should -BeTrue
        $command.Parameters.ContainsKey('SyncElementId') | Should -BeTrue
        $command.Parameters.ContainsKey('UserId') | Should -BeTrue
        $command.Parameters.ContainsKey('FirstName') | Should -BeTrue
        $command.Parameters.ContainsKey('LastName') | Should -BeTrue
        $command.Parameters.ContainsKey('Username') | Should -BeTrue
        $command.Parameters.ContainsKey('Email') | Should -BeTrue
        $command.Parameters.ContainsKey('WhatIf') | Should -BeTrue
        $command.Parameters.ContainsKey('Confirm') | Should -BeTrue
    }

    It 'Should render all required PSUConfig user inputs' {
        $command = Get-Command -Name New-PSUConfigUserForm -Module $script:moduleName -ErrorAction Stop
        $commandSource = $command.ScriptBlock.ToString()

        $commandSource | Should -Match "New-UDTextbox -Id 'psuConfigUserFirstName'"
        $commandSource | Should -Match "New-UDTextbox -Id 'psuConfigUserLastName'"
        $commandSource | Should -Match "New-UDTextbox -Id 'psuConfigUsername'"
        $commandSource | Should -Match "New-UDTextbox -Id 'psuConfigUserEmail'"
    }

    It 'Should create or update a user and sync through Page scope on submit' {
        $command = Get-Command -Name New-PSUConfigUserForm -Module $script:moduleName -ErrorAction Stop
        $commandSource = $command.ScriptBlock.ToString()

        $commandSource | Should -Match '\$Page:PSUConfigUserFormSyncElementId = \$resolvedSyncElementId'
        $commandSource | Should -Match '\$Page:PSUConfigUserFormUserId = \$UserId'
        $commandSource | Should -Match 'New-PSUConfigUser @userParameters'
        $commandSource | Should -Match 'Set-PSUConfigUser @userParameters'
        $commandSource | Should -Match 'Confirm\s+= \$false'
        $commandSource | Should -Match 'Hide-UDModal'
        $commandSource | Should -Match 'Sync-UDElement -Id \$Page:PSUConfigUserFormSyncElementId'
    }
}
