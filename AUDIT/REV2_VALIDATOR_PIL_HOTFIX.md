# Rev2 Validator Pillow/PIL Hotfix

## Reported failure

`python tool/validate_project.py` failed in GitHub Actions with:

```text
ModuleNotFoundError: No module named 'PIL'
```

## Root cause

The validator imported Pillow only to inspect PNG alpha transparency, but the
Android and Windows workflows did not install Pillow.

## Correction

The validator now inspects 8-bit, non-interlaced RGBA PNG files using only the
Python standard library (`struct` and `zlib`). No third-party Python package is
required to run `tool/validate_project.py`.

## Validation

- Validator imports: standard library only
- Icon RGBA and fully transparent pixel checks: retained
- Android workflow: no additional Python installation required
- Windows workflow: no additional Python installation required
- Local `python tool/validate_project.py`: PASS
