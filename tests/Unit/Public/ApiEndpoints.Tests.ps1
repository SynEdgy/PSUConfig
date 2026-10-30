BeforeAll {
    $script:moduleName = 'PSUConfig'

    if (-not (Get-Module -Name $script:moduleName -ListAvailable))
    {
        & "$PSScriptRoot/../../../build.ps1" -Tasks 'noop' 2>&1 4>&1 5>&1 6>&1 > $null
    }

    Import-Module -Name $script:moduleName -Force -ErrorAction Stop

    $script:expectedEndpoints = @(
        @{
            Command = 'Find-UserByCity'
            Name    = 'findUserByCity'
            Path    = '/users/by-city'
            Method  = 'GET'
        }
        @{
            Command = 'Get-Something'
            Name    = 'GetSomething'
            Path    = '/something'
            Method  = 'GET'
        }
        @{
            Command = 'Get-PSUConfigUser'
            Name    = 'getPSUConfigUser'
            Path    = '/psuConfigUser'
            Method  = 'GET'
        }
        @{
            Command = 'New-PSUConfigUser'
            Name    = 'newPSUConfigUser'
            Path    = '/psuConfigUser'
            Method  = 'POST'
        }
        @{
            Command = 'Set-PSUConfigUser'
            Name    = 'setPSUConfigUser'
            Path    = '/psuConfigUser'
            Method  = 'PUT'
        }
        @{
            Command = 'Remove-PSUConfigUser'
            Name    = 'removePSUConfigUser'
            Path    = '/psuConfigUser'
            Method  = 'DELETE'
        }
    )
}

AfterAll {
    Remove-Module -Name $script:moduleName -Force -ErrorAction SilentlyContinue
}

Describe 'Requested PSUConfig API endpoints' {
    It 'declares the expected APIEndpoint metadata' {
        foreach ($expectedEndpoint in $script:expectedEndpoints)
        {
            $commandInfo = Get-Command -Name $expectedEndpoint.Command -Module $script:moduleName
            $attribute = $commandInfo.ScriptBlock.Attributes |
                Where-Object { $_.TypeId.Name -eq 'APIEndpoint' }

            $attribute.Name | Should -Be $expectedEndpoint.Name
            $attribute.Path | Should -Be $expectedEndpoint.Path
            $attribute.Method | Should -Be @($expectedEndpoint.Method)
        }
    }

    It 'generates parser-safe endpoint script blocks in the PSUConfig environment' {
        $endpoints = @(Get-ModuleApiEndpoint -Module PSUConfig -Environment PSUConfig -ApiPrefix api)

        foreach ($expectedEndpoint in $script:expectedEndpoints)
        {
            $endpoint = $endpoints |
                Where-Object {
                    $_.FunctionInfo.Name -eq $expectedEndpoint.Command -and
                    $_.Method -contains $expectedEndpoint.Method
                }

            $endpoint | Should -Not -BeNullOrEmpty
            $endpoint.Environment | Should -Be 'PSUConfig'

            $generatedScriptblock = Get-ModuleApiEndpointScriptblock -ModuleApiEndpoint $endpoint
            $tokens = $null
            $errors = $null
            $null = [System.Management.Automation.Language.Parser]::ParseInput(
                $generatedScriptblock.ToString(),
                [ref]$tokens,
                [ref]$errors
            )
            $errors | Should -BeNullOrEmpty
        }
    }

    It 'disables interactive confirmation on generated write endpoints' {
        $endpoints = @(Get-ModuleApiEndpoint -Module PSUConfig -Environment PSUConfig -ApiPrefix api)

        foreach ($commandName in 'New-PSUConfigUser', 'Set-PSUConfigUser', 'Remove-PSUConfigUser')
        {
            $endpoint = $endpoints |
                Where-Object FunctionInfo |
                Where-Object { $_.FunctionInfo.Name -eq $commandName }
            $scriptBlock = Get-ModuleApiEndpointScriptblock -ModuleApiEndpoint $endpoint

            $scriptBlock.ToString() | Should -Match '-Confirm:\$false'
        }
    }
}
