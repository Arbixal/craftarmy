#!/usr/bin/env python3
"""Read-only stdlib structure/docs/baseline checks; NOT a Lua parser/runtime."""
from pathlib import Path
import hashlib
import re
import sys
from urllib.parse import unquote, urlsplit

ROOT = Path(__file__).resolve().parent.parent
ADDON = ROOT / "CraftArmy"
ORDER = [f"{name}.lua" for name in (
    "Core", "Storage", "Data", "Knowledge", "Collectors", "KnowledgeCheck", "Details", "ViewModel", "Dashboard", "SelfTests", "Commands"
)]
REQUIRED = [f"CraftArmy/{name}" for name in ORDER] + [
    "CraftArmy/CraftArmy.toc", "tests/dashboard.lua", "tools/check_dashboard.py",
    "docs/dashboard/README.md", "docs/dashboard/schema.md", "docs/dashboard/evidence.md",
]


def anchors(text):
    result, counts = set(), {}
    for heading in re.findall(r"^#{1,6}\s+(.+?)\s*#*\s*$", text, re.M):
        heading = re.sub(r"[\[\]`*_]", "", heading).lower()
        slug = re.sub(r"[^\w\-\s]", "", heading, flags=re.UNICODE).replace(" ", "-")
        n = counts.get(slug, 0)
        counts[slug] = n + 1
        result.add(slug if n == 0 else f"{slug}-{n}")
    result.update(re.findall(r'<a\s+(?:name|id)=[\"\']([^\"\']+)', text))
    return result


def check():
    errors = []
    for name in REQUIRED:
        if not (ROOT / name).is_file():
            errors.append(f"missing required file: {name}")
    toc = ADDON / "CraftArmy.toc"
    if not toc.is_file():
        return errors, 0, 0
    metadata, entries = {}, []
    for line in toc.read_text().splitlines():
        line = line.strip()
        if line.startswith("##"):
            key, sep, value = line[2:].partition(":")
            key, value = key.strip(), value.strip()
            if not sep or key in metadata:
                errors.append(f"malformed/duplicate TOC metadata: {line}")
            metadata[key] = value
        elif line and not line.startswith("#"):
            entries.append(line)
            target = (ADDON / line.replace("\\", "/")).resolve()
            if not target.is_relative_to(ADDON.resolve()) or not target.is_file():
                errors.append(f"unsafe/missing TOC entry: {line}")
    if entries != ORDER:
        errors.append("TOC order must match exact eleven-file manifest, no duplicates")
    for key, value in {"Interface": "120105", "Version": "0.2.0-mvp", "SavedVariables": "CraftArmyDB"}.items():
        if metadata.get(key) != value:
            errors.append(f"expected {key}: {value}")
    if not metadata.get("Title"):
        errors.append("missing Title")
    if any("SavedVariables" in k and k != "SavedVariables" for k in metadata):
        errors.append("additional saved variable declarations")
    if any(k in metadata for k in ("Dependencies", "RequiredDeps", "OptionalDeps", "LoadWith")):
        errors.append("addon dependencies not allowed")
    if re.search(r"@[^@\n]+@|\b(?:TODO|TBD|PLACEHOLDER)\b|<[^>]+>", toc.read_text(), re.I):
        errors.append("unfilled TOC metadata")
    # Fixture sentinels are isolated; inspect production modules separately.
    production_names = set()
    for name in ORDER:
        if name != "SelfTests.lua" and (ADDON / name).is_file():
            production_names.update(re.findall(r"\b([A-Za-z_]\w*DB)\b", (ADDON / name).read_text()))
    if production_names != {"CraftArmyDB"}:
        errors.append(f"production saved-variable references inconsistent: {sorted(production_names)}")
    baseline = ROOT / "docs/diagnostics/evidence.md"
    reviewed = {}
    if baseline.is_file():
        for digest, name in re.findall(r"^([0-9a-f]{64})  (\S+)$", baseline.read_text(), re.M):
            reviewed[name] = digest  # Latest reviewed R1 list supersedes original list.
    if len(reviewed) != 8:
        errors.append("expected eight reviewed diagnostic hashes")
    for name, digest in reviewed.items():
        path = (ROOT / name).resolve()
        if not path.is_relative_to(ROOT) or not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != digest:
            errors.append(f"diagnostic baseline changed: {name}")
    documents = [p for p in ROOT.rglob("*.md")
                 if not any(part.startswith(".") for part in p.relative_to(ROOT).parts)]
    links = 0
    for doc in documents:
        for target in re.findall(r"\[[^\]]*\]\(([^\s)]+)(?:\s+[^)]*)?\)", doc.read_text()):
            parts = urlsplit(target)
            if parts.scheme or parts.netloc:
                continue
            links += 1
            path = (doc.parent / unquote(parts.path)).resolve() if parts.path else doc
            if not path.is_relative_to(ROOT) or not path.exists():
                errors.append(f"broken local link: {doc.relative_to(ROOT)} -> {target}")
            elif parts.fragment and path.is_file() and unquote(parts.fragment) not in anchors(path.read_text()):
                errors.append(f"broken local anchor: {doc.relative_to(ROOT)} -> {target}")
    return errors, len(documents), links


if __name__ == "__main__":
    failures, docs, links = check()
    for failure in failures:
        print(f"FAIL: {failure}", file=sys.stderr)
    if failures:
        sys.exit(1)
    print("PASS: 17 required files; exact TOC/order/paths/metadata; isolated production SavedVariables; no dependencies")
    print(f"PASS: {docs} Markdown files inspected; {links} local links/anchors; eight diagnostic hashes unchanged")
    print("Structural only: Lua syntax, fixtures, UI and target-client APIs NOT validated")
