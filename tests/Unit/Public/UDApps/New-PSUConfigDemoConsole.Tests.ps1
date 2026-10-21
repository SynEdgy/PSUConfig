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
        $appPath = PSUConfig\Get-UDAppPath
        $assetPath = Join-Path -Path $appPath -ChildPath 'assets'

        Test-Path -Path (Join-Path -Path $assetPath -ChildPath 'synedgy-logo.svg') | Should -BeTrue
        Test-Path -Path (Join-Path -Path $assetPath -ChildPath 'powershell-cube.jpg') | Should -BeTrue
    }

    It 'Should provide separate light and dark PSU theme definitions' {
        $appPath = PSUConfig\Get-UDAppPath
        $themePath = Join-Path -Path $appPath -ChildPath 'theme.psd1'
        $theme = Import-PowerShellDataFile -Path $themePath

        $theme.Keys | Should -Contain 'light'
        $theme.Keys | Should -Contain 'dark'
        $theme.light.palette.background.default | Should -Not -BeNullOrEmpty
        $theme.dark.palette.background.default | Should -Not -BeNullOrEmpty
    }
}
