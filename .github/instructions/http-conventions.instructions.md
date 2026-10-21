---
description: 'HTTP call conventions for PowerShell in PSUConfig'
applyTo: '**/*.ps1'
---

# HTTP Conventions

- Always set `-ContentType` to a value that includes `; charset=utf-8` when calling `Invoke-WebRequest` or `Invoke-RestMethod`.
- Apply the same suffix when setting a `Content-Type` header in a hashtable passed to `-Headers`.
- Examples: `application/json; charset=utf-8`, `application/octet-stream; charset=utf-8`, `application/xml; charset=utf-8`.
- Set `Accept` headers explicitly when consuming JSON: `Accept = 'application/json'`.
- Pass bearer tokens via `Authorization = "Bearer $Token"` headers, not query strings.
- Build URLs with `[uri]::EscapeDataString(...)` for any path or query segment that may contain user-controlled values.
