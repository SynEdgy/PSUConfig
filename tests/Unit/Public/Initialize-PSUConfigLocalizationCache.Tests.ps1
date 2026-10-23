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

Describe 'Initialize-PSUConfigLocalizationCache' {
    It 'Should initialize the PSUConfigDemo resource through the shared helper' {
        Mock -CommandName Get-PSUConfigSetting -MockWith {
            @{
                DefaultUILanguage = 'fr'
            }
        }
        Mock -CommandName Initialize-PSULocalizationCache -MockWith {
            $Cache.en = @{
                HeroTitle = 'English title'
            }
            $Cache.fr = @{
                HeroTitle = 'French title'
            }
            return $Cache
        }

        $cache = [System.Collections.Hashtable]::Synchronized(@{})
        $initializeParameters = @{
            Cache = $cache
            Force = $true
        }
        $expectedModuleBase = (PSUConfig\Get-PSUConfigModule).ModuleBase
        $result = PSUConfig\Initialize-PSUConfigLocalizationCache @initializeParameters

        $result.en.HeroTitle | Should -Be 'English title'
        $result.fr.HeroTitle | Should -Be 'French title'
        $cache.PSUConfigDemo.en.HeroTitle | Should -Be 'English title'
        Should -Invoke -CommandName Initialize-PSULocalizationCache -Exactly -Times 1 -Scope It -ParameterFilter {
            $Name -eq 'PSUConfigDemo' -and
            $ModuleBase -eq $expectedModuleBase -and
            $DefaultUICulture -eq 'fr' -and
            $Cache.Contains('en') -and
            -not $Cache.Contains('PSUConfigDemo') -and
            $Force
        }
    }
}
