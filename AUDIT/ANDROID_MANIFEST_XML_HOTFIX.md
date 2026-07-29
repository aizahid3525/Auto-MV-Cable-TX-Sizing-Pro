# Android Manifest XML Hotfix

## Failure corrected

`tool/configure_platforms.py` previously inserted the literal application name
`Auto MV Cable & TX Sizing Pro` into the `android:label` attribute. The raw
ampersand is not valid XML and caused `:app:processReleaseMainManifest` to fail.

## Controlled correction

- `AndroidManifest.xml` now uses `android:label="@string/app_name"`.
- `strings.xml` is generated using `xml.etree.ElementTree`, which safely
  serialises the ampersand as `&amp;`.
- Both generated XML files are parsed immediately after writing.
- The independent project validator checks the generated manifest and string
  resource whenever the Android platform wrapper is present.

## Scope

No engineering formula, database, protection rule, UI workflow or application
version was changed by this hotfix.
