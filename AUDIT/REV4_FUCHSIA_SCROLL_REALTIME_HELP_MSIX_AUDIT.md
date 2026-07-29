# Rev4 Fuchsia UI, Database Scrolling, Live Helper and MSIX Audit

## Release identity

- Flutter version: `1.1.0+4`
- Android application ID: `com.aizahid.auto_mv_cable_tx_sizing_pro`
- Microsoft Store identity: `AiZahid.AutoMVCableTXSizingPro`
- Microsoft Store publisher: `CN=A0E77901-C4C9-4DDA-9126-02F6FC3FDA15`
- Publisher display name: `AiZahid`
- MSIX version / architecture: `1.1.0.0` / `x64`
- Engineering engines retained: `MVTX-CALC-V1`, `MVTX-PROTECTION-V1`
- Helper schema: `MVTX-HELP-V2`

## Implemented requests

### Database scrolling defect

- Replaced the fixed filter/result composition inside each database tab with one `CustomScrollView`.
- Filter cards use `SliverToBoxAdapter`; matching records use a lazy `SliverList`.
- Added `PageStorageKey` state retention and drag-to-dismiss keyboard behaviour.
- Added a widget regression test that opens the database tab and drags the complete filter/result surface.

### Fuchsia application identity

- Replaced the legacy blue identity with a controlled fuchsia/purple palette.
- Applied the palette to light and dark schemes, focused inputs, selected navigation, tabs, progress indicators, banners, radial-chart accents and Store assets.
- Semantic pass/caution/fail colours remain distinct where engineering status requires them.

### Dashboard database metric cards

- Icon is positioned at the upper-left and navigation arrow at the upper-right.
- Record count is placed below in a full-width, single-line `FittedBox` and formatted with a thousands separator.
- Category label uses the full card width below the count.
- Paired cards retain equal height; an unpaired final card spans the full two-column width.

### Helper popup audit

- Input controls use the question-mark helper; result and database-output cards use the information helper.
- All 45 helper records contain a title, explanation, app usage, equation, worked example, warning, source/basis and parseable two-column reference table.
- `EngineeringHelpScope` supplies current screen state to every helper below it.
- Popup dialogs show the governing equation, live current-value substitution, current metrics, result status where available, responsive horizontally scrollable tables, warning and source/basis.
- Result `i` dialogs infer the correct engineering helper topic from the displayed output label.
- Helper dialogs are vertically scrollable and bounded for phone/tablet layouts.

### Microsoft Store package

- Added controlled `Package.appxmanifest` with exact Partner Center identity values.
- Added Store logo, tile and splash assets.
- Windows GitHub Actions now stages the Flutter release, creates an x64 MSIX with `MakeAppx.exe`, optionally signs it when PFX secrets are configured, verifies identity fields and uploads the MSIX plus the portable ZIP.

## Engineering-governance safeguards

- Cable calculation engine: unchanged from Rev3.
- Transformer calculation engine: unchanged from Rev3.
- Protection calculation engine and protection models: unchanged from Rev3.
- MV cable, transformer, protection, standards, source and regression JSON assets: unchanged from Rev3.
- Only helper content and its controlled manifest hash were revised for the requested live equations and table presentation.
- Master workbook was synchronised with all 45 helper records, formula/equation column, reference tables, Rev4 identity and controlled asset manifest.

## Static validation completed

- Fail-closed Python validator: **PASS — 2,596 checks**.
- Python source compilation: **PASS**.
- JSON parsing, record counts and controlled SHA-256 manifest: **PASS**.
- Dart delimiter and local-import static checks: **PASS**.
- Helper-ID, live-resolver and reference-table coverage: **PASS**.
- Database scrolling and widget-test source contracts: **PASS**.
- Fuchsia theme and dashboard metric-layout contracts: **PASS**.
- Microsoft Store manifest XML, identity, asset presence and workflow contracts: **PASS**.
- Engineering master XLSX ZIP integrity and Rev4 content: **PASS**.
- Analytical engineering regression vectors: **PASS**.
- Rev3-to-Rev4 engineering-core comparison: **UNCHANGED** for every controlled calculation/database file listed in `ENGINEERING_CORE_COMPARISON_REV3_TO_REV4.txt`.

## Native Flutter validation status

The Flutter and Dart SDKs were not installed in the packaging environment. Therefore, no local `flutter analyze`, `flutter test`, APK, AAB, Windows executable or MSIX build result is claimed. The Android and Windows GitHub Actions workflows remain the authoritative native validation/build path and are configured to run formatting, analysis, tests and release builds.
