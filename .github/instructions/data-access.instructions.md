---
description: 'synedgy.PSSqlite data access conventions'
applyTo: 'source/{Public,Private}/**/*.ps1'
---

# Data Access Guidelines (synedgy.PSSqlite)

Use the `synedgy.PSSqlite` CRUD helpers; do not hand-write SQL or open `Microsoft.Data.Sqlite.SqliteConnection` directly except inside helpers that genuinely need raw access.

## Cmdlet selection

- Read: `Get-PSSqliteRow`.
- Insert: `New-PSSqliteRow` (returns the inserted row via `RETURNING *`).
- Update: `Set-PSSqliteRow`.
- Delete: `Remove-PSSqliteRow`.
- Raw SQL (only when CRUD is insufficient): `Invoke-PSSqliteQuery -SqliteConnection $conn -CommandText '...' -Parameters @{ ... }`. Always parameterise; never interpolate user input into `CommandText`.

## Parameter conventions

- Pass the cached `[synedgy.PSSqlite.SqliteDBConfig]` from `Get-myModuleConfig` to the `-SqliteDBConfig` parameter. Do not reload the YAML inside functions.
- Pass `-TableName` as a literal string matching `schema.Tables.<Name>` in the YAML.
- `-RowData` and `-ClauseData` accept `[System.Collections.IDictionary]`. Keys must match column names declared in the schema; unknown keys emit `Write-Warning` and are silently dropped.
- `$null` values in `-RowData` are dropped (use `Invoke-PSSqliteQuery` with `DBNULL` if a NULL write is required).

## ClauseData query semantics

- Exact match on column `Foo`: `@{ Foo = 'bar' }` → `Foo = @Foo`.
- Wildcard: any value containing `*` is rewritten to SQL `LIKE` with `%` (e.g. `@{ Name = 'John*' }` → `Name LIKE 'John%'`).
- Range suffixes: keys ending in `Before` / `After` map to `<` / `>` against the stripped column name. Example: `@{ createdBefore = $cutoff }` → `created < @createdBefore`.
- Default collation is `COLLATE NOCASE`. Pass `-CaseSensitive` when binary equality matters.
- Index any column you query in `ClauseData` (`indexed: true` in the schema YAML).

## Connection lifetime

- Default: each CRUD call opens and closes its own connection (and clears the pool).
- For batches in the same function, create one connection with `New-PSSqliteConnection -ConnectionString $SqliteDBConfig.ConnectionString`, pass it via `-SqliteConnection` to every call with `-KeepAlive`, and close it with `Close-PSSqliteConnection` in `end { }`.
- `:memory:` databases require `-KeepAlive` for the entire lifetime of the data; closing drops the DB.

## Output shape

- `Get-PSSqliteRow` returns `[PSCustomObject]` by default. Do not change the `-As` parameter from public functions (it is `DontShow`); rely on the default.
- `New-PSSqliteRow` returns the inserted row(s); capture it when the caller needs the generated `id`.

## Initialization

- Module-level DB init goes through `Initialize-PSUConfigDB` (which wraps `Initialize-PSSqliteDatabase`). Do not call `Initialize-PSSqliteDatabase` directly from public functions.
- `MigrationMode` defaults to `INCREMENTAL`. Pass `-Force` only from administrative entry points; it implies `OVERWRITE` and drops all data.
