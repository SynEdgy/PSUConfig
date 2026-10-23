$localizationTriggerParameters = @{
    Name          = 'Initialize PSUConfig localization cache'
    EventType     = 'ServerStarted'
    Environment   = 'PSUConfig'
    TriggerScript = 'PSUConfig\Initialize-PSUConfigLocalizationCache'
    Delay         = 10
}

New-PSUTrigger @localizationTriggerParameters
