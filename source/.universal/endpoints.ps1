
Import-Module -Name synedgy.universal.helper,PSUConfig


# $ModuleFile = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'PSUConfig.psd1'
# Import-Module synedgy.universal.helper
# Import-Module -Name $ModuleFile
#TODO: fix Authentication parameter when auth is implemented
Import-PSUEndpoint -Module PSUConfig -Environment "PSUConfig" -ApiPrefix 'api' -Authentication:$false
