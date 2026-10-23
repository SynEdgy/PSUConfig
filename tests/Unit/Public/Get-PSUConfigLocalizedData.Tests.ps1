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

Describe 'Get-PSUConfigLocalizedData' {
    It 'Should return the requested dictionary from the environment cache' {
        $cache = @{
            PSUConfigDemo = @{
                en = @{ HeroTitle = 'English title' }
                fr = @{ HeroTitle = 'French title' }
            }
        }

        $result = PSUConfig\Get-PSUConfigLocalizedData -Language 'fr' -Cache $cache

        $result.HeroTitle | Should -Be 'French title'
    }

    It 'Should keep named resource bundles isolated in the same cache' {
        Mock -CommandName Get-PSULocalizationLanguage -MockWith {
            @('en', 'fr')
        }

        $cache = @{
            PSUConfigDemo = @{
                fr = @{ Title = 'Demo title' }
            }
            'PSUConfig.Users' = @{
                fr = @{ Title = 'Users title' }
            }
        }
        $parameters = @{
            Name     = 'PSUConfig.Users'
            Language = 'fr'
            Cache    = $cache
        }
        $result = PSUConfig\Get-PSUConfigLocalizedData @parameters

        $result.Title | Should -Be 'Users title'
    }

    It 'Should load the bundled Users localization resource' {
        $cache = [System.Collections.Hashtable]::Synchronized(@{})
        $parameters = @{
            Name     = 'PSUConfig.Users'
            Language = 'fr'
            Cache    = $cache
        }
        $result = PSUConfig\Get-PSUConfigLocalizedData @parameters

        ($result.PageTitle -f 'PSUConfig') | Should -Be 'Utilisateurs PSUConfig'
        $result.PageEyebrow | Should -Be 'SYNEDGY - DONNÉES SQLITE'
        $cache.'PSUConfig.Users'.fr.PageTitle | Should -Be 'Utilisateurs {0}'
    }

    It 'Should initialize the environment cache when it is missing' {
        Mock -CommandName Initialize-PSUConfigLocalizationCache -MockWith {
            $Cache[$Name] = @{
                en = @{
                    HeroTitle = 'English title'
                }
                fr = @{
                    HeroTitle = 'French title'
                }
            }
            return $Cache[$Name]
        }

        $cache = [System.Collections.Hashtable]::Synchronized(@{})
        $result = PSUConfig\Get-PSUConfigLocalizedData -Language 'en' -Cache $cache

        $result.HeroTitle | Should -Be 'English title'
        $cache.PSUConfigDemo.Keys | Should -Contain 'fr'
        Should -Invoke -CommandName Initialize-PSUConfigLocalizationCache -Exactly -Times 1 -Scope It -ParameterFilter {
            $Name -eq 'PSUConfigDemo' -and $Cache -eq $cache
        }
    }
}
