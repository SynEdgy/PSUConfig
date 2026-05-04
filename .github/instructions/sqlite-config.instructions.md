---
description: 'SQLite schema configuration instructions'
applyTo: 'source/config/*.PSSqliteConfig.y*ml'
---

# SQLite Config Guidelines

`source/config/PSUConfig.PSSqliteConfig.yml` is parsed by `synedgy.PSSqlite` (`Get-PSSqliteDBConfig` → `[SQLiteDBConfig]`) and applied by `Initialize-PSSqliteDatabase`. The filename must match `<ModuleName>.PSSqliteConfig.y*ml` so `Get-PSSqliteDBConfigFile` can discover it via the `config/` subfolder of the module base.

## File-level keys

- `DatabasePath`: use `$repository` (expanded by `Get-ExpandedString`); never hard-code an absolute path. `:memory:` is allowed for transient/test DBs.
- `databaseFile`: filename only, e.g. `PSUConfig.db`. Combined with `DatabasePath` to build the connection string `Data Source=<DatabasePath>/<databaseFile>;`.
- `ConnectionString`: omit; it is derived. Set it directly only when overriding (`:memory:`, custom Sqlite options).
- `version`: string, default `'0'`. Persisted on init in the `_metadata` table (key `version`). Drives `Compare-PSSqliteDBVersion` and the `INCREMENTAL` migration path. Bump on every schema change you want migrated.
- `schema.Tables.<TableName>`: maps to `[SqliteTable]`. Each table has `columns`, optional `Constraints`, `Options`, `Schema`.

## Column properties

Each entry under `schema.Tables.<Table>.columns.<Name>` maps to `[SqliteColumn]`. Property names are case-insensitive (PowerShell-yaml). Supported keys:

- `type` (required): one of the `Microsoft.Data.Sqlite.SqliteType` values (`Integer`, `Text`, `Real`, `Blob`).
- `primaryKey` (bool): exactly one column per table.
- `primaryKeyOrder`: `ASC` / `DESC` (rare; omit unless needed).
- `autoIncrement` (bool): only valid on `Integer primaryKey`. `INTEGER PRIMARY KEY` is auto-`AUTOINCREMENT` already; setting this is usually redundant.
- `allowNull` (bool, default `true`): set `false` for `NOT NULL`.
- `unique` (bool) + optional `uniqueConflictClause` (`REPLACE`, `IGNORE`, `ABORT`, `FAIL`, `ROLLBACK`).
- `checkExpression` (string): raw SQL `CHECK` expression.
- `defaultValue`: literal or SQL expression (string values are auto-escaped).
- `collation`: `BINARY` / `NOCASE` / `RTRIM`. Note: CRUD helpers default to `COLLATE NOCASE` at query time regardless.
- `indexed` (bool): index the column.
- `references` (string): inline foreign-key target, e.g. `OtherTable(id)`. Prefer table-level `Constraints` for multi-column / named FKs.

## Table-level constraints

Add under `schema.Tables.<Table>.Constraints` as a list. Each item must include `Type`:

- `Type: PrimaryKey` → `[SqlitePrimaryKeyTableConstraint]` (composite PKs).
- `Type: ForeignKey` → `[SqliteForeignKeyTableConstraint]`.
- `Type: Check` → `[SqliteCheckTableConstraint]`.
- `Type: Index` → `[SqliteIndexConstraint]` (named/composite indexes).

`Options` accepts `[SQLiteTableOption]` values (`WithoutRowId`, `Strict`).

## Conventions in this repo

- Timestamp columns are `TEXT` ISO-8601, named `createdOn` / `updatedOn`.
- Natural-key string columns (`uid`, `email`, `username`) should set `unique: true` unless intentionally non-unique.
- Index any column referenced from a `Get-PSSqliteRow` `ClauseData` key in module functions.

## Migration & compatibility

- Adding a new table or new nullable column is additive; safe to keep the same `version` only if `INCREMENTAL` migration with `IF NOT EXISTS` semantics will pick it up. Otherwise bump `version`.
- Renaming/removing a column, changing `type`, or changing `primaryKey` is breaking: bump `version`, document in `CHANGELOG.md` `Unreleased`. Users running `Initialize-PSUConfigDB` will need `MigrationMode = 'OVERWRITE'` (data loss) or a manual migration.
- Validate locally after edits:
  ```powershell
  ./build.ps1 -Tasks build
  Import-Module ./output/PSUConfig/*/PSUConfig.psd1 -Force
  Initialize-PSUConfigDB -Force -Verbose
  ```
