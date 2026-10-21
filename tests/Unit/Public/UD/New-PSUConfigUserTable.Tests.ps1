BeforeAll {
    $script:moduleName = 'PSUConfig'

    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        & "$PSScriptRoot/../../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    Import-Module -Name $script:moduleName -Force -ErrorAction 'Stop'

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
        $result = PSUConfig\New-PSUConfigUserTable -Id 'users' -Title 'Users' -PageSize 20 -Confirm:$false

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

    It 'Should open the shared user form in edit mode from the Edit column' {
        $command = Get-Command -Name New-PSUConfigUserTable -Module $script:moduleName -ErrorAction Stop
        $commandSource = $command.ScriptBlock.ToString()

        $command.Parameters.ContainsKey('SyncElementId') | Should -BeTrue
        $commandSource | Should -Match "New-UDTableColumn -Property edit -Title 'Edit'"
        $commandSource | Should -Match "New-UDCard -Title 'Edit PSUConfig user'"
        $commandSource | Should -Match 'UserId\s+= \[System\.Int64\]\$EventData\.id'
        $commandSource | Should -Match 'New-PSUConfigUserForm @formParameters'
        $commandSource | Should -Match "New-UDButton -Text 'Cancel'"
    }

    It 'Should require modal confirmation before removing a user' {
        $command = Get-Command -Name New-PSUConfigUserTable -Module $script:moduleName -ErrorAction Stop
        $commandSource = $command.ScriptBlock.ToString()

        $commandSource | Should -Match "New-UDTableColumn -Property remove -Title 'Remove'"
        $commandSource | Should -Match "New-UDButton -Text 'Remove user' -Color error"
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
        PSUConfig\New-PSUConfigUserTable -WhatIf | Should -BeNullOrEmpty

        Should -Invoke -CommandName Get-PSUConfigUser -Exactly -Times 0 -Scope It
        Should -Invoke -CommandName New-UDTable -Exactly -Times 0 -Scope It
    }
}
