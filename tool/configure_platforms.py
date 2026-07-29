#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP_NAME = 'Auto MV Cable & TX Sizing Pro'
PACKAGE_ID = 'com.aizahid.auto_mv_cable_tx_sizing_pro'


def replace(path: Path, old: str, new: str) -> None:
    if not path.exists():
        return
    text = path.read_text(encoding='utf-8')
    if old in text:
        path.write_text(text.replace(old, new), encoding='utf-8')


def configure_android() -> None:
    manifest = ROOT / 'android/app/src/main/AndroidManifest.xml'
    if manifest.exists():
        text = manifest.read_text(encoding='utf-8')
        import re
        text = re.sub(r'android:label="[^"]*"', f'android:label="{APP_NAME}"', text, count=1)
        manifest.write_text(text, encoding='utf-8')
    for gradle in [ROOT / 'android/app/build.gradle.kts', ROOT / 'android/app/build.gradle']:
        if gradle.exists():
            text = gradle.read_text(encoding='utf-8')
            import re
            text = re.sub(r'applicationId\s*=\s*"[^"]+"', f'applicationId = "{PACKAGE_ID}"', text)
            text = re.sub(r'namespace\s*=\s*"[^"]+"', f'namespace = "{PACKAGE_ID}"', text)
            gradle.write_text(text, encoding='utf-8')
    strings = ROOT / 'android/app/src/main/res/values/strings.xml'
    strings.parent.mkdir(parents=True, exist_ok=True)
    strings.write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<resources>\n'
        f'    <string name="app_name">{APP_NAME.replace("&", "&amp;")}</string>\n'
        '</resources>\n',
        encoding='utf-8',
    )


def configure_windows() -> None:
    main_cpp = ROOT / 'windows/runner/main.cpp'
    if main_cpp.exists():
        text = main_cpp.read_text(encoding='utf-8')
        import re
        text = re.sub(r'window\.Create\(L"[^"]+"', f'window.Create(L"{APP_NAME}"', text)
        text = re.sub(r'window\.CreateAndShow\(L"[^"]+"', f'window.CreateAndShow(L"{APP_NAME}"', text)
        main_cpp.write_text(text, encoding='utf-8')
    rc = ROOT / 'windows/runner/Runner.rc'
    if rc.exists():
        replace(rc, 'auto_mv_cable_tx_sizing_pro', APP_NAME)
        replace(rc, 'Auto_mv_cable_tx_sizing_pro', APP_NAME)


if __name__ == '__main__':
    configure_android()
    configure_windows()
    print('Platform identity configured.')
