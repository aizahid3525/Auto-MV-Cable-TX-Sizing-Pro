# Auto MV Cable & TX Sizing Pro — Rev2 Static Engineering Audit

## Controlled identity

- App name: **Auto MV Cable & TX Sizing Pro**
- Package ID: `com.aizahid.auto_mv_cable_tx_sizing_pro`
- Version: `1.1.0+2`
- Calculation schema: `MVTX-CALC-V1`
- Protection schema: `MVTX-PROTECTION-V1`
- Platforms: Android and Windows through Flutter/GitHub Actions
- Primary theme: Fuchsia `#C2185B`, including light and dark modes

## Rev2 scope verified

- 1,320 MV cable records
- 336 transformer records
- 315 protection and switchgear records
- Automatic preliminary MV switch-fuse versus VCB screening
- Required VCB voltage, continuous-current, breaking-current and short-time rating envelopes
- MV transformer-fuse current starting point with explicit curve-coordination warning
- CT ratio and class guidance
- Relay-function applicability and preliminary pickup starting points
- LV ACB frame, sensor, Icu/Icw requirements and LSIG starting points
- Oil-immersed and dry-type transformer internal-protection guidance
- Professional manual overrides with fail-closed under-rating checks
- Integration into Transformer Design and coordinated Cable + TX Design
- Protection results and limitations included in PDF reports
- Question-mark and information helpers with examples and reference lists
- Synchronized Rev2 engineering master workbook

## Safeguard policy

The automatic engine returns a required rating envelope and preliminary settings. It does not claim a final purchasable model, utility approval, protection grading, selectivity, discrimination, arc-flash result or approved setting schedule.

Final issue requires project-specific confirmation of at least:

- Maximum and minimum utility fault levels
- Transformer impedance tolerance and inrush data
- Cable, busduct and busbar ampacity and impedance
- Motor contribution and operating scenarios
- Exact VCB, switchgear, fuse, ACB, CT and relay models
- Fuse and breaker time-current curves
- VCB/switchgear type-test ratings, interlocks and control supply
- CT burden, ALF or knee point, lead resistance and saturation
- Relay pickup, curve, TMS/time dial, high-set and trip matrix
- ACB Icu, Ics, Icw, utilisation category and manufacturer discrimination tables
- TNB/utility, Suruhanjaya Tenaga, competent-person and project requirements

Statuses are deliberately conservative:

- `PASS`: entered numerical checks pass
- `VERIFY`: technically plausible, but final evidence is incomplete
- `FAIL`: an entered device or setting is inadequate
- `NOT ASSESSED`: an essential input is missing or invalid

## Static and analytical validation

`tool/validate_project.py` completed **1,921 checks** and passed. Coverage includes:

- Identity and version consistency
- JSON schema/record-count checks
- SHA-256 controlled-data integrity
- Protection-rating envelope coverage
- Fail-closed manual-selection safeguards
- UI, database and PDF integration contracts
- Workbook presence and formula/error checks
- Source and standards traceability
- Analytical regression vectors
- Android and Windows workflow contracts
- Dart local-import and delimiter consistency

## Native validation boundary

The packaging environment did not contain the Flutter or Dart SDK. Therefore, the following were **not** executed locally and are not claimed as passed:

- `dart format`
- `flutter analyze`
- `flutter test`
- Android APK/AAB compilation
- Windows release compilation

The included GitHub Actions run those native checks and produce Android and Windows artifacts. Production Android publication additionally requires the protected upload keystore and signing secrets.

## Widget-test timeout hotfix

The dashboard smoke test no longer uses `pumpAndSettle()`. Controlled assets are preloaded through `tester.runAsync`, followed by bounded deterministic frame pumps. This prevents continuously animated loading indicators from causing Android and Windows CI timeouts while retaining verification of asset loading and dashboard rendering.
