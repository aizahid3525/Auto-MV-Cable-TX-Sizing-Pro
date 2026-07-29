#!/usr/bin/env python3
"""Independent fail-closed validation for the controlled Rev4 fuchsia UI,
real-time helper, database scrolling and Microsoft Store MSIX package."""

from __future__ import annotations

import hashlib
import json
import math
import re
import struct
import sys
import zipfile
import zlib
from pathlib import Path
from xml.etree import ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "assets" / "data"
errors: list[str] = []
checks = 0


def check(condition: bool, message: str) -> None:
    global checks
    checks += 1
    if not condition:
        errors.append(message)


def load(name: str) -> dict:
    path = DATA / name
    check(path.exists(), f"Missing controlled asset {name}")
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:  # pragma: no cover - fail-closed validation
        errors.append(f"Invalid JSON {name}: {exc}")
        return {}


def next_standard(values: list[float], required: float) -> float:
    for value in sorted(set(values)):
        if value + 1e-9 >= required:
            return value
    return math.nan


def canonical_text_sha256(path: Path) -> str:
    """Hash UTF-8 controlled text with platform-neutral line endings.

    Git may materialise text as LF or CRLF depending on checkout settings.
    The engineering content is identical, so the manifest comparison
    canonicalises CRLF and legacy CR to LF before calculating SHA-256.
    """
    raw = path.read_bytes()
    try:
        raw.decode("utf-8")
    except UnicodeDecodeError:
        return hashlib.sha256(raw).hexdigest()
    canonical = raw.replace(b"\r\n", b"\n").replace(b"\r", b"\n")
    return hashlib.sha256(canonical).hexdigest()


