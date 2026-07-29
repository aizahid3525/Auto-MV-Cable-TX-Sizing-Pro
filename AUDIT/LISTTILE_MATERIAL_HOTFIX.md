# ListTile Material Ancestry Hotfix

## Reported failure

Flutter widget testing raised three framework assertions because the three `SwitchListTile.adaptive` controls on the Protection page were descendants of a coloured `DecoratedBox` created by `SectionCard`, without a nearer `Material` ancestor.

## Correction

- `SectionCard` now uses `Material` with a `RoundedRectangleBorder`, border side and `Clip.antiAlias`.
- The visible surface, border and 20 px radius are preserved.
- `ListTile`, `SwitchListTile` and other ink-based descendants now paint backgrounds and splashes on the correct Material.
- The dashboard widget test explicitly checks `tester.takeException()` is null.
- `tool/validate_project.py` rejects regression to a coloured Container-based `SectionCard`.

## Local validation boundary

Flutter SDK was unavailable in the packaging environment. Static validation, clean extraction, ZIP integrity and cross-platform line-ending simulation were performed. Native `flutter test` must be confirmed by GitHub Actions.
