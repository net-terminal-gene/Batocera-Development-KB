#!/usr/bin/env python3
"""Generate or refresh top-level README.md for each entries/YYYY-MM-DD_slug/ folder."""

from __future__ import annotations

import re
from pathlib import Path

ENTRIES = Path(__file__).resolve().parents[1] / "entries"

SCOPE_REPOS = {
    "bua-": "batocera-unofficial-addons",
    "bsm-": "batocera.linux",
    "crt-": "ZFEbHVUE/Batocera-CRT-Script",
    "v43-": "batocera.linux",
    "hd-crt-": "ZFEbHVUE/Batocera-CRT-Script",
    "steam-": "ZFEbHVUE/Batocera-CRT-Script",
}


def infer_repo(slug: str) -> str:
    for prefix, repo in SCOPE_REPOS.items():
        if slug.startswith(prefix):
            return repo
    if slug.startswith("2026-"):
        pass
    # date prefix stripped below
    return "multiple / see plan.md"


def repo_for_folder(name: str) -> str:
    _, _, slug = name.partition("_")
    if not slug:
        return "see plan.md"
    for prefix, repo in SCOPE_REPOS.items():
        if slug.startswith(prefix):
            return repo
    return "see plan.md"


def first_heading(text: str) -> str:
    for line in text.splitlines():
        if line.startswith("# "):
            return line[2:].strip()
    return ""


def section_paragraph(text: str, heading: str) -> str:
    lines = text.splitlines()
    capture: list[str] = []
    in_section = False
    for line in lines:
        if line.startswith("## "):
            if in_section:
                break
            if line[3:].strip().lower() == heading.lower():
                in_section = True
            continue
        if in_section:
            if line.startswith("#"):
                break
            if line.strip():
                capture.append(line.strip())
            elif capture:
                break
    return " ".join(capture) if capture else ""


def verdict_status(text: str) -> str:
    m = re.search(r"^## Status:?\s*(.+)$", text, re.MULTILINE | re.IGNORECASE)
    if m:
        line = re.sub(r"\*\*", "", m.group(1).strip())
        if ". " in line:
            line = line.split(". ", 1)[0] + "."
        if len(line) > 100:
            line = line[:97] + "..."
        return line
    return "TBD (see VERDICT.md)"


def pr_line(text: str) -> str:
    if "no pr yet" in text.lower():
        return "None yet — see [pr-status.md](pr-status.md)"
    m = re.search(r"\[#(\d+)\]\((https://[^)]+)\)", text)
    if m:
        num, url = m.groups()
        status = "OPEN"
        for pat in (r"\*\*MERGED\*\*", r"MERGED", r"\*\*CLOSED\*\*", r"CLOSED"):
            if re.search(pat, text, re.IGNORECASE):
                status = pat.replace("*", "").replace("\\", "")
                break
        return f"[#{num}]({url}) ({status}) — see [pr-status.md](pr-status.md)"
    m = re.search(r"PR #(\d+)", text, re.IGNORECASE)
    if m:
        return f"#{m.group(1)} — see [pr-status.md](pr-status.md)"
    return "See [pr-status.md](pr-status.md)"


def build_readme(entry_dir: Path) -> str:
    name = entry_dir.name
    plan = (entry_dir / "plan.md").read_text(encoding="utf-8") if (entry_dir / "plan.md").exists() else ""
    verdict = (entry_dir / "VERDICT.md").read_text(encoding="utf-8") if (entry_dir / "VERDICT.md").exists() else ""
    pr = (entry_dir / "pr-status.md").read_text(encoding="utf-8") if (entry_dir / "pr-status.md").exists() else ""

    title = first_heading(plan) or name.replace("_", " ").title()
    summary = section_paragraph(plan, "Problem") or section_paragraph(verdict, "Summary")
    if not summary:
        summary = "Development session — see plan.md for scope and validation steps."

    status = verdict_status(verdict) if verdict else "TBD"
    repo = repo_for_folder(name)

    return f"""# {title}

**Session:** `{name}`  
**Status:** {status}  
**Primary repo:** {repo}  
**PR:** {pr_line(pr)}

## What this is

{summary}

## Where to look

| File / folder | Purpose |
|---------------|---------|
| [plan.md](plan.md) | Problem, approach, files touched, validation checklist |
| [VERDICT.md](VERDICT.md) | Final outcome when the session closes |
| [pr-status.md](pr-status.md) | PR links, branch, merge state |
| [research/](research/) | Investigation notes and system findings |
| [design/](design/) | Architecture and flow |
| [debug/](debug/) | Test logs, repro steps, failure signs |

Authoritative detail lives in **VERDICT.md** and **pr-status.md** once work is done; **plan.md** shows original intent vs what shipped.
"""


def main() -> None:
    count = 0
    for entry_dir in sorted(ENTRIES.iterdir()):
        if not entry_dir.is_dir() or entry_dir.name.startswith("."):
            continue
        readme = entry_dir / "README.md"
        readme.write_text(build_readme(entry_dir), encoding="utf-8")
        count += 1
    print(f"Wrote {count} README.md files under {ENTRIES}")


if __name__ == "__main__":
    main()
