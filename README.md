# Auto MV Cable & TX Sizing Pro

> Modern UI build: radial MV cable/transformer coverage, responsive two-column cards, corrected helper-icon semantics and a complete navigation drawer.

**Android and Windows Flutter engineering design aid** for MV cables,
transformers, coordinated feeder design, and preliminary transformer
protection/switchgear selection.

- App name: **Auto MV Cable & TX Sizing Pro**
- Package ID: `com.aizahid.auto_mv_cable_tx_sizing_pro`
- Version: `1.1.0+4`
- Calculation engine: `MVTX-CALC-V1`
- Protection engine: `MVTX-PROTECTION-V1`
- Brand: **AiZahid**
- Theme: **Professional fuchsia / purple**, with persistent responsive light and dark modes


## Rev4 user-interface and engineering-helper update

- Professional fuchsia/purple application theme across light and dark modes.
- Engineering Database filters and matched records now share one `CustomScrollView`, so every filter remains reachable on small phones while the bottom navigation stays fixed.
- Dashboard database statistics use an icon/arrow top row with the count and full-width label below, preventing narrow-card word fragmentation.
- Every input helper uses `?`; calculated and database-derived outputs use `i`.
- Helper dialogs include governing equations, current-value substitutions, live pass/verify traces where applicable, and responsive reference tables.
- Microsoft Store MSIX identity is controlled by `Package.appxmanifest`, with an x64 MSIX build added to the Windows GitHub Actions workflow.

### Microsoft Store identity

- Identity name: `AiZahid.AutoMVCableTXSizingPro`
- Publisher: `CN=A0E77901-C4C9-4DDA-9126-02F6FC3FDA15`
- Publisher display name: `AiZahid`
- Store package version: `1.1.0.0`

See `docs/MICROSOFT_STORE_MSIX.md` for CI packaging and optional signing secrets.

## Modern UI and navigation update

- Dashboard redesigned using the latest Auto Cable Sizing Pro interaction pattern.
- Interactive concentric radial chart: outer ring for MV cable families and inner ring for transformer families.
- Tappable segments, centre-cycle control, selected-family summary and filtered database transfer.
- Full navigation drawer for all seven workflows, theme control, About and FAQ.
- Four primary bottom destinations: Dashboard, MV Cable, Transformer and Database.
- Responsive two-column card system across input and result grids.
- Height-matched paired cards; an unpaired final card spans the complete two-column width.
- Input guidance uses the question-mark icon only. Calculated and database-derived outputs use the information icon.
- Core cable, transformer and protection calculation engines remain unchanged; helper guidance is upgraded to live equation traces and tabular references.

## Included engineering workflows

### MV cable design

- Three-phase design current
- Installation-method ampacity and derating
- Parallel-run selection
- R/X voltage drop
- Conductor short-circuit withstand
- Charging current and conductor loss
- Screen-bonding selection and verification warning

### Transformer design

- Demand, growth, harmonic and motor allowances
- Standard transformer rating selection
- Normal and outage loading
- MV/LV full-load current
- Preliminary terminal fault current
- Preliminary losses, efficiency and regulation

### Cable + transformer coordination

- Automatic transformer selection
- Coordinated MV feeder recommendation
- Integrated protection recommendation
- PDF engineering report

### Protection & switchgear

- Risk-based preliminary selection between MV switch-fuse and VCB + relay
- VCB voltage, current, breaking-current and short-time requirements
- MV fuse starting rating
- Protection CT ratio and class guidance
- Relay-function recommendation and preliminary pickup values
- LV ACB frame, sensor, breaking capacity and LSIG starting values
- Oil-immersed and dry-type transformer internal protection
- **Automatic preliminary** and **Professional manual** modes
- Fail-closed manual-selection checks

The package contains **315 protection and switchgear records**. Generic
entries are rating envelopes, not manufacturer product models.

## Controlled engineering assets

