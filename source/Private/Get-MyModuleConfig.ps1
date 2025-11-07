function Get-myModuleConfig
{
    [CmdletBinding()]
    param
    (
        [Parameter(DontShow)]
        [string]
        $ConfigFile,

        [Parameter()]
        [switch]
        $Force
    )

    if  ($null -eq $script:MyModuleDBConfig -or $Force)
    {
        if ([string]::IsNullOrEmpty($ConfigFile))
        {
            # Retrieve configuration from the current's module config subdirectory
            $ConfigFile = Get-PSSqliteDBConfigFile
        }
        else
        {
            Write-Verbose -Message ('Loading configuration from {0}' -f $ConfigFile)
        }

        $script:MyModuleDBConfig = Get-PSSqliteDBConfig -ConfigFile $ConfigFile

    }

    return $script:MyModuleDBConfig
}
