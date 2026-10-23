function Get-PSUConfigDatabaseAnalysis
{
    <#
        .SYNOPSIS
            Reports the tables, record counts, and schema version for the PSUConfig database.

        .DESCRIPTION
            Queries the live SQLite schema for every non-system table, counts the records
            in each table, and reads the stored database schema version from the PSSqlite
            _metadata table. Each result row includes the database file and schema version.

        .PARAMETER SqliteDBConfig
            Supplies the resolved SQLite database configuration used for the analysis.

        .EXAMPLE
            Get-PSUConfigDatabaseAnalysis

            Returns table record counts and the stored schema version for the configured database.
    #>
    [CmdletBinding()]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param
    (
        [Parameter(DontShow)]
        [synedgy.PSSqlite.SqliteDBConfig]
        $SqliteDBConfig = (Get-PSUConfigDatabaseConfiguration)
    )

    Write-Verbose -Message 'Starting PSUConfig database analysis.' -Verbose

    if ($null -eq $SqliteDBConfig)
    {
        throw 'The PSUConfig SQLite database configuration could not be loaded.'
    }

    $databaseFilePath = Join-Path -Path $SqliteDBConfig.DatabasePath -ChildPath $SqliteDBConfig.DatabaseFile
    if (-not (Test-Path -LiteralPath $databaseFilePath -PathType Leaf))
    {
        throw "The configured PSUConfig database file was not found at '$databaseFilePath'."
    }

    $sqliteConnection = New-PSSqliteConnection -ConnectionString $SqliteDBConfig.ConnectionString -ErrorAction Stop
    try
    {
        $tableQueryParameters = @{
            SqliteConnection = $sqliteConnection
            CommandText      = @'
SELECT name AS TableName
FROM sqlite_schema
WHERE type = 'table'
  AND name NOT LIKE 'sqlite_%'
ORDER BY name;
'@
            As               = 'PSCustomObject'
            KeepAlive        = $true
            ErrorAction      = 'Stop'
        }
        $tables = @(Invoke-PSSqliteQuery @tableQueryParameters)

        $tableCounts = foreach ($table in $tables)
        {
            $tableName = [System.String]$table.TableName
            $quotedTableName = '"{0}"' -f $tableName.Replace('"', '""')
            $countQueryParameters = @{
                SqliteConnection = $sqliteConnection
                CommandText      = 'SELECT COUNT(*) AS RecordCount FROM {0};' -f $quotedTableName
                As               = 'PSCustomObject'
                KeepAlive        = $true
                ErrorAction      = 'Stop'
            }
            $countResult = @(Invoke-PSSqliteQuery @countQueryParameters)

            [pscustomobject]@{
                TableName   = $tableName
                RecordCount = [System.Int64]$countResult[0].RecordCount
            }
        }

        $metadata = Get-PSSqliteDBMetadata -SqliteConnection $sqliteConnection -MetadataKey 'version' -ErrorAction Stop
        $schemaVersion = [System.String]$metadata['version']
        if ([System.String]::IsNullOrWhiteSpace($schemaVersion))
        {
            throw "The configured PSUConfig database does not contain a schema version in '_metadata'."
        }

        $analysis = foreach ($tableCount in $tableCounts)
        {
            [pscustomobject]@{
                DatabaseFile  = $SqliteDBConfig.DatabaseFile
                SchemaVersion = $schemaVersion
                TableName     = $tableCount.TableName
                RecordCount   = $tableCount.RecordCount
            }
        }
    }
    finally
    {
        if ($null -ne $sqliteConnection)
        {
            $sqliteConnection.Close()
            $sqliteConnection.Dispose()
            Close-PSSqliteConnection
        }
    }

    $analysis
}
