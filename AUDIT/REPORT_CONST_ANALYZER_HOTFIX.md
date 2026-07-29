# PDF report const-constructor analyzer hotfix

## Reported failure

Android and Windows `flutter analyze --no-fatal-infos` reported 12 `const_with_non_const` errors in `lib/services/report_service.dart`.

## Correction

- Removed `const` from every `pw.*` constructor invocation in the PDF report service.
- Retained ordinary Dart constants that remain valid, such as the static string header list.
- Added a validator regression check requiring `const pw.` to be absent from the report service.

## Local validation boundary

Python/static project validation is executed in this environment. Flutter SDK validation must run in GitHub Actions; no claim is made that `flutter analyze`, tests, or native builds were executed locally.
