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

Describe 'Get-PSUConfigAppPath' {
    It 'Should be available as an exported command' {
        $command = Get-Command -Name Get-PSUConfigAppPath -Module $script:moduleName -ErrorAction Stop

        $command | Should -Not -BeNullOrEmpty
    }

    It 'Should default AppName to PSUConfigDemo and resolve an existing path' {
        $result = PSUConfig\Get-PSUConfigAppPath

        $result | Should -Not -BeNullOrEmpty
        Split-Path -Path $result -Leaf | Should -Be 'PSUConfigDemo'
    }

    It 'Should throw when the requested app folder does not exist' {
        { PSUConfig\Get-PSUConfigAppPath -AppName 'NonExistentApp' -ErrorAction Stop } | Should -Throw
    }
}
