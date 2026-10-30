function Read-PSUConfigMonitoringMachineData
{
    <#
        .SYNOPSIS
            Reads the PSUConfig monitoring machine inventory.

        .DESCRIPTION
            Loads the persistent monitoring JSON fixture and converts it into
            PowerShell objects used by detection, health, and patch workflows.

        .EXAMPLE
            Read-PSUConfigMonitoringMachineData

            Returns the monitoring inventory and its machine collection.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param ()

    Get-Content -Path (Get-PSUConfigMonitoringMachineDataPath) -Raw -ErrorAction Stop |
        ConvertFrom-Json -Depth 5
}
