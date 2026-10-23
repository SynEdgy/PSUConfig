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

    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        & (Join-Path -Path $script:projectPath -ChildPath 'build.ps1') -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    Import-Module -Name $script:moduleName -Force -ErrorAction 'Stop'

    if (-not (Get-PSDrive -Name Page -ErrorAction SilentlyContinue))
    {
        $null = New-PSDrive -Name Page -PSProvider Variable -Root '' -Scope Global -ErrorAction SilentlyContinue
        $script:removePageDrive = $true
    }

    $PSDefaultParameterValues['InModuleScope:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Mock:ModuleName'] = $script:moduleName
    $PSDefaultParameterValues['Should:ModuleName'] = $script:moduleName
}

AfterAll {
    $PSDefaultParameterValues.Remove('Mock:ModuleName')
    $PSDefaultParameterValues.Remove('InModuleScope:ModuleName')
    $PSDefaultParameterValues.Remove('Should:ModuleName')

    if ($script:removePageDrive)
    {
        Remove-PSDrive -Name Page -Scope Global -ErrorAction SilentlyContinue
    }

    Remove-Module -Name $script:moduleName
}

Describe 'New-PSUConfigUserTable' {
    BeforeAll {
        Mock -CommandName Get-PSUConfigUser -MockWith {
            @(
                [pscustomobject]@{ id = 2; username = 'grace' }
                [pscustomobject]@{ id = 1; username = 'ada' }
            )
        }
        Mock -CommandName New-UDTableColumn -MockWith {
            param($Property, $Title, $IncludeInSearch)

            @{
                Property        = $Property
                Title           = $Title
                IncludeInSearch = $IncludeInSearch
            }
        }
        Mock -CommandName New-UDTable -MockWith {
            param($Id, $Title, $Data, $Columns, $PageSize)

            [pscustomobject]@{
                Id       = $Id
                Title    = $Title
                Data     = @($Data)
                Columns  = @($Columns)
                PageSize = $PageSize
            }
        }
        Mock -CommandName New-UDAlert -MockWith {
            param($Text)

            throw "The user table unexpectedly rendered an error alert: $Text"
        }
    }

    It 'Should render sorted PSUConfig users with the configured table settings' {
        $result = PSUConfig\New-PSUConfigUserTable -Id 'users' -Title 'Users' -PageSize 20 -Language 'en' -Confirm:$false

        $result.Id | Should -Be 'users'
        $result.Title | Should -Be 'Users'
        $result.PageSize | Should -Be 20
        $result.Data.username | Should -Be @('ada', 'grace')
        $result.Columns.Count | Should -Be 10
        @($result.Columns | Where-Object IncludeInSearch).Property | Should -Be @(
            'id'
            'firstName'
            'lastName'
            'username'
            'uid'
            'email'
            'createdOn'
            'updatedOn'
        )
        Should -Invoke -CommandName Get-PSUConfigUser -Exactly -Times 1 -Scope It
        Should -Invoke -CommandName New-UDTable -Exactly -Times 1 -Scope It
        Should -Invoke -CommandName New-UDAlert -Exactly -Times 0 -Scope It
    }

    It 'Should resolve its component-owned localized data' {
        $command = Get-Command -Name New-PSUConfigUserTable -Module $script:moduleName -ErrorAction Stop
        $commandSource = $command.ScriptBlock.ToString()

        $command.Parameters.ContainsKey('Language') | Should -BeTrue
        $command.Parameters.Language.Attributes.Mandatory | Should -Contain $true
        $commandSource | Should -Match "Name\s+= 'PSUConfig\.UserTable'"
        $commandSource | Should -Match 'Get-PSUComponentLocalizedData @psuConfigUserTableStringsParameters'
        $commandSource | Should -Match '\$Page:PSUConfigUserTableStrings = \$psuConfigUserTableStrings'
        $commandSource | Should -Match '\$Page:PSUConfigUserTableLanguage = \$Language'
    }

    It 'Should open the shared localized user form in edit mode from the Edit column' {
        $command = Get-Command -Name New-PSUConfigUserTable -Module $script:moduleName -ErrorAction Stop
        $commandSource = $command.ScriptBlock.ToString()

        $command.Parameters.ContainsKey('SyncElementId') | Should -BeTrue
        $commandSource | Should -Match 'New-UDTableColumn -Property edit -Title \$psuConfigUserTableStrings\.EditColumn'
        $commandSource | Should -Match 'New-UDCard -Title \$Page:PSUConfigUserTableStrings\.EditModalTitle'
        $commandSource | Should -Match 'UserId\s+= \[System\.Int64\]\$EventData\.id'
        $commandSource | Should -Match 'Language\s+= \$Page:PSUConfigUserTableLanguage'
        $commandSource | Should -Match 'New-PSUConfigUserForm @formParameters'
        $commandSource | Should -Match 'New-UDButton -Text \$Page:PSUConfigUserTableStrings\.Cancel'
    }

    It 'Should require modal confirmation before removing a user' {
        $command = Get-Command -Name New-PSUConfigUserTable -Module $script:moduleName -ErrorAction Stop
        $commandSource = $command.ScriptBlock.ToString()

        $commandSource | Should -Match 'New-UDTableColumn -Property remove -Title \$psuConfigUserTableStrings\.RemoveColumn'
        $commandSource | Should -Match 'New-UDButton -Text \$Page:PSUConfigUserTableStrings\.RemoveConfirm -Color error'
        $commandSource | Should -Match 'Remove-PSUConfigUser -id \$userId -Confirm:\$false'
        $commandSource | Should -Match 'Sync-UDElement -Id \$EventData\._syncElementId'
    }

    It 'Should include data columns but not action columns in free-text search' {
        $command = Get-Command -Name New-PSUConfigUserTable -Module $script:moduleName -ErrorAction Stop
        $commandSource = $command.ScriptBlock.ToString()

        @(
            'id'
            'firstName'
            'lastName'
            'username'
            'uid'
            'email'
            'createdOn'
            'updatedOn'
        ).ForEach{
            $commandSource | Should -Match ('New-UDTableColumn -Property {0} .* -IncludeInSearch' -f $_)
        }

        $commandSource | Should -Not -Match "New-UDTableColumn -Property edit .* -IncludeInSearch"
        $commandSource | Should -Not -Match "New-UDTableColumn -Property remove .* -IncludeInSearch"
    }

    It 'Should not query users when WhatIf is used' {
        PSUConfig\New-PSUConfigUserTable -Language 'en' -WhatIf | Should -BeNullOrEmpty

        Should -Invoke -CommandName Get-PSUConfigUser -Exactly -Times 0 -Scope It
        Should -Invoke -CommandName New-UDTable -Exactly -Times 0 -Scope It
    }

    It 'Should provide matching English and French component resources' {
        $englishPath = Join-Path -Path $script:projectPath -ChildPath 'source\en\PSUConfig.UserTable.strings.psd1'
        $frenchPath = Join-Path -Path $script:projectPath -ChildPath 'source\fr\PSUConfig.UserTable.strings.psd1'

        $englishData = Import-PowerShellDataFile -LiteralPath $englishPath
        $frenchData = Import-PowerShellDataFile -LiteralPath $frenchPath

        @($englishData.Keys | Sort-Object) | Should -Be @($frenchData.Keys | Sort-Object)
        $englishData.TableTitle | Should -Be 'Internal users'
        $frenchData.TableTitle | Should -Be 'Utilisateurs internes'
        ($frenchData.RemovePrompt -f 'ada', 1) | Should -Be "Supprimer l'utilisateur ada (1) ?"
    }
}
