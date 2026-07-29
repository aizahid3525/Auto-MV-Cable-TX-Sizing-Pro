# ListTile Material Hotfix — Patch Only

This patch is intended for the immediately previous package:

`Auto_MV_Cable_TX_Sizing_Pro_V1_1_0_REV2_WIDGET_TEST_TIMEOUT_HOTFIX_GITHUB_FULL_PACKAGE`

## Recommended application

From the repository root:

```bash
git apply --check Auto_MV_Cable_TX_Sizing_Pro_REV2_LISTTILE_MATERIAL_HOTFIX_FROM_WIDGET_TIMEOUT.patch
git apply Auto_MV_Cable_TX_Sizing_Pro_REV2_LISTTILE_MATERIAL_HOTFIX_FROM_WIDGET_TIMEOUT.patch
python tool/validate_project.py
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-fatal-infos
flutter test --reporter expanded
```

The patch changes:

- `lib/widgets/common_widgets.dart`
- `test/widget_test.dart`
- `tool/validate_project.py`
- `README.md`
- `AUDIT/LISTTILE_MATERIAL_HOTFIX.md`

The full-package ZIP is safer when repository baseline/version is uncertain.