def png_rgba_alpha_min(path: Path) -> tuple[bool, int]:
    """Return whether a PNG is 8-bit RGBA and its minimum alpha value.

    This intentionally uses only the Python standard library so GitHub Actions
    and local validation do not depend on Pillow/PIL being preinstalled.
    """
    signature = b"\x89PNG\r\n\x1a\n"
    raw = path.read_bytes()
    if not raw.startswith(signature):
        return False, 255

    offset = len(signature)
    width = height = bit_depth = color_type = interlace = None
    idat = bytearray()
    while offset + 12 <= len(raw):
        length = struct.unpack(">I", raw[offset : offset + 4])[0]
        chunk_type = raw[offset + 4 : offset + 8]
        data_start = offset + 8
        data_end = data_start + length
        if data_end + 4 > len(raw):
            return False, 255
        chunk_data = raw[data_start:data_end]
        if chunk_type == b"IHDR":
            if length != 13:
                return False, 255
            width, height, bit_depth, color_type, _, _, interlace = struct.unpack(
                ">IIBBBBB", chunk_data
            )
        elif chunk_type == b"IDAT":
            idat.extend(chunk_data)
        elif chunk_type == b"IEND":
            break
        offset = data_end + 4

    if not width or not height or bit_depth != 8 or color_type != 6 or interlace != 0:
        return False, 255

    try:
        scanlines = zlib.decompress(bytes(idat))
    except zlib.error:
        return False, 255

    bytes_per_pixel = 4
    stride = width * bytes_per_pixel
    expected = height * (stride + 1)
    if len(scanlines) != expected:
        return False, 255

    previous = bytearray(stride)
    alpha_min = 255
    cursor = 0

    def paeth(a: int, b: int, c: int) -> int:
        estimate = a + b - c
        pa = abs(estimate - a)
        pb = abs(estimate - b)
        pc = abs(estimate - c)
        if pa <= pb and pa <= pc:
            return a
        if pb <= pc:
            return b
        return c

    for _ in range(height):
        filter_type = scanlines[cursor]
        cursor += 1
        encoded = scanlines[cursor : cursor + stride]
        cursor += stride
        decoded = bytearray(stride)
        for index, value in enumerate(encoded):
            left = decoded[index - bytes_per_pixel] if index >= bytes_per_pixel else 0
            up = previous[index]
            up_left = previous[index - bytes_per_pixel] if index >= bytes_per_pixel else 0
            if filter_type == 0:
                reconstructed = value
            elif filter_type == 1:
                reconstructed = (value + left) & 0xFF
            elif filter_type == 2:
                reconstructed = (value + up) & 0xFF
            elif filter_type == 3:
                reconstructed = (value + ((left + up) // 2)) & 0xFF
            elif filter_type == 4:
                reconstructed = (value + paeth(left, up, up_left)) & 0xFF
            else:
                return False, 255
            decoded[index] = reconstructed
        for alpha_index in range(3, stride, bytes_per_pixel):
            alpha_min = min(alpha_min, decoded[alpha_index])
            if alpha_min == 0:
                break
        previous = decoded

    return True, alpha_min


def balanced_dart(path: Path) -> bool:
    """Check delimiters while ignoring strings and comments."""
    text = path.read_text(encoding="utf-8")
    stack: list[str] = []
    pairs = {")": "(", "]": "[", "}": "{"}
    i = 0
    quote: str | None = None
    triple = False
    while i < len(text):
        ch = text[i]
        nxt = text[i + 1] if i + 1 < len(text) else ""
        if quote:
            if ch == "\\":
                i += 2
                continue
            if triple and text[i : i + 3] == quote * 3:
                quote = None
                triple = False
                i += 3
                continue
            if not triple and ch == quote:
                quote = None
            i += 1
            continue
        if ch in ("'", '"'):
            triple = text[i : i + 3] == ch * 3
            quote = ch
            i += 3 if triple else 1
            continue
        if ch == "/" and nxt == "/":
            end = text.find("\n", i + 2)
            i = len(text) if end < 0 else end + 1
            continue
        if ch == "/" and nxt == "*":
            end = text.find("*/", i + 2)
            if end < 0:
                return False
            i = end + 2
            continue
        if ch in "([{":
            stack.append(ch)
        elif ch in ")]}":
            if not stack or stack.pop() != pairs[ch]:
                return False
        i += 1
    return not stack and quote is None


# Identity and declared assets.
pubspec_path = ROOT / "pubspec.yaml"
pubspec = pubspec_path.read_text(encoding="utf-8")
check("name: auto_mv_cable_tx_sizing_pro" in pubspec, "Incorrect Flutter project name")
check("version: 1.1.0+4" in pubspec, "Incorrect Rev4 build version")
for asset in [
    "mv_cable_database.json",
    "transformer_database.json",
    "protection_database.json",
    "help_content.json",
    "standards_register.json",
    "manufacturer_sources.json",
    "regression_vectors.json",
    "data_manifest.json",
]:
    check(f"assets/data/{asset}" in pubspec, f"Asset not declared in pubspec: {asset}")

cables = load("mv_cable_database.json")
transformers = load("transformer_database.json")
protection = load("protection_database.json")
help_data = load("help_content.json")
standards = load("standards_register.json")
sources = load("manufacturer_sources.json")
regression = load("regression_vectors.json")
manifest = load("data_manifest.json")

# Counts and schema contracts.
check(cables.get("recordCount") == len(cables.get("records", [])) == 1320,
      "Cable record count mismatch")
check(transformers.get("recordCount") == len(transformers.get("records", [])) == 336,
      "Transformer record count mismatch")
check(protection.get("recordCount") == len(protection.get("records", [])) == 315,
      "Protection record count mismatch")
check(help_data.get("schema") == "MVTX-HELP-V2", "Incorrect helper schema")
check(help_data.get("recordCount") == len(help_data.get("records", [])) >= 45,
      "Insufficient or inconsistent Rev4 helper coverage")
for helper in help_data.get("records", []):
    helper_id = helper.get("ID", "<unknown>")
    for field in [
        "ID", "Title", "Explanation", "How app uses it",
        "Formula / equation", "Worked example", "Warning",
        "Source / basis", "Reference table",
    ]:
        check(bool(str(helper.get(field, "")).strip()),
              f"Helper {helper_id} has empty field: {field}")
    table = str(helper.get("Reference table", ""))
    rows = [row.strip() for row in table.split(" | ") if row.strip()]
    check(len(rows) >= 2 and all(" / " in row for row in rows),
          f"Helper {helper_id} reference table is not a parseable two-column table")
check(standards.get("recordCount") == len(standards.get("records", [])) >= 17,
      "Insufficient or inconsistent standards register")
check(sources.get("recordCount") == len(sources.get("records", [])) >= 29,
      "Insufficient or inconsistent source register")
check(regression.get("recordCount") == len(regression.get("records", [])) >= 8,
      "Insufficient or inconsistent regression vectors")
check(len(protection.get("profiles", [])) >= 2, "Protection profiles missing")
check(len(protection.get("relayFunctions", [])) >= 10, "Relay-function register incomplete")
check(len(protection.get("internalProtection", [])) >= 7, "Internal protection register incomplete")

# Database coverage.
cable_brands = {r.get("Brand") for r in cables.get("records", [])}
for brand in ["TCI", "Leader Cable", "Southern Cable", "Tai Sin", "Federal Power"]:
    check(brand in cable_brands, f"Missing cable brand {brand}")

tx_brands = {r.get("Brand") for r in transformers.get("records", [])}
for brand in ["MTM", "EWT", "Schneider Electric", "WEG"]:
    check(brand in tx_brands, f"Missing transformer brand {brand}")

protection_categories = {r.get("Device category") for r in protection.get("records", [])}
for category in [
    "VCB requirement", "ACB requirement", "MV fuse requirement",
    "VCB family", "ACB family", "RMU family",
]:
    check(category in protection_categories, f"Missing protection category {category}")

protection_brands = {r.get("Brand") for r in protection.get("records", [])}
for brand in ["Schneider Electric", "ABB", "Siemens", "Eaton"]:
    check(brand in protection_brands, f"Missing protection product family {brand}")

for record in cables.get("records", [])[:80]:
    check(str(record.get("Source URL", "")).startswith("https://"),
          f"Invalid cable source URL {record.get('ID')}")
    check(float(record.get("Ampacity air A", 0)) > 0,
          f"Invalid cable ampacity {record.get('ID')}")
    check(float(record.get("R90 Ω/km", 0)) > 0,
          f"Invalid cable resistance {record.get('ID')}")

for record in transformers.get("records", [])[:80]:
    check(str(record.get("Source URL", "")).startswith("https://"),
          f"Invalid transformer source URL {record.get('ID')}")
    check(float(record.get("Impedance %", 0)) > 0,
          f"Invalid transformer impedance {record.get('ID')}")
    check(float(record.get("Load loss kW ref.", 0)) >=
          float(record.get("No-load loss kW ref.", 0)),
          f"Transformer loss relationship requires review {record.get('ID')}")

for record in protection.get("records", []):
    check(str(record.get("Source URL", "")).startswith("https://"),
          f"Invalid protection source URL {record.get('ID')}")
    category = record.get("Device category", "")
    if category.endswith("requirement"):
        check(float(record.get("Rated voltage kV", 0)) > 0,
              f"Invalid protection voltage rating {record.get('ID')}")
        check(float(record.get("Rated current A", 0)) > 0,
              f"Invalid protection current rating {record.get('ID')}")
        check("NOT A PRODUCT MODEL" in str(record.get("Data status", "")) or
              category == "MV fuse requirement",
              f"Generic rating not adequately labelled {record.get('ID')}")

# Required help and standards.
help_ids = {r.get("ID") for r in help_data.get("records", [])}
for topic in [
    "protection_profile", "mv_device_strategy", "mv_fault_duty",
    "vcb_selection", "mv_fuse_selection", "ct_selection",
    "relay_functions", "acb_selection", "acb_lsig",
    "internal_tx_protection", "protection_status",
    "database_search", "protection_category", "cable_loading",
    "cable_loss", "transformer_losses", "transformer_efficiency",
    "transformer_regulation",
]:
    check(topic in help_ids, f"Missing protection helper {topic}")

standard_ids = {r.get("ID") for r in standards.get("records", [])}
for standard in [
    "IEC-62271-100", "IEC-60282-1", "IEC-60947-2",
    "IEC-61869-2", "IEC-60255",
]:
    check(standard in standard_ids, f"Missing protection standard {standard}")

# Controlled data manifest integrity.
manifest_rows = {r.get("File"): r for r in manifest.get("records", [])}
for path in sorted(DATA.glob("*.json")):
    if path.name == "data_manifest.json":
        continue
    row = manifest_rows.get(path.name)
    check(row is not None, f"Manifest missing {path.name}")
    if row:
        actual = canonical_text_sha256(path)
        check(row.get("SHA-256") == actual, f"SHA-256 mismatch for {path.name}")

# Icon transparency (standard-library PNG inspection; no Pillow dependency).
for icon_name in ["app_icon_512.png", "app_icon_1024.png", "adaptive_foreground.png"]:
    icon_path = ROOT / "assets" / "icons" / icon_name
    check(icon_path.exists(), f"Missing icon {icon_name}")
    if icon_path.exists():
        is_rgba, alpha_min = png_rgba_alpha_min(icon_path)
        check(is_rgba, f"Icon is not a supported 8-bit non-interlaced RGBA PNG: {icon_name}")
        check(alpha_min == 0, f"Icon lacks fully transparent outer pixels: {icon_name}")

# Source and UI contracts.
required_dart = [
    "lib/main.dart", "lib/calculations.dart", "lib/data_repository.dart",
    "lib/protection_models.dart", "lib/protection_calculations.dart",
    "lib/screens/cable_design_screen.dart",
    "lib/screens/transformer_design_screen.dart",
    "lib/screens/coordinated_design_screen.dart",
    "lib/screens/protection_design_screen.dart",
    "lib/screens/database_screen.dart", "lib/widgets/common_widgets.dart",
    "lib/services/report_service.dart",
]
for filename in required_dart:
    path = ROOT / filename
    check(path.exists(), f"Missing {filename}")
    if path.exists():
        check(balanced_dart(path), f"Unbalanced Dart delimiters in {filename}")

for dart_path in sorted([*ROOT.glob("lib/**/*.dart"), *ROOT.glob("test/**/*.dart")]):
    check(balanced_dart(dart_path),
          f"Unbalanced Dart delimiters in {dart_path.relative_to(ROOT)}")

main_text = (ROOT / "lib/main.dart").read_text(encoding="utf-8")
check("ProtectionDesignScreen" in main_text, "Protection page not routed")
check("NavigationDestinationLabelBehavior.alwaysShow" in main_text,
      "Four-destination labelled mobile navigation contract missing")
for term in [
    "_AppNavigationDrawer",
    "_bottomPageIndices = <int>[0, 1, 2, 5]",
    "DashboardDatabaseFilter",
    "DatabaseFilterTransfer",
    "Open navigation menu",
]:
    check(term in main_text, f"Modern navigation contract missing {term}")

dashboard_text = (ROOT / "lib/screens/dashboard_screen.dart").read_text(encoding="utf-8")
for term in [
    "Interactive radial chart", "MV cable family", "Transformer family",
    "_CoveragePainter", "_coverageIndexFromPosition",
    "View ${selected.value} records", "Engineering Database & Reference",
    "class _MetricCard", "Icons.arrow_forward_rounded", "FittedBox(",
    "_formatCount(value)", "EngineeringHelpScope",
]:
    check(term in dashboard_text, f"Rev4 dashboard contract missing {term}")
metric_block = dashboard_text.split("class _MetricCard", 1)[1]
check(metric_block.find("Icons.arrow_forward_rounded") < metric_block.find("FittedBox("),
      "Metric arrow must be above the count/text block")
check("maxLines: 3" in metric_block and "TextOverflow.ellipsis" in metric_block,
      "Metric label wrapping safeguard missing")

common_widgets_text = (ROOT / "lib/widgets/common_widgets.dart").read_text(encoding="utf-8")
for term in [
    "class EngineeringHelpScope", "class HelperButton",
    "Formula / equation", "Live calculation using current values",
    "Reference values / options", "SingleChildScrollView(",
    "_topicIdForResultLabel", "class LabeledField", "class ResultTile",
    "class ResponsiveGrid", "if (!hasPair)",
    "SizedBox(width: double.infinity, child: children[index])",
]:
    check(term in common_widgets_text, f"Rev4 responsive/help contract missing {term}")
labeled_field_block = common_widgets_text.split("class LabeledField", 1)[1].split("class ResultTile", 1)[0]
check("information: true" not in labeled_field_block,
      "Input LabeledField must use the question-mark helper")
helper_button_block = common_widgets_text.split("class HelperButton", 1)[1].split("Future<void> showHelperDialog", 1)[0]
check("Icons.help_outline_rounded" in helper_button_block,
      "Input question-mark helper icon is missing")
result_tile_block = common_widgets_text.split("class ResultTile", 1)[1].split("class ResponsiveGrid", 1)[0]
check("Icons.info_outline_rounded" in result_tile_block,
      "ResultTile information icon is missing")
check("information: true" in result_tile_block,
      "ResultTile must request result-information semantics")

all_screen_text = "\n".join(
    path.read_text(encoding="utf-8")
    for path in sorted(ROOT.glob("lib/screens/*.dart"))
)
used_topic_ids = set(re.findall(r"topicId:\s*'([^']+)'", all_screen_text))
helper_ids = {r.get("ID") for r in help_data.get("records", [])}
resolver_ids = set(re.findall(r"case '([^']+)'", common_widgets_text))
for topic_id in sorted(used_topic_ids):
    check(topic_id in helper_ids, f"Used helper topic is absent from JSON: {topic_id}")
    check(topic_id in resolver_ids, f"Used helper topic lacks live-value resolver: {topic_id}")

database_text = (ROOT / "lib/screens/database_screen.dart").read_text(encoding="utf-8")
for term in [
    "class DatabaseFilterTransfer", "_cableFamily = transfer.label",
    "_txType = transfer.label", "ResponsiveGrid(", "Record information",
    "CustomScrollView(", "PageStorageKey<String>(scrollKey)",
    "ScrollViewKeyboardDismissBehavior.onDrag", "SliverToBoxAdapter(",
    "SliverList(", "topicId: 'database_search'",
    "topicId: 'protection_category'",
]:
    check(term in database_text, f"Rev4 database scroll/helper contract missing {term}")
database_tab_block = database_text.split("Widget _databaseTab", 1)[1].split("Widget _filterField", 1)[0]
check("return Column(" not in database_tab_block,
      "Database tab still uses a height-trapping fixed Column")

repo_text = (ROOT / "lib/data_repository.dart").read_text(encoding="utf-8")
for term in ["protection_database.json", "ProtectionProfileRecord", "ctRatios",
             "standardAcbFrames", "standardVcbBreakingRatings"]:
    check(term in repo_text, f"Protection repository contract missing {term}")

calc_text = (ROOT / "lib/protection_calculations.dart").read_text(encoding="utf-8")
for term in [
    "preferredMvDevice", "vcbRatedVoltageKv", "fuseCurrentA", "acbFrameA",
    "ctRatio", "relayFunctions", "instantaneousPickupA",
    "Selected/manual VCB rating is below", "ACB long-time pickup exceeds",
]:
    check(term in calc_text, f"Protection calculation/safeguard missing {term}")

screen_text = (ROOT / "lib/screens/protection_design_screen.dart").read_text(encoding="utf-8")
for term in [
    "Automatic preliminary", "Professional manual", "VCB requirement",
    "ACB frame / sensor", "Protection CT", "Recommended relay functions",
    "Safeguards and required verification", "HelperButton",
]:
    check(term in screen_text, f"Protection UI contract missing {term}")

report_text = (ROOT / "lib/services/report_service.dart").read_text(encoding="utf-8")
for term in ["Protection and switchgear selection", "Recommended relay functions",
             "Icu, Ics, Icw", "CT ratio, class, burden"]:
    check(term in report_text, f"Protection PDF contract missing {term}")

# Analyzer hotfix contracts from the supplied Android/Windows CI output.
check("import '../models.dart';" in report_text,
      "AssessmentStatus label extension is not imported by report_service.dart")
for status_expression in [
    "transformer.status.label", "cable.status.label", "protection.status.label",
]:
    check(status_expression in report_text,
          f"PDF status label contract missing {status_expression}")

all_dart_text = "\n".join(
    path.read_text(encoding="utf-8")
    for path in sorted(ROOT.glob("lib/**/*.dart"))
)
check(
    re.search(
        r"DropdownButtonFormField<[^>]+>\(\s*\n\s*value:",
        all_dart_text,
    ) is None,
    "Deprecated DropdownButtonFormField.value argument remains",
)
check("initialValue:" in all_dart_text,
      "DropdownButtonFormField initialValue migration missing")

single_line_if = re.compile(r"^\s*if\s*\([^\n]+\)\s+(?!\{)[^/\n].*;\s*$", re.MULTILINE)
check(single_line_if.search(all_dart_text) is None,
      "Single-statement if without braces remains")

for term in [
    "const Padding(\n          padding: EdgeInsets.fromLTRB(18, 18, 18, 0)",
    "trailing: const HelperButton(\n        topicId: 'protection_status'",
]:
    check(term in all_dart_text, f"Reported const-constructor cleanup missing: {term}")

check("const pw." not in report_text,
      "Invalid const pdf/widget constructor remains in report_service.dart")

# Material ancestry safeguard for ListTile-based controls. SectionCard may host
# SwitchListTile/ListTile children, so its coloured surface must itself be a
# Material rather than an intermediate decorated Container.
common_widgets_text = (ROOT / "lib/widgets/common_widgets.dart").read_text(
    encoding="utf-8"
)
section_card_match = re.search(
    r"class SectionCard.*?class HelperButton",
    common_widgets_text,
    re.DOTALL,
)
check(section_card_match is not None, "SectionCard implementation missing")
if section_card_match is not None:
    section_card_text = section_card_match.group(0)
    check("return Material(" in section_card_text,
          "SectionCard must provide a Material ancestor")
    check("shape: RoundedRectangleBorder(" in section_card_text,
          "SectionCard Material shape/border contract missing")
    check("clipBehavior: Clip.antiAlias" in section_card_text,
          "SectionCard Material clipping contract missing")
    check("return Container(" not in section_card_text,
          "SectionCard must not use a coloured DecoratedBox around ListTiles")

# Resolve local Dart imports.
for dart in ROOT.glob("lib/**/*.dart"):
    text = dart.read_text(encoding="utf-8")
    for relative in re.findall(r"import\s+'(\.{1,2}/[^']+)'", text):
        target = (dart.parent / relative).resolve()
        check(target.exists(), f"Broken import {relative} in {dart.relative_to(ROOT)}")

# Fuchsia theme identity.
theme_text = (ROOT / "lib/app_theme.dart").read_text(encoding="utf-8")
for term in [
    "0xFF581C87", "0xFFC026D3", "0xFFF0ABFC",
    "static const Color fuchsia", "ColorScheme.fromSeed",
    "navigationBarTheme", "tabBarTheme", "focusedBorder",
]:
    check(term in theme_text, f"Fuchsia theme contract missing {term}")
check("0xFF0F2A6A" not in theme_text, "Legacy blue theme remains active")

# Microsoft Store package identity and MSIX workflow.
manifest_path = ROOT / "Package.appxmanifest"
check(manifest_path.exists(), "Microsoft Store Package.appxmanifest missing")
if manifest_path.exists():
    try:
        package_root = ET.parse(manifest_path).getroot()
        appx_ns = "http://schemas.microsoft.com/appx/manifest/foundation/windows10"
        identity = package_root.find(f"{{{appx_ns}}}Identity")
        properties = package_root.find(f"{{{appx_ns}}}Properties")
        check(identity is not None, "Store Identity element missing")
        if identity is not None:
            check(identity.attrib.get("Name") == "AiZahid.AutoMVCableTXSizingPro",
                  "Incorrect Microsoft Store identity name")
            check(identity.attrib.get("Publisher") ==
                  "CN=A0E77901-C4C9-4DDA-9126-02F6FC3FDA15",
                  "Incorrect Microsoft Store publisher")
            check(identity.attrib.get("Version") == "1.1.0.0",
                  "Incorrect Microsoft Store package version")
            check(identity.attrib.get("ProcessorArchitecture") == "x64",
                  "Incorrect Store processor architecture")
        check(properties is not None, "Store Properties element missing")
        if properties is not None:
            publisher_display = properties.find(f"{{{appx_ns}}}PublisherDisplayName")
            display_name = properties.find(f"{{{appx_ns}}}DisplayName")
            check(publisher_display is not None and publisher_display.text == "AiZahid",
                  "Incorrect Store publisher display name")
            check(display_name is not None and
                  display_name.text == "Auto MV Cable & TX Sizing Pro",
                  "Incorrect Store display name")
    except ET.ParseError as exc:
        check(False, f"Invalid Package.appxmanifest XML: {exc}")

store_assets = ROOT / "windows" / "packaging" / "Assets"
for asset_name in [
    "StoreLogo.png", "Square44x44Logo.png", "Square150x150Logo.png",
    "Square310x310Logo.png", "Wide310x150Logo.png", "SplashScreen.png",
]:
    asset_path = store_assets / asset_name
    check(asset_path.exists(), f"Missing Microsoft Store asset {asset_name}")
    if asset_path.exists():
        check(asset_path.read_bytes().startswith(b"\x89PNG\r\n\x1a\n"),
              f"Store asset is not a valid PNG signature: {asset_name}")

windows_workflow = (ROOT / ".github/workflows/windows.yml").read_text(encoding="utf-8")
for term in [
    "Create Microsoft Store MSIX", "makeappx.exe",
    "Auto_MV_Cable_TX_Sizing_Pro_1.1.0.0_x64.msix",
    "WINDOWS_PFX_BASE64", "WINDOWS_PFX_PASSWORD",
    "AiZahid.AutoMVCableTXSizingPro",
    "CN=A0E77901-C4C9-4DDA-9126-02F6FC3FDA15",
]:
    check(term in windows_workflow, f"Windows MSIX workflow contract missing {term}")

# Analytical regression checks.
primary = 1000 / (math.sqrt(3) * 11)
secondary = 1000 / (math.sqrt(3) * 0.415)
lv_fault = secondary / 0.06 / 1000
check(abs(primary - 52.4863881081) < 1e-6, "MV current regression failed")
check(abs(secondary - 1391.2054679268) < 1e-6, "LV current regression failed")
check(abs(lv_fault - 23.1867577988) < 1e-6, "Transformer fault regression failed")
check(next_standard(protection["standardVcbVoltageKv"], 12) == 12,
      "VCB voltage selection regression failed")
check(next_standard(protection["standardVcbCurrentA"], max(primary * 1.25, 630)) == 630,
      "VCB current selection regression failed")
check(next_standard(protection["standardVcbBreakingKa"], 20) == 20,
      "VCB breaking selection regression failed")
check(next_standard(protection["standardFuseCurrentA"], primary * 1.5) == 80,
      "MV fuse selection regression failed")
check(next_standard(protection["standardAcbFramesA"], secondary * 1.05) == 1600,
      "ACB frame selection regression failed")
check(next_standard(protection["standardAcbBreakingKa"], lv_fault * 1.1) == 42,
      "ACB breaking selection regression failed")
check(next_standard(protection["ctRatiosA"], primary / 0.8) == 75,
      "CT ratio selection regression failed")

# Workbook integrity and Rev2 sheets.
master = ROOT / "engineering_master" / \
    "Auto_MV_Cable_TX_Sizing_Pro_Engineering_Master_Rev2_AppV1_1_0.xlsx"
check(master.exists(), "Rev2 engineering master workbook missing")
if master.exists():
    check(zipfile.is_zipfile(master), "Engineering master is not a valid XLSX ZIP")
    if zipfile.is_zipfile(master):
        with zipfile.ZipFile(master) as archive:
            check(archive.testzip() is None, "Engineering master ZIP integrity failure")
            workbook_xml = ET.fromstring(archive.read("xl/workbook.xml"))
            ns = {"m": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
            sheet_names = {
                node.attrib["name"]
                for node in workbook_xml.findall("m:sheets/m:sheet", ns)
            }
            for sheet in [
                "Protection_DB", "Protection_Profiles", "Relay_Functions",
                "Internal_Protection", "Protection_Calc", "Protection_Help",
                "Protection_Standards", "Protection_Sources",
                "Protection_Regression", "Data_Manifest_Rev2",
            ]:
                check(sheet in sheet_names, f"Workbook missing sheet {sheet}")
            xml_text = "\n".join(
                archive.read(name).decode("utf-8", errors="ignore")
                for name in archive.namelist()
                if name.startswith("xl/") and name.endswith(".xml")
            )
            for term in [
                "Formula / equation", "MVTX-HELP-V2", "database_search",
                "transformer_efficiency", "1.1.0+4",
            ]:
                check(term in xml_text, f"Workbook Rev4 helper/version content missing {term}")

# Generated Android identity and XML-safety contract.
platform_config_path = ROOT / "tool" / "configure_platforms.py"
check(platform_config_path.exists(), "Platform configuration script missing")
if platform_config_path.exists():
    platform_config = platform_config_path.read_text(encoding="utf-8")
    check(
        "ANDROID_APP_LABEL = '@string/app_name'" in platform_config,
        "Android manifest must reference the app-name string resource",
    )
    check(
        'android:label="{APP_NAME}"' not in platform_config,
        "Raw app name must not be interpolated into AndroidManifest.xml",
    )
    check(
        "ET.SubElement(resources, 'string', {'name': 'app_name'})"
        in platform_config,
        "Android app-name resource must be generated by an XML API",
    )
    check(
        "ET.fromstring(text)" in platform_config
        and "ET.parse(manifest)" in platform_config
        and "ET.parse(strings)" in platform_config,
        "Generated Android XML preflight validation is missing",
    )

android_manifest_path = ROOT / "android/app/src/main/AndroidManifest.xml"
android_strings_path = ROOT / "android/app/src/main/res/values/strings.xml"
if android_manifest_path.exists():
    try:
        android_manifest_root = ET.parse(android_manifest_path).getroot()
        application = android_manifest_root.find("application")
        android_label_key = "{http://schemas.android.com/apk/res/android}label"
        check(application is not None, "Android manifest application element missing")
        if application is not None:
            check(
                application.attrib.get(android_label_key) == "@string/app_name",
                "Android manifest application label must use @string/app_name",
            )
    except ET.ParseError as exc:
        check(False, f"Generated AndroidManifest.xml is invalid XML: {exc}")

if android_strings_path.exists():
    try:
        android_strings_root = ET.parse(android_strings_path).getroot()
        app_name_nodes = [
            node
            for node in android_strings_root.findall("string")
            if node.attrib.get("name") == "app_name"
        ]
        check(len(app_name_nodes) == 1, "Android app_name string must exist exactly once")
        if len(app_name_nodes) == 1:
            check(
                app_name_nodes[0].text == "Auto MV Cable & TX Sizing Pro",
                "Android app_name string has incorrect text",
            )
    except ET.ParseError as exc:
        check(False, f"Generated strings.xml is invalid XML: {exc}")

# Cross-platform Git line-ending contract.
gitattributes_path = ROOT / ".gitattributes"
check(gitattributes_path.exists(), ".gitattributes is missing")
if gitattributes_path.exists():
    gitattributes = gitattributes_path.read_text(encoding="utf-8")
    check("*.json text eol=lf" in gitattributes,
          "JSON LF line-ending contract missing")
    check("*.dart text eol=lf" in gitattributes,
          "Dart LF line-ending contract missing")

# Deterministic widget-test contract.
widget_test_path = ROOT / "test" / "widget_test.dart"
check(widget_test_path.exists(), "Dashboard widget test missing")
if widget_test_path.exists():
    widget_test = widget_test_path.read_text(encoding="utf-8")
    check(re.search(r"\btester\.pumpAndSettle\s*\(", widget_test) is None,
          "Dashboard widget test must not use unbounded pumpAndSettle")
    check("tester.runAsync" in widget_test,
          "Dashboard widget test must load controlled assets with tester.runAsync")
    check("EngineeringRepository.instance.load" in widget_test,
          "Dashboard widget test must preload the controlled repository")
    check("tester.pump(const Duration(milliseconds: 100))" in widget_test,
          "Dashboard widget test must use bounded deterministic pumping")
    check("expect(tester.takeException(), isNull)" in widget_test,
          "Dashboard widget test must assert that no framework exception occurred")
    for term in [
        "database filters and records share a scrollable surface",
        "PageStorageKey<String>('mv-cable-database')",
        "tester.drag(find.byKey(key)",
    ]:
        check(term in widget_test, f"Database scrolling regression test missing {term}")

# Workflow and docs contracts.
for workflow in [".github/workflows/android.yml", ".github/workflows/windows.yml"]:
    text = (ROOT / workflow).read_text(encoding="utf-8")
    for term in [
        "python tool/validate_project.py",
        "dart format lib test",
        "dart format --output=none --set-exit-if-changed lib test",
        "flutter analyze",
        "flutter test",
    ]:
        check(term in text, f"Workflow {workflow} missing {term}")

readme = (ROOT / "README.md").read_text(encoding="utf-8")
for term in ["1.1.0+4", "MVTX-PROTECTION-V1", "Professional manual",
             "fuchsia", "AiZahid.AutoMVCableTXSizingPro",
             "315 protection and switchgear records", "does **not** claim final selectivity"]:
    check(term in readme, f"README contract missing {term}")

if errors:
    print(f"STATIC REV4 VALIDATION: FAIL — {checks} checks, {len(errors)} errors")
    for error in errors:
        print(f" - {error}")
    sys.exit(1)

print(
    f"STATIC REV4 VALIDATION: PASS — {checks} checks; "
    "fuchsia identity, controlled data, real-time equation helpers, responsive tables, "
    "database scrolling, metric-card layout, MSIX identity, workbook integrity and "
    "analytical regressions verified."
)