- 1,320 MV cable records
- 336 transformer records
- 315 protection and switchgear records
- Controlled helper, standards, source and regression registers
- `engineering_master/Auto_MV_Cable_TX_Sizing_Pro_Engineering_Master_Rev2_AppV1_1_0.xlsx`

Manufacturer product-family information is separated from calculated or
engineering-reference values. Replace or verify preliminary data against the
exact current catalogue, quotation, nameplate, type-test report and project
specification before final issue.

## GitHub validation and builds

The Android and Windows workflows:

1. Generate the required Flutter platform wrapper.
2. Configure application identity.
3. Resolve Flutter dependencies.
4. Run `python tool/validate_project.py`.
5. Verify Dart formatting.
6. Run `flutter analyze`.
7. Run `flutter test`.
8. Build the platform release artifacts.

The Python validator uses only the Python standard library. Pillow/PIL is not
required.

### Android outputs

- Release APK
- Release AAB
- Obfuscation symbols

Production Play publication still requires the protected upload-keystore
secrets and verification of the signed AAB.

### Windows outputs

- Portable Windows ZIP
- Microsoft Store x64 MSIX: `Auto_MV_Cable_TX_Sizing_Pro_1.1.0.0_x64.msix`
- Controlled `Package.appxmanifest` and Store tile assets
- Obfuscation symbols

## Local commands

```bash
flutter create --platforms=android,windows --org com.aizahid --project-name auto_mv_cable_tx_sizing_pro .
python tool/configure_platforms.py
flutter pub get
dart run flutter_launcher_icons
python tool/validate_project.py
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos
flutter test --reporter expanded
flutter build apk --release
flutter build appbundle --release
flutter build windows --release
```

## Protection safeguards

Automatic recommendations remain preliminary. The application:

- selects minimum rating envelopes, not guaranteed product compatibility;
- requires actual utility maximum and minimum fault levels for final duty;
- requires transformer impedance and tolerance from the nameplate or approved data;
- requires fuse, relay and trip-unit curves for final grading;
- requires CT burden, saturation, ALF or knee-point verification;
- requires ACB `Icu`, `Ics`, `Icw`, utilisation category and trip-unit range verification;
- requires busbar, cable, busduct and neutral rating coordination;
- requires manufacturer discrimination/cascading tables where applicable;
- requires final utility, TNB, Suruhanjaya Tenaga, project and competent-person approval.

The app does **not** claim final selectivity without actual device curves,
manufacturer data, CT performance and a complete protection-coordination
study.

## Validation status

The included Python audit verifies controlled data, source traceability,
engineering rating envelopes, safeguards, workbook integrity, icon
transparency, Dart source contracts and analytical regression vectors.

Native Flutter analyser, test and build results must be taken from the supplied
GitHub Actions workflows or another environment with the Flutter SDK.


## Rev2 cross-platform CI hotfix

- Controlled JSON SHA-256 verification canonicalises LF/CRLF line endings.
- `.gitattributes` enforces LF for JSON, Dart, Python, YAML and other text assets.
- Windows CI disables automatic CRLF conversion before checkout.
- Android and Windows CI run `dart format lib test` before the strict idempotence check.
- The formatter remains a gate: the second formatter command must report no further changes.

## Analyzer hotfix

- Resolves the three `AssessmentStatus.label` analyzer errors in PDF reporting.
- Removes all reported `DropdownButtonFormField.value` deprecations.
- Cleans the reported braces and const-constructor lints.
- Adds regression gates for these source contracts.

## Android manifest XML hotfix

- Android now references `@string/app_name` from `AndroidManifest.xml`.
- The ampersand in **Auto MV Cable & TX Sizing Pro** is written by Python's
  XML API to `strings.xml`, which serialises it safely as `&amp;`.
- `tool/configure_platforms.py` parses both generated XML files before the
  workflow proceeds, so malformed platform identity files fail immediately.
- `tool/validate_project.py` independently verifies the generated manifest
  label and exact application-name string when the Android wrapper exists.
