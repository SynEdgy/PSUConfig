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

Describe 'New-PSUConfigAddUserButton' {
    It 'Should be exported with ShouldProcess and refresh parameters' {
        $command = Get-Command -Name New-PSUConfigAddUserButton -Module $script:moduleName -ErrorAction Stop

        $command.Parameters.ContainsKey('Id') | Should -BeTrue
        $command.Parameters.ContainsKey('SyncElementId') | Should -BeTrue
        $command.Parameters.ContainsKey('Language') | Should -BeTrue
        $command.Parameters.Language.Attributes.Mandatory | Should -Contain $true
        $command.Parameters.ContainsKey('WhatIf') | Should -BeTrue
        $command.Parameters.ContainsKey('Confirm') | Should -BeTrue
    }

    It 'Should resolve its component-owned localized data' {
        $command = Get-Command -Name New-PSUConfigAddUserButton -Module $script:moduleName -ErrorAction Stop
        $commandSource = $command.ScriptBlock.ToString()

        $commandSource | Should -Match "Name\s+= 'PSUConfig\.AddUserButton'"
        $commandSource | Should -Match 'Language\s+= \$Language'
        $commandSource | Should -Match 'DefaultUILanguage\s+= \(Get-PSUConfigSetting\)\.DefaultUILanguage'
        $commandSource | Should -Match 'Cache\s+= \$Cache:PSUConfigLocalization'
        $commandSource | Should -Match 'Get-PSUComponentLocalizedData @psuConfigAddUserButtonStringsParameters'
    }

    It 'Should open a localized modal containing the reusable user form' {
        $command = Get-Command -Name New-PSUConfigAddUserButton -Module $script:moduleName -ErrorAction Stop
        $commandSource = $command.ScriptBlock.ToString()

        $commandSource | Should -Match 'New-UDFloatingActionButton'
        $commandSource | Should -Match '} -TooltipContent {'
        $commandSource | Should -Match 'Show-UDModal'
        $commandSource | Should -Match 'New-UDCard -Title \$Page:PSUConfigAddUserButtonStrings\.ModalTitle'
        $commandSource | Should -Match 'New-PSUConfigUserForm @formParameters'
        $commandSource | Should -Match 'New-UDButton -Text \$Page:PSUConfigAddUserButtonStrings\.Cancel'
        $commandSource | Should -Match 'New-UDTypography -Text \$psuConfigAddUserButtonStrings\.Tooltip'
    }

    It 'Should pass deferred component state through Page scope' {
        $command = Get-Command -Name New-PSUConfigAddUserButton -Module $script:moduleName -ErrorAction Stop
        $commandSource = $command.ScriptBlock.ToString()

        $commandSource | Should -Match '\$Page:PSUConfigAddUserButtonSyncElementId = \$resolvedSyncElementId'
        $commandSource | Should -Match '\$Page:PSUConfigAddUserButtonStrings = \$psuConfigAddUserButtonStrings'
        $commandSource | Should -Match '\$Page:PSUConfigAddUserButtonLanguage = \$Language'
        $commandSource | Should -Match 'SyncElementId = \$Page:PSUConfigAddUserButtonSyncElementId'
        $commandSource | Should -Match 'Language\s+= \$Page:PSUConfigAddUserButtonLanguage'
    }

    It 'Should provide matching English and French component resources' {
        $englishPath = Join-Path -Path $script:projectPath -ChildPath 'source\en\PSUConfig.AddUserButton.strings.psd1'
        $frenchPath = Join-Path -Path $script:projectPath -ChildPath 'source\fr\PSUConfig.AddUserButton.strings.psd1'

        $englishData = Import-PowerShellDataFile -LiteralPath $englishPath
        $frenchData = Import-PowerShellDataFile -LiteralPath $frenchPath

        @($englishData.Keys | Sort-Object) | Should -Be @($frenchData.Keys | Sort-Object)
        $englishData.Tooltip | Should -Be 'Add PSUConfig user'
        $frenchData.Tooltip | Should -Be 'Ajouter un utilisateur PSUConfig'
        $frenchData.Cancel | Should -Be 'Annuler'
    }
}
