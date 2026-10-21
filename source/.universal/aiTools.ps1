# AI tools are now declared via the [AiTool()] attribute directly on the target
# functions (Find-UserByCity, New-myUser) and discovered/registered here in one call,
# mirroring the [APIEndpoint()] / Import-PSUEndpoint pattern used in endpoints.ps1.
# The previous hand-written New-PsuMcpTool calls referenced a cmdlet that does not
# exist in this PSU version (the real cmdlet is New-PSUAiTool).
Import-Module -Name synedgy.universal.helper, PSUConfig

Import-PSUAiTool -Module PSUConfig -Environment 'PSUConfig'
