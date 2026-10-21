---
description: 'PowerShell formatting conventions for PSUConfig'
applyTo: '**/*.ps1'
---

# PowerShell Style

- Place `{` and `}` on their own lines (Allman/OTBS-off style) for `if`, `else`, `elseif`, `try`, `catch`, `finally`, `foreach`, `while`, `function`, `param`, scriptblocks, and `task`.
- Add a blank line after every closing `}` that ends a block, hashtable, or scriptblock and sits on its own line.
- Do not add a blank line when `}` is immediately followed by another `}`, by a continuation keyword on the next line (`else`, `elseif`, `catch`, `finally`), or by a closing token on the same logical statement (`)`, `,`, `;`, `|`).
- Do not apply the blank-line rule to inline single-line scriptblocks (e.g. `Where-Object { $_.name -eq $x }`) or single-line hashtable literals.
- Inside `param()`, separate each `[Parameter()]`/typed parameter declaration with one blank line.
- Indent with 4 spaces; never use tabs.
- Prefer the `-f` string format operator over inline string interpolation when a string contains one or more `$variable` or `$(expression)` substitutions. Example: use `'User {0} has {1} items' -f $name, $count` instead of `"User $name has $count items"`. Single-variable strings with no surrounding text (e.g. `"$value"` used solely to coerce to string) and double-quoted strings whose only dynamic part is an escape sequence (e.g. `"`t"`, `"`n"`) are exempt.
- Pass `Content-Type` to `Invoke-RestMethod` and `Invoke-WebRequest` via the `-ContentType` parameter, not via the `-Headers` hashtable. Reserve `-Headers` for headers without a dedicated parameter (e.g. `Authorization`, `Accept`).
- Use splatting (a `@params` hashtable) instead of a long inline argument list when a command call has 4 or more parameters or would exceed ~120 characters on one line. Name the splat hashtable after the call site (e.g. `$publishParams`, `$deployParams`) and place it immediately above the invocation.
