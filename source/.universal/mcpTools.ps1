$newMcpToolParams = @{
    Name           = "Find-UserByCity"
    Description    = "Finds users by city in the PSUConfig database"
    ScriptFullPath = "PSUConfig\Find-UserByCity"
}

New-PsuMcpTool @newMcpToolParams

$newMcpToolParams = @{
    Name           = "New-MyUser"
    Description    = "Creates a new user in the PSUConfig database"
    ScriptFullPath = "PSUConfig\New-MyUser"
}

New-PsuMcpTool @newMcpToolParams
