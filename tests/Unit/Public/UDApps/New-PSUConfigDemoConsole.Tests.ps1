BeforeAll {
    $script:moduleName = 'PSUConfig'

    # If the module is not found, run the build task 'noop'.
    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        # Redirect all streams to $null, except the error stream (stream 2)
        & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    # Re-import the module using force to get any code changes between runs.
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

Describe 'New-PSUConfigDemoConsole' {
    It 'Should be available as an exported command' {
        $command = Get-Command -Name New-PSUConfigDemoConsole -Module $script:moduleName -ErrorAction Stop

        $command | Should -Not -BeNullOrEmpty
    }

    It 'Should support ShouldProcess' {
        $command = Get-Command -Name New-PSUConfigDemoConsole -Module $script:moduleName -ErrorAction Stop

        $command.Parameters.Keys | Should -Contain 'Confirm'
        $command.Parameters.Keys | Should -Contain 'WhatIf'
    }

    It 'Should not build the app definition when -WhatIf is used' {
        PSUConfig\New-PSUConfigDemoConsole -WhatIf | Should -BeNullOrEmpty
    }

    It 'Should bundle the SynEdgy visual assets' {
        $appPath = PSUConfig\Get-PSUConfigAppPath
        $assetPath = Join-Path -Path $appPath -ChildPath 'assets'

        Test-Path -Path (Join-Path -Path $assetPath -ChildPath 'synedgy-logo.svg') | Should -BeTrue
        Test-Path -Path (Join-Path -Path $assetPath -ChildPath 'powershell-cube.jpg') | Should -BeTrue
    }

    It 'Should provide separate light and dark PSU theme definitions' {
        $appPath = PSUConfig\Get-PSUConfigAppPath
        $themePath = Join-Path -Path $appPath -ChildPath 'theme.psd1'
        $theme = Import-PowerShellDataFile -Path $themePath

        $theme.Keys | Should -Contain 'light'
        $theme.Keys | Should -Contain 'dark'
        $theme.light.palette.background.default | Should -Not -BeNullOrEmpty
        $theme.dark.palette.background.default | Should -Not -BeNullOrEmpty
    }

    It 'Should bundle English, French, and German Home localization resources' {
        $moduleBase = (Get-Module -Name $script:moduleName).ModuleBase
        $englishPath = Join-Path -Path $moduleBase -ChildPath 'en'
        $englishPath = Join-Path -Path $englishPath -ChildPath 'PSUConfigDemo.strings.psd1'
        $frenchPath = Join-Path -Path $moduleBase -ChildPath 'fr'
        $frenchPath = Join-Path -Path $frenchPath -ChildPath 'PSUConfigDemo.strings.psd1'
        $germanPath = Join-Path -Path $moduleBase -ChildPath 'de'
        $germanPath = Join-Path -Path $germanPath -ChildPath 'PSUConfigDemo.strings.psd1'
        $englishStrings = Import-PowerShellDataFile -Path $englishPath
        $frenchStrings = Import-PowerShellDataFile -Path $frenchPath
        $germanStrings = Import-PowerShellDataFile -Path $germanPath
        $englishUsersPath = Join-Path -Path $moduleBase -ChildPath 'en'
        $englishUsersPath = Join-Path -Path $englishUsersPath -ChildPath 'PSUConfig.Users.psd1'
        $frenchUsersPath = Join-Path -Path $moduleBase -ChildPath 'fr'
        $frenchUsersPath = Join-Path -Path $frenchUsersPath -ChildPath 'PSUConfig.Users.psd1'
        $germanUsersPath = Join-Path -Path $moduleBase -ChildPath 'de'
        $germanUsersPath = Join-Path -Path $germanUsersPath -ChildPath 'PSUConfig.Users.psd1'
        $englishUsersStrings = Import-PowerShellDataFile -Path $englishUsersPath
        $frenchUsersStrings = Import-PowerShellDataFile -Path $frenchUsersPath
        $germanUsersStrings = Import-PowerShellDataFile -Path $germanUsersPath
        $appPath = PSUConfig\Get-PSUConfigAppPath
        $homePath = Join-Path -Path $appPath -ChildPath 'pages'
        $homePath = Join-Path -Path $homePath -ChildPath 'Home.ps1'
        $homeSource = Get-Content -Path $homePath -Raw
        $usersPath = Join-Path -Path $appPath -ChildPath 'pages'
        $usersPath = Join-Path -Path $usersPath -ChildPath 'Users.ps1'
        $usersSource = Get-Content -Path $usersPath -Raw
        $jobInfoPath = Join-Path -Path $appPath -ChildPath 'pages'
        $jobInfoPath = Join-Path -Path $jobInfoPath -ChildPath 'job_info.ps1'
        $jobInfoSource = Get-Content -Path $jobInfoPath -Raw

        $englishStrings.HeroTitle | Should -Be 'PowerShell Universal, managed as code.'
        $frenchStrings.HeroTitle | Should -Match 'comme du code'
        $frenchStrings.HeroTitle | Should -Not -Be $englishStrings.HeroTitle
        $germanStrings.HeroTitle | Should -Be 'PowerShell Universal, als Code verwaltet.'
        $englishStrings.NavigationHome | Should -Be 'Module-first demo'
        $frenchStrings.NavigationHome | Should -Be 'Démo modulaire'
        $germanStrings.NavigationHome | Should -Be 'Modulbasierte Demo'
        @($englishStrings.Keys | Sort-Object) | Should -Be @($frenchStrings.Keys | Sort-Object)
        @($englishStrings.Keys | Sort-Object) | Should -Be @($germanStrings.Keys | Sort-Object)
        ($englishUsersStrings.PageTitle -f 'PSUConfig') | Should -Be 'PSUConfig users'
        ($frenchUsersStrings.PageTitle -f 'PSUConfig') | Should -Be 'Utilisateurs PSUConfig'
        ($germanUsersStrings.PageTitle -f 'PSUConfig') | Should -Be 'PSUConfig-Benutzer'
        $frenchUsersStrings.PageEyebrow | Should -Not -Be $englishUsersStrings.PageEyebrow
        @($englishUsersStrings.Keys | Sort-Object) | Should -Be @($frenchUsersStrings.Keys | Sort-Object)
        @($englishUsersStrings.Keys | Sort-Object) | Should -Be @($germanUsersStrings.Keys | Sort-Object)
        $homeSource | Should -Match 'Get-PSUConfigModule'
        $homeSource | Should -Match 'Resolve-PSULocalizationLanguage'
        $homeSource | Should -Match 'Get-PSUConfigLocalizedData'
        $homeSource | Should -Match '\$psuConfigDemoStrings = Get-PSUConfigLocalizedData'
        $homeSource | Should -Match '\$Page:PSUConfigDemoStrings = \$psuConfigDemoStrings'
        $homeSource | Should -Match '\$psuConfigDemoStrings\.DeliverySectionTitle'
        $homeSource | Should -Match '\$psuConfigDemoStrings\.SurfacesSectionTitle'
        $homeSource | Should -Match '\$psuConfigDemoStrings\.TargetSectionTitle'
        $homeSource | Should -Match "# 'From repository to running platform'"
        $homeSource | Should -Not -Match "New-UDTypography\s+-Text\s+'From repository to running platform'"
        $homeSource | Should -Match "# 'One module, every PSU surface'"
        $homeSource | Should -Not -Match "New-UDTypography\s+-Text\s+'One module, every PSU surface'"
        $homeSource | Should -Match "# 'Active target'"
        $homeSource | Should -Not -Match "New-UDTypography\s+-Text\s+'Active target'"
        $homeSource | Should -Not -Match '\$tl:'
        $usersSource | Should -Match "Name\s*=\s*'PSUConfig\.Users'"
        $usersSource | Should -Match 'Get-PSUConfigLocalizedData'
        $usersSource | Should -Match '\$psuConfigUsersStrings = Get-PSUConfigLocalizedData'
        $usersSource | Should -Not -Match "Text 'PSUConfig users'"
        $jobInfoSource | Should -Match 'Resolve-PSULocalizationLanguage @languageParameters'
        $jobInfoSource | Should -Match '\$psuConfigDemoStrings = Get-PSUConfigLocalizedData'
        $jobInfoSource | Should -Match '\$psuConfigDemoStrings\.JobPageEyebrow'
        $jobInfoSource | Should -Match '\$psuConfigDemoStrings\.JobPageTitle'
        $jobInfoSource | Should -Match '\$psuConfigDemoStrings\.JobPageDescription'
        $jobInfoSource | Should -Match '\$psuConfigDemoStrings\.JobBackButton'
        $jobInfoSource | Should -Match "# 'Back to module-first demo'"
        $jobInfoSource | Should -Not -Match "Text\s*=\s*'Back to module-first demo'"
        $jobInfoSource | Should -Match 'New-UDPsuJobHeader @headerParameters'
        $jobInfoSource | Should -Match 'Language\s+= \$language'
        $jobInfoSource | Should -Match 'DefaultUILanguage\s+= \$defaultUILanguage'
    }

    It 'Should provide a persistent language selector in the app header' {
        $commandPath = (Get-Command -Name New-PSUConfigDemoConsole -Module $script:moduleName).ScriptBlock.File
        $commandSource = Get-Content -Path $commandPath -Raw

        $commandSource | Should -Match 'HeaderContent'
        $commandSource | Should -Match 'Get-PSUConfigModule'
        $commandSource | Should -Match 'Resolve-PSULocalizationLanguage @languageParameters'
        $commandSource | Should -Match 'New-UDLanguageSelector @languageSelectorParameters'
        $commandSource | Should -Match 'ModuleBase\s*=\s*\$moduleBase'
        $commandSource | Should -Match 'UseLanguageLabel\s*=\s*\$true'
        $commandSource | Should -Not -Match 'UseNativeLanguageName\s*=\s*\$true'
        $commandSource | Should -Match '\$psuConfigDemoStrings\.NavigationHome'
        $commandSource | Should -Match '\$psuConfigDemoStrings\.NavigationUsers'
        $commandSource | Should -Match "New-UDDynamic -Id 'psuconfig-navigation'"
        $commandSource | Should -Not -Match "Label\s*=\s*'Module-first demo'"
        $commandSource | Should -Not -Match "Label\s*=\s*'Users'"
    }

    It 'Should register startup localization cache initialization' {
        $moduleBase = (Get-Module -Name $script:moduleName).ModuleBase
        $universalPath = Join-Path -Path $moduleBase -ChildPath '.universal'
        $scriptsSource = Get-Content -Path (Join-Path -Path $universalPath -ChildPath 'scripts.ps1') -Raw
        $triggersSource = Get-Content -Path (Join-Path -Path $universalPath -ChildPath 'triggers.ps1') -Raw

        $scriptsSource | Should -Match "Command 'Initialize-PSUConfigLocalizationCache'"
        $triggersSource | Should -Match "EventType\s*=\s*'ServerStarted'"
        $triggersSource | Should -Match "TriggerScript\s*=\s*'PSUConfig\\Initialize-PSUConfigLocalizationCache'"
    }
}
