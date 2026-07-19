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
}
