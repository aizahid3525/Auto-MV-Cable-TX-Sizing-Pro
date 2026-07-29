# Auto MV Cable & TX Sizing Pro — Rev3 Modern UI Audit

## Controlled release identity

- App: **Auto MV Cable & TX Sizing Pro**
- Package ID: `com.aizahid.auto_mv_cable_tx_sizing_pro`
- Flutter version declaration: `1.1.0+3`
- Engineering master: `Auto_MV_Cable_TX_Sizing_Pro_Engineering_Master_Rev2_AppV1_1_0.xlsx`
- Calculation engine: `MVTX-CALC-V1`
- Protection engine: `MVTX-PROTECTION-V1`
- UI revision: **Rev3 modern radial dashboard, sidebar and responsive two-column layout**

## Reference implementation basis

The UI structure was adapted from the latest controlled **Auto Cable Sizing Pro V114 Rev78** package and the supplied Android screenshots. Only interaction and presentation patterns were reused. MV cable, transformer, protection and standards content remains specific to this application.

Reference package SHA-256:

`f8218e8374a0833f8245a1bc536c847f6abc473f76a2afd74265a5010c0dce0a`

## Implemented UI scope

### Dashboard

- Replaced the previous fuchsia dashboard with the AiZahid navy/blue/cyan modern engineering theme.
- Added a compact branded hero card with four engineering capability indicators.
- Added a responsive engineering-workflow section.
- Added two-column database KPI cards.
- Added an interactive concentric radial chart:
  - outer ring: MV cable families;
  - inner ring: transformer families/types;
  - independently normalised ring percentages;
  - segment tap selection;
  - centre-circle cycling;
  - selected-family count and percentage summary;
  - expandable two-column family legend;
  - direct transfer to the matching database tab and family filter.
- Added two-column engineering-tip cards.

### Navigation

- Added a complete phone/tablet navigation drawer with all seven destinations.
- Added app branding, theme control, About and FAQ sections.
- Retained a four-destination primary bottom navigation bar for Dashboard, MV Cable, Transformer and Database.
- Retained a seven-destination navigation rail for wide layouts.
- Android back navigation returns secondary pages to Dashboard before exiting.

### Responsive two-column contract

- Replaced fixed-aspect-ratio form/result grids with a shared responsive paired-row layout.
- Normal phone and tablet widths use two columns.
- Cards within each pair are height matched.
- When the child count is odd, the last card spans the full two-column width.
- Extremely narrow accessibility layouts fall back to a single column rather than clipping text.
- Applied to cable, transformer, coordination, protection, database and dashboard card groups.

### Helper-icon convention

- Input controls use exactly one question-mark helper.
- Result and database-derived output cards use an information icon.
- Removed the previous duplicate question-mark + information-icon pair from input labels.
- Generic result information remains available when a result has no dedicated controlled helper topic.

### Database

- Added MV cable-family filtering.
- Added dashboard-to-database transfer for cable and transformer radial selections.
- Redesigned filter groups as responsive two-column cards.
- Added information controls to database record cards.

## Engineering integrity

This revision is UI-only. No calculation equations, selection algorithms, controlled JSON data, regression vectors, protection envelopes or engineering-master workbook content were changed.

Controlled engineering-master SHA-256 remains:

`71fddedf68608cdf51d0506681477ef8811a74df23ffe6e2fee425003f2546b6`

## Validation performed in this environment

- `python tool/validate_project.py`: **PASS — 1,997 checks**.
- Python source compilation: **PASS** for `validate_project.py` and `configure_platforms.py`.
- Delimiter balance, source contracts, controlled-data counts, workbook integrity, analytical regressions, navigation, radial-chart, helper-icon and two-column layout contracts: **PASS**.
- No Flutter SDK was available in the execution environment; therefore `dart format`, `flutter analyze`, `flutter test`, APK/AAB and Windows builds were not executed locally.
- The included GitHub Actions workflows perform platform generation, dependency resolution, formatting, analysis, tests and release builds.

## Release safeguard

Treat all recommendations as preliminary until exact manufacturer data, utility fault levels, protection curves, CT performance, transformer inrush, cable bonding/earthing, discrimination and applicable IEC/MS/ST/TNB/project requirements are verified by the responsible engineer.
