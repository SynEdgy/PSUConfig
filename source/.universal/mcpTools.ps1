$newMcpToolParams = @{
    Name           = "New-MyUser"
    Description    = "Creates a new user in the PSUConfig database"
    ScriptFullPath = "PSUConfig\New-MyUser"
}

New-PsuMcpTool @newMcpToolParams
