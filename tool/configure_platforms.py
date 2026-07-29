#!/usr/bin/env python3
from pathlib import Path
import re
from xml.etree import ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
APP_NAME = 'Auto MV Cable & TX Sizing Pro'
PACKAGE_ID = 'com.aizahid.auto_mv_cable_tx_sizing_pro'
ANDROID_APP_LABEL = '@string/app_name'


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
        text, replacements = re.subn(
            r'android:label="[^"]*"',
            f'android:label="{ANDROID_APP_LABEL}"',
            text,
            count=1,
        )
        if replacements != 1:
            raise RuntimeError(
                'Android application label was not found exactly once in '
                f'{manifest}'
            )
        # Fail immediately if identity configuration would create malformed XML.
        ET.fromstring(text)
        manifest.write_text(text, encoding='utf-8')
        ET.parse(manifest)

    for gradle in [
        ROOT / 'android/app/build.gradle.kts',
        ROOT / 'android/app/build.gradle',
    ]:
        if gradle.exists():
            text = gradle.read_text(encoding='utf-8')
            text = re.sub(
                r'applicationId\s*=\s*"[^"]+"',
                f'applicationId = "{PACKAGE_ID}"',
                text,
            )
            text = re.sub(
                r'namespace\s*=\s*"[^"]+"',
                f'namespace = "{PACKAGE_ID}"',
                text,
            )
            gradle.write_text(text, encoding='utf-8')

    strings = ROOT / 'android/app/src/main/res/values/strings.xml'
    strings.parent.mkdir(parents=True, exist_ok=True)
    resources = ET.Element('resources')
    app_name = ET.SubElement(resources, 'string', {'name': 'app_name'})
    app_name.text = APP_NAME
    tree = ET.ElementTree(resources)
    ET.indent(tree, space='    ')
    tree.write(strings, encoding='utf-8', xml_declaration=True)
    ET.parse(strings)


def configure_windows() -> None:
    main_cpp = ROOT / 'windows/runner/main.cpp'
    if main_cpp.exists():
        text = main_cpp.read_text(encoding='utf-8')
        text = re.sub(
            r'window\.Create\(L"[^"]+"',
            f'window.Create(L"{APP_NAME}"',
            text,
        )
        text = re.sub(
            r'window\.CreateAndShow\(L"[^"]+"',
            f'window.CreateAndShow(L"{APP_NAME}"',
            text,
        )
        main_cpp.write_text(text, encoding='utf-8')
    rc = ROOT / 'windows/runner/Runner.rc'
    if rc.exists():
        replace(rc, 'auto_mv_cable_tx_sizing_pro', APP_NAME)
        replace(rc, 'Auto_mv_cable_tx_sizing_pro', APP_NAME)


if __name__ == '__main__':
    configure_android()
    configure_windows()
    print('Platform identity configured and XML validated.')
