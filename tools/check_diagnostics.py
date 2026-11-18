#!/usr/bin/env python3
"""Read-only stdlib packaging check; NOT a Lua parser or API/runtime validator."""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parent.parent
ADDON = ROOT / "CraftArmy_Diagnostics"
ORDER = ["Core.lua", "Probes.lua", "SelfTests.lua", "Commands.lua"]
REQUIRED = [f"CraftArmy_Diagnostics/{name}" for name in ORDER] + [
    "CraftArmy_Diagnostics/CraftArmy_Diagnostics.toc",
    "tests/run.lua", "tools/check_diagnostics.py",
    "docs/diagnostics/README.md", "docs/diagnostics/evidence.md",
]


def check():
    errors = []
    for name in REQUIRED:
        if not (ROOT / name).is_file():
            errors.append(f"missing required file: {name}")
    toc = ADDON / "CraftArmy_Diagnostics.toc"
    if not toc.is_file():
        return errors
    text = toc.read_text(encoding="utf-8")
    metadata, entries = {}, []
    for line in text.splitlines():
        line = line.strip()
        if line.startswith("##"):
            key, sep, value = line[2:].partition(":")
            if not sep:
                errors.append(f"malformed metadata: {line}")
                continue
            key, value = key.strip(), value.strip()
            if key in metadata:
                errors.append(f"duplicate metadata: {key}")
            metadata[key] = value
        elif line and not line.startswith("#"):
            entries.append(line)
            normalized = line.replace("\\", "/")
            target = (ADDON / normalized).resolve()
            if not target.is_relative_to(ADDON.resolve()):
                errors.append(f"manifest path escapes addon: {line}")
            if not target.is_file():
                errors.append(f"missing TOC entry: {line}")
    if entries != ORDER:
        errors.append(f"TOC entries must appear exactly once in order: {ORDER}; got {entries}")
    for key in ["Interface", "Title", "Version", "SavedVariables"]:
        if not metadata.get(key):
            errors.append(f"missing/empty metadata: {key}")
    if not re.fullmatch(r"[1-9][0-9]{5}", metadata.get("Interface", "")):
        errors.append("Interface must be an explicit six-digit number (source evidence checked by humans)")
    if re.search(r"@[^@\n]+@|\b(?:TODO|TBD|PLACEHOLDER)\b|<[^>]+>", text, re.I):
        errors.append("unfilled metadata placeholder")
    if metadata.get("SavedVariables") != "CraftArmyDiagnosticsDB":
        errors.append("SavedVariables must be exactly CraftArmyDiagnosticsDB")
    if any("SavedVariables" in key and key != "SavedVariables" for key in metadata):
        errors.append("additional SavedVariables declaration not allowed")
    if any(key in metadata for key in ["Dependencies", "RequiredDeps", "OptionalDeps", "LoadWith"]):
        errors.append("diagnostic must not force load/depend on other addons")
    names = set()
    for name in ORDER:
        source = ADDON / name
        if source.is_file():
            code = source.read_text(encoding="utf-8")
            # Naming consistency only, not Lua global/data-flow analysis.
            names.update(re.findall(r"(?<![\w.:])([A-Za-z_]\w*DB)\b", code))
    if names != {"CraftArmyDiagnosticsDB"}:
        errors.append(f"inconsistent SavedVariables references: {sorted(names)}")
    return errors


if __name__ == "__main__":
    failures = check()
    for failure in failures:
        print(f"FAIL: {failure}", file=sys.stderr)
    if failures:
        sys.exit(1)
    print("PASS: 9 required files; exact TOC order/paths/metadata; one SavedVariables name")
    print("Structural only: Lua syntax, fixtures and installed-client APIs NOT validated")
