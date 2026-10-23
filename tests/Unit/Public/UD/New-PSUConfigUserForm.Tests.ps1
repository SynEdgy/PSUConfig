BeforeAll {
    $script:moduleName = 'PSUConfig'
    $script:projectPath = $PSScriptRoot

    while (-not (Test-Path -Path (Join-Path -Path $script:projectPath -ChildPath 'build.ps1')))
    {
        $parentPath = Split-Path -Path $script:projectPath -Parent

        if ($parentPath -eq $script:projectPath)
        {
            throw 'Could not locate repository root containing build.ps1.'
        }

        $script:projectPath = $parentPath
    }

    & (Join-Path -Path $script:projectPath -ChildPath 'build.ps1') -Tasks 'noop' > $null
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
        $command.Parameters.ContainsKey('Language') | Should -BeTrue
        $command.Parameters.Language.Attributes.Mandatory | Should -Contain $true
        $command.Parameters.ContainsKey('WhatIf') | Should -BeTrue
        $command.Parameters.ContainsKey('Confirm') | Should -BeTrue
    }

    It 'Should resolve its component-owned localized data' {
        $command = Get-Command -Name New-PSUConfigUserForm -Module $script:moduleName -ErrorAction Stop
        $commandSource = $command.ScriptBlock.ToString()

        $commandSource | Should -Match "Name\s+= 'PSUConfig\.UserForm'"
        $commandSource | Should -Match 'Language\s+= \$Language'
        $commandSource | Should -Match 'Get-PSUComponentLocalizedData @psuConfigUserFormStringsParameters'
        $commandSource | Should -Match '\$Page:PSUConfigUserFormStrings = \$psuConfigUserFormStrings'
    }

    It 'Should render all required PSUConfig user inputs with localized labels' {
        $command = Get-Command -Name New-PSUConfigUserForm -Module $script:moduleName -ErrorAction Stop
        $commandSource = $command.ScriptBlock.ToString()

        $commandSource | Should -Match "New-UDTextbox -Id 'psuConfigUserFirstName'"
        $commandSource | Should -Match "New-UDTextbox -Id 'psuConfigUserLastName'"
        $commandSource | Should -Match "New-UDTextbox -Id 'psuConfigUsername'"
        $commandSource | Should -Match "New-UDTextbox -Id 'psuConfigUserEmail'"
        $commandSource | Should -Match '-Label \$psuConfigUserFormStrings\.FirstNameLabel'
        $commandSource | Should -Match 'SubmitText\s+= \$submitText'
        $commandSource | Should -Match 'New-UDForm @formParameters'
        $commandSource | Should -Not -Match '\}\s+-SubmitText'
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

    It 'Should provide matching English and French component resources' {
        $englishPath = Join-Path -Path $script:projectPath -ChildPath 'source\en\PSUConfig.UserForm.strings.psd1'
        $frenchPath = Join-Path -Path $script:projectPath -ChildPath 'source\fr\PSUConfig.UserForm.strings.psd1'

        $englishData = Import-PowerShellDataFile -LiteralPath $englishPath
        $frenchData = Import-PowerShellDataFile -LiteralPath $frenchPath

        @($englishData.Keys | Sort-Object) | Should -Be @($frenchData.Keys | Sort-Object)
        $englishData.CreateSubmit | Should -Be 'Create user'
        $frenchData.CreateSubmit | Should -Be "Créer l'utilisateur"
        ($frenchData.UserUpdatedMessage -f 'ada') | Should -Be 'Utilisateur ada mis à jour.'
    }
}
