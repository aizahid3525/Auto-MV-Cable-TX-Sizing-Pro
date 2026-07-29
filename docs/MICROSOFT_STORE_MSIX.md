# Microsoft Store MSIX configuration

## Reserved Partner Center identity

| Manifest property | Controlled value |
|---|---|
| `Package/Identity/Name` | `AiZahid.AutoMVCableTXSizingPro` |
| `Package/Identity/Publisher` | `CN=A0E77901-C4C9-4DDA-9126-02F6FC3FDA15` |
| `Package/Identity/Version` | `1.1.0.0` |
| `Package/Properties/PublisherDisplayName` | `AiZahid` |
| Display name | `Auto MV Cable & TX Sizing Pro` |
| Architecture | `x64` |

The Android application ID remains separate: `com.aizahid.auto_mv_cable_tx_sizing_pro`.

## GitHub Actions outputs

The Windows workflow builds and uploads:

- `Auto_MV_Cable_TX_Sizing_Pro_Windows_Portable.zip`
- `Auto_MV_Cable_TX_Sizing_Pro_1.1.0.0_x64.msix`
- obfuscation symbols
- the controlled `Package.appxmanifest`

The workflow stages the Flutter Windows release, copies the Store assets, renames the controlled manifest to `AppxManifest.xml`, and runs the Windows SDK `MakeAppx.exe`.

## Optional signing secrets

For a signed CI artifact, configure both repository secrets:

- `WINDOWS_PFX_BASE64`
- `WINDOWS_PFX_PASSWORD`

The PFX subject/publisher must match the controlled Store publisher exactly. Never commit a `.pfx`, certificate password, or decoded certificate file. Without these secrets, CI still creates an unsigned MSIX for Partner Center processing/testing.

## Store submission safeguards

- Do not change the reserved identity name or publisher certificate subject.
- Use four-part MSIX versions and keep the fourth component at `0` for Store releases.
- Increment the Store package version for every submission, for example `1.1.1.0`.
- Run the Windows workflow and Microsoft Store certification tests before production submission.
- Verify the exact executable name remains `auto_mv_cable_tx_sizing_pro.exe`.
