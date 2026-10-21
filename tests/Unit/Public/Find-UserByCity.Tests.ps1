BeforeAll {
    $script:moduleName = 'PSUConfig'

    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
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

Describe 'Find-UserByCity' {
    BeforeAll {
        Mock -CommandName Invoke-RestMethod -MockWith {
            [pscustomobject]@{
                users = @(
                    [pscustomobject]@{
                        firstName = 'Ada'
                        address   = [pscustomobject]@{ city = 'London' }
                    }
                    [pscustomobject]@{
                        firstName = 'Grace'
                        address   = [pscustomobject]@{ city = 'New York' }
                    }
                )
            }
        }
    }

    It 'Should return users whose city contains the supplied value' {
        $result = @(PSUConfig\Find-UserByCity -City 'London')

        $result.Count | Should -Be 1
        $result[0].firstName | Should -Be 'Ada'
        Should -Invoke -CommandName Invoke-RestMethod -Exactly -Times 1 -Scope It
    }
}
