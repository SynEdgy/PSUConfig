function Get-PSUConfigMonitoringMachineDataPath
{
    <#
        .SYNOPSIS
            Resolves the writable monitoring inventory path.

        .DESCRIPTION
            Returns the configured monitoring inventory path and seeds it from
            the module's bundled JSON fixture when the writable copy is missing.

        .EXAMPLE
            Get-PSUConfigMonitoringMachineDataPath

            Returns the persistent machine inventory JSON path.
    #>
    [CmdletBinding()]
    [OutputType([System.String])]
    param ()

    $dataPath = $env:PSUCONFIG_MONITORING_MACHINE_DATA_PATH
    if ([System.String]::IsNullOrWhiteSpace($dataPath))
    {
        $dataPath = Join-Path -Path (Get-PSUConfigSetting).SqliteDBConfig.DatabasePath -ChildPath 'monitoring-machines.json'
    }

    if (-not (Test-Path -Path $dataPath))
    {
        $null = New-Item -Path (Split-Path -Path $dataPath -Parent) -ItemType Directory -Force
        $seedPath = Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath 'config\monitoring-machines.json'
        Copy-Item -Path $seedPath -Destination $dataPath -Force
    }

    (Resolve-Path -Path $dataPath).Path
}
