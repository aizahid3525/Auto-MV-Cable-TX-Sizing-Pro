# Rev2 Cross-Platform CI Hotfix

## Failures corrected

1. Windows checkout converted controlled JSON line endings from LF to CRLF, causing raw-byte SHA-256 mismatches.
2. The strict Dart formatting check failed before analysis because repository source required formatter changes.

## Corrections

- Added `.gitattributes` with explicit LF contracts.
- Disabled Windows Git `core.autocrlf` before checkout.
- Updated the validator to hash canonical UTF-8 text line endings.
- CI now applies `dart format lib test`, then runs the strict idempotence check.
- No engineering formulas, databases, selection rules or protection safeguards were altered.
