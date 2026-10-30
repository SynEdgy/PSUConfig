function Get-PSUConfigMonitoringComputer
{
    <#
        .SYNOPSIS
            Gets vulnerable computers enriched with owner and health details.

        .DESCRIPTION
            Uses PSUConfig's monitoring inventory to discover computers affected
            by a software advisory, then retrieves and caches the owner and current
            health of every affected computer before returning a consolidated view.

        .PARAMETER SoftwareName
            Specifies the installed software to inspect.

        .PARAMETER AffectedBeforeVersion
            Specifies the first non-vulnerable software version.

        .EXAMPLE
            Get-PSUConfigMonitoringComputer -SoftwareName SecureConnect -AffectedBeforeVersion 5.4

            Returns vulnerable SecureConnect computers with owner and health
            information from the PSUConfig monitoring workflow.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject[]])]
    param
    (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $SoftwareName = 'SecureConnect',

        [Parameter()]
        [System.Version]
        $AffectedBeforeVersion = '5.4'
    )

    foreach ($machine in @((Read-PSUConfigMonitoringMachineData).machines))
    {
        $software = @($machine.installedSoftware |
            Where-Object name -eq $SoftwareName) |
            Select-Object -First 1
        if (-not $software -or [System.Version]$software.version -ge $AffectedBeforeVersion)
        {
            continue
        }

        $owner = if ($null -eq $machine.ownerId)
        {
            [pscustomobject]@{ Assigned = $false }
        }
        else
        {
            $user = Invoke-PSUConfigMonitoringDirectoryRequest -Path (
                'users/{0}?select=id,firstName,lastName,email,company' -f $machine.ownerId
            )
            $setUserProfileParameters = @{
                Id         = [System.Int32]$user.id
                FirstName  = [System.String]$user.firstName
                LastName   = [System.String]$user.lastName
                Email      = [System.String]$user.email
                Department = [System.String]$user.company.department
                Title      = [System.String]$user.company.title
                Confirm    = $false
            }
            $null = Set-PSUConfigUserProfile @setUserProfileParameters

            [pscustomobject]@{
                Assigned  = $true
                DisplayName = '{0} {1}' -f $user.firstName, $user.lastName
                Email       = [System.String]$user.email
                Department  = [System.String]$user.company.department
            }
        }

        [pscustomobject]@{
            Id                 = [System.String]$machine.id
            ComputerName       = [System.String]$machine.hostname
            Model              = [System.String]$machine.model
            OperatingSystem    = [System.String]$machine.operatingSystem.name
            SoftwareName       = $SoftwareName
            SoftwareVersion    = [System.String]$software.version
            IsVulnerable       = $true
            OwnerId            = $machine.ownerId
            OwnerAssigned      = [System.Boolean]$owner.Assigned
            OwnerDisplayName   = [System.String]$owner.DisplayName
            OwnerEmail         = [System.String]$owner.Email
            OwnerDepartment    = [System.String]$owner.Department
            Online             = [System.Boolean]$machine.health.online
            HealthStatus       = if ($machine.health.online) { 'Online' } else { 'Offline' }
            UptimeHours        = [System.Double]$machine.health.uptimeHours
            LastRebootTime     = [System.DateTime]$machine.health.lastRebootTime
        }
    }
}
