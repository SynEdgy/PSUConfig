$localizationTriggerParameters = @{
    Name          = 'Initialize PSUConfig localization cache'
    EventType     = 'ServerStarted'
    Environment   = 'PSUConfig'
    TriggerScript = 'PSUConfig\Initialize-PSUConfigLocalizationCache'
    Delay         = 10
}

New-PSUTrigger @localizationTriggerParameters

$databaseTriggerParameters = @{
    Name          = 'Initialize PSUConfig database'
    EventType     = 'ServerStarted'
    Environment   = 'PSUConfig'
    TriggerScript = 'PSUConfig\Initialize-PSUConfigDB'
    Delay         = 15
}

New-PSUTrigger @databaseTriggerParameters
