# Auto MV Cable & TX Sizing Pro

**Android and Windows Flutter engineering design aid** for medium-voltage cables, transformers, protection and coordinated feeder/transformer/switchgear selection.

- App name: **Auto MV Cable & TX Sizing Pro**
- Package ID: `com.aizahid.auto_mv_cable_tx_sizing_pro`
- Version: `1.1.0+2`
- Engineering schemas: `MVTX-CALC-V1` and `MVTX-PROTECTION-V1`
- Brand: **AiZahid**
- Theme: **Fuchsia**, with responsive light and dark modes

## Rev2 protection and switchgear scope

The new **Protection & Switchgear** workflow provides automatic preliminary selection of:

- MV switch-fuse versus VCB + numerical relay strategy
- VCB rated voltage, continuous current, breaking current and short-time duty
- MV transformer-fuse current starting point
- Protection CT primary ratio and class guidance
- Relay-function applicability: 50/51, 50N/51N, 49, 46, 87T, 64REF, 50BF and 74TCS
- LV ACB frame, sensor, pole arrangement, Icu/Icw requirement and LSIG starting values
- Oil-immersed and dry-type transformer internal-protection recommendations
- Family-level VCB, RMU and ACB candidates from controlled official sources

The output is a **required rating envelope**, not a final purchasable model or approved setting schedule. The engine fails closed when a manual device rating is below the calculated requirement.

## Included workflows

1. **MV Cable Design**
   - Three-phase current, ampacity, derating and parallel runs
   - Voltage drop using conductor resistance and reactance
   - Conductor adiabatic short-circuit withstand
   - Charging current and conductor loss
   - Screen-bonding selection and verification warnings

2. **Transformer Design**
   - Demand, growth, harmonics and motor allowance
   - Automatic rating selection and N-1 loading screening
   - MV/LV full-load current
   - Transformer-terminal fault estimate
   - Loss, efficiency and regulation
   - Integrated protection preview

3. **Cable + TX Coordination**
   - Automatic transformer and MV feeder selection
   - Integrated preliminary protection and switchgear result
   - VCB, ACB and CT summary
   - Expanded PDF engineering report

4. **Protection & Switchgear**
   - Automatic preliminary mode
   - Professional manual mode with fail-closed overrides
   - Configurable Malaysia/IEC and critical-facility screening profiles
   - VCB, fuse, ACB, CT and relay setting starting points
   - Manufacturer-family candidates and detailed safeguards

5. **Engineering Database**
   - 1,320 MV cable records
   - 336 transformer records
   - 315 protection and switchgear records
   - Cable, transformer and protection filters
   - Manufacturer-family records separated from engineering rating envelopes

6. **Helper System**
   - Question-mark and information buttons
   - Explanations, use in the app, worked examples and reference lists
   - Current project values where applicable
   - Dedicated protection topics for VCB, fuses, CTs, relays, ACBs and internal transformer protection

## Controlled engineering assets

- `assets/data/mv_cable_database.json`
- `assets/data/transformer_database.json`
- `assets/data/protection_database.json`
- `assets/data/help_content.json`
- `assets/data/standards_register.json`
- `assets/data/manufacturer_sources.json`
- `assets/data/regression_vectors.json`
- `assets/data/data_manifest.json`
- `engineering_master/Auto_MV_Cable_TX_Sizing_Pro_Engineering_Master_Rev2_AppV1_1_0.xlsx`

## Automatic-protection safeguards

The app does **not** claim final selectivity, discrimination or utility approval without:

- Maximum and minimum utility fault levels
- Transformer impedance tolerance and inrush data
- MV/LV cable and busbar impedances
- Motor contribution and arc-flash inputs
- Exact VCB, fuse, ACB, CT and relay models
- VCB/switchgear type-tested ratings and interlocks
- Fuse time-current curves and switch-fuse compatibility
- CT burden, ALF or knee point, lead resistance and saturation assessment
- Relay curves, pickup settings, TMS/time dial and trip matrix
- ACB Icu, Ics, Icw, trip-unit ranges and manufacturer discrimination tables
- TNB/utility, Suruhanjaya Tenaga, competent-person and project approval

Status meanings:

- **PASS** — entered numerical checks pass
- **VERIFY** — technically plausible but exact equipment/study confirmation is still required
- **FAIL** — selected equipment or setting is inadequate
- **NOT ASSESSED** — essential input is missing or invalid

## GitHub use

Upload the **contents** of this folder to the root of a GitHub repository.

### Android workflow

The `Validate and Build Android` workflow:

1. Creates the Android Flutter wrapper.
2. Applies the package and application identity.
3. Resolves dependencies and generates launcher icons.
4. Runs the controlled-data validator.
5. Runs formatting, analyzer and Flutter tests.
6. Builds obfuscated release APK and AAB artifacts.

Production Play publication still requires the protected upload keystore and signing secrets.

### Windows workflow

The `Validate and Build Windows` workflow:

1. Creates the Windows Flutter wrapper.
2. Applies the app identity.
3. Runs the same validation, formatting, analyzer and tests.
4. Builds an obfuscated Windows release.
5. Packages the portable Windows folder into a ZIP artifact.

## Local validation commands

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

## Validation boundary

The package includes an independent Python static/data/regression validator. Flutter native validation must still be confirmed by the included GitHub Actions because the packaging environment did not contain the Flutter or Dart SDK.
