# PSU translation locale fallback

## Summary

PowerShell Universal 2026.3.3 does not apply the documented fallback from a
regional browser locale to its generic language translation.

With translations registered for `en` and `fr`:

- `Accept-Language: en` selects the English translation.
- `Accept-Language: fr` selects the French translation.
- `Accept-Language: en-US` selects English through the server fallback.
- `Accept-Language: fr-FR` selects English through the server fallback instead
  of selecting the registered `fr` translation.

This behavior was reproduced locally with the PSUConfig demo. It has not been
confirmed as an upstream defect by Devolutions.

## Documented behavior

The PSU translation documentation states that the server first looks for the
specific language ID presented by the browser. If that ID is not registered,
PSU should attempt the next-best language.

For example, a request for `fr-FR` should fall back to `fr` before using the
server-wide fallback language.

Reference:
[PowerShell Universal translations](https://docs.devolutions.net/powershell-universal/platform/translations.md)

## Reproduction

Register generic English and French translations containing the same key:

```powershell
New-PSUTranslation -LanguageId 'en' -Strings @{
    PSUConfigHeroTitle = 'PowerShell Universal, managed as code.'
}

New-PSUTranslation -LanguageId 'fr' -Strings @{
    PSUConfigHeroTitle = 'PowerShell Universal, géré comme du code.'
}
```

Use the key in a dashboard:

```powershell
New-UDTypography -Text $tl:PSUConfigHeroTitle -Variant h2
```

The following Playwright probe demonstrates the locale-dependent result:

```javascript
for (const locale of ['fr', 'fr-FR', 'en', 'en-US']) {
  const context = await browser.newContext({ locale });
  const page = await context.newPage();
  await page.goto('http://localhost:5000/psuconfig-demo/');
  console.log(`${locale}: ${await page.getByRole('heading', { level: 2 }).innerText()}`);
  await context.close();
}
```

Observed output:

```text
fr: PowerShell Universal, géré comme du code.
fr-FR: PowerShell Universal, managed as code.
en: PowerShell Universal, managed as code.
en-US: PowerShell Universal, managed as code.
```

The `fr` dictionary was verified to contain the requested key through PSU's
native translation API, so the result is not caused by a missing translation
string.

## No native dashboard language switch

PSU dashboards do not expose a documented language selector or dashboard-level
language override.

The `$tl:` provider selects its dictionary from the HTTP request's
`Accept-Language` header. Neither `New-UDApp` nor `New-UDPage` provides a
language, locale, culture, or translation parameter.

The PSU documentation does not define any of the following as dashboard
language overrides:

- A query-string parameter.
- A cookie.
- A `$Session:` or `$Page:` variable.
- An application setting.
- A client-side call that changes `$tl:` resolution.

`$LanguageID` is documented for selecting translations when running a script,
not for overriding the language of a dashboard session.

As a result, a dashboard control cannot switch the native `$tl:` provider
between English and French. JavaScript running in the page also cannot change
the `Accept-Language` header used to load the current dashboard.

## Impact

- Browsers commonly send regional language IDs such as `fr-FR`.
- A French user can therefore receive the server fallback language even though
  a generic `fr` translation is registered.
- Users must change their browser language preference to change the native
  dashboard translation.
- Applications that require an in-app language switch cannot rely exclusively
  on the native `$tl:` provider.

## PSUConfig application workaround

PSUConfig no longer relies on `$tl:` for the localized Home hero. It bundles
English and French data-only PSD1 dictionaries and resolves the application
language with this precedence:

1. The explicit `PSUConfigLanguage` browser cookie, when set to `en` or `fr`.
2. The request's `Accept-Language` preferences, including regional values such
   as `fr-FR` and `fr-CH`.
3. `DefaultUILanguage` from the active environment in `PSUConfig.config.yml`,
   or English when that setting is null.

The top-right app selector writes the cookie and reloads the page. The selected
dictionary is then resolved on the next request without attempting to override
PSU's native `$tl:` provider.

A `ServerStarted` trigger loads both dictionaries into the PSUConfig execution
environment's shared `$Cache:` scope. The app can also initialize the cache on
demand when a deployment occurs before the next server restart.

## Preferred native behavior

PSU should evaluate the complete `Accept-Language` preference list and apply
specific-to-generic fallback before selecting the server-wide fallback.

For example:

```text
fr-FR -> fr -> configured server fallback -> en
```

The documented fallback should behave consistently for dashboard requests,
API requests, and all regional language identifiers.
