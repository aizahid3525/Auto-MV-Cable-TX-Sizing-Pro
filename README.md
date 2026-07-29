# Auto MV Cable & TX Sizing Pro

> Rev2 hotfix: ListTile Material ancestry corrected for deterministic Android and Windows widget tests.

**Android and Windows Flutter engineering design aid** for MV cables,
transformers, coordinated feeder design, and preliminary transformer
protection/switchgear selection.

- App name: **Auto MV Cable & TX Sizing Pro**
- Package ID: `com.aizahid.auto_mv_cable_tx_sizing_pro`
- Version: `1.1.0+2`
- Calculation engine: `MVTX-CALC-V1`
- Protection engine: `MVTX-PROTECTION-V1`
- Brand: **AiZahid**
- Theme: **Fuchsia**, with responsive light and dark modes

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

