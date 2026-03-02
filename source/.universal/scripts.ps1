# New-PSUScript -Name "Get-SomeScript.ps1" -Description "Get-SomeScript.ps1" -Path "scripts\Get-SomeScript.ps1" -Environment "Integrated"
New-PSUScript -Environment "PSUConfig" -Module 'PSUConfig' -Command 'Set-myUser'
New-PSUScript -Environment "PSUConfig" -Module 'PSUConfig' -Command 'Initialize-PSUConfigDB'
New-PSUScript -Environment "PSUConfig" -Module 'PSUConfig' -Command 'New-myUser'
New-PSUScript -Environment "PSUConfig" -Module 'PSUConfig' -Command 'Get-myUser'

New-PSUScript -Environment "PSUConfig" -Path 'scripts\Get-Process.ps1' -Description 'Get-Process.ps1' -Name 'Get-Process.ps1'
