$ModuleFile = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'PSUConfig.psd1'

# New-PSUEnvironment -Name "CustomEnvironment" -Path "pwsh" -Arguments "-NoLogo" -Modules @('PowerShell-Yaml') -Description "A Custom Environment with Module Loaded" -DisableImplicitWinCompat
New-PSUEnvironment -Name "Integrated" -Path "Universal.Server" -Variables @('*') -Description "An environment for running scripts directly in the PowerShell Universal server."
New-PSUEnvironment -Name "PowerShell 7" -Variables @('*') -Description "The PowerShell 7 version included with PowerShell Universal." -Type "PowerShell7"
New-PSUEnvironment -Name "Windows PowerShell 5.1" -Variables @('*') -Description "Windows PowerShell 5.1" -Type "WindowsPowerShell"

New-PSUEnvironment -Name "PSUConfig" -Variables @('*') -Description "Environment for SynEdgy Central" `
    -Type "PowerShell7" -Path "pwsh" -Arguments "-NoLogo" -Modules @('synedgy.PSSqlite','synedgy.universal.helper',$ModuleFile) `
-DisableImplicitWinCompat #-PSModulePath (Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Modules')
