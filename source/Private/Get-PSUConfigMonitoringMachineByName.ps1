function Get-PSUConfigMonitoringMachineByName
{
    <#
        .SYNOPSIS
            Resolves one computer from the bundled monitoring inventory.

        .DESCRIPTION
            Searches PSUConfig's monitoring machine data by hostname or inventory
            identifier and throws an explicit error when no computer matches.

        .PARAMETER ComputerName
            Specifies the hostname or inventory identifier to resolve.

        .EXAMPLE
            Get-PSUConfigMonitoringMachineByName -ComputerName CH-GVA-LT1001

            Returns the matching monitoring inventory object.
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $ComputerName
    )

    $machine = @(Read-PSUConfigMonitoringMachineData).machines |
        Where-Object { $_.hostname -eq $ComputerName -or $_.id -eq $ComputerName } |
        Select-Object -First 1

    if (-not $machine)
    {
        throw "Computer '$ComputerName' was not found in the monitoring inventory."
    }

    $machine
}
