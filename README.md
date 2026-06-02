# Batocera-Development-KB

Knowledge base for Batocera-related development. Covers multiple projects: [Batocera-CRT-Script](https://github.com/ZFEbHVUE/Batocera-CRT-Script), [batocera-unofficial-addons](https://github.com/batocera-unofficial-addons/batocera-unofficial-addons), [batocera.linux](https://github.com/batocera-linux/batocera.linux), and others.

## Purpose

This repository preserves research, design documents, debug logs, and verdicts for Batocera development efforts. It serves as institutional memory so that future sessions have full context on past decisions, bugs encountered, fixes applied, and lessons learned — across CRT Script, BUA add-ons, storage manager, Wayland/X11, and more.

## Structure

All timestamped sessions live under `entries/`. Each folder is one development effort:

```
entries/
└── YYYY-MM-DD_short-description/
    ├── README.md        — high-level summary (start here on GitHub)
    ├── plan.md          — problem, approach, validation checklist
    ├── pr-status.md     — PR tracking (required)
    ├── VERDICT.md       — outcome when the session closes
    ├── design/          — architecture and flow
    ├── research/        — investigation notes
    └── debug/           — test logs and failure signs
```

**Read order:** `README.md` → `plan.md` → `VERDICT.md` / `pr-status.md` → subfolders as needed.

Entry slugs use scope prefixes when helpful: `bua-steam-*`, `bsm-mergerfs-*`, `crt-*`, `v43-*`.

## Creating a new entry

Use **`/batocera-kb-new`** (or `/batocera-kb new`) in Cursor. The agent scaffolds the folder, writes `README.md` from the problem statement, syncs the wiki vault, and follows templates in `.cursor/skills/batocera-kb/SKILL.md`.

Manual checklist:

1. Create `entries/YYYY-MM-DD_short-description/` with the files above.
2. Write **`README.md` first** — one paragraph on what and why, plus status and PR pointer.
3. Fill **`plan.md`** — problem, root cause (TBD ok), solution, files touched, validation.
4. Set **`pr-status.md`** to "No PR yet" until a PR exists.
5. Set **`VERDICT.md`** to `Status: TBD` until the session closes.
6. Regenerate README after major status changes: `python3 scripts/generate-entry-readmes.py` (optional; `/batocera-kb-edit` should update README by hand when closing a session).

### README.md (entry root)

GitHub shows this file when browsing an entry folder. Keep it short:

```markdown
# Human-readable title

**Session:** `YYYY-MM-DD_slug`
**Status:** TBD | MERGED | FIXED | …
**Primary repo:** owner/repo
**PR:** link or "None yet"

## What this is

One paragraph: problem, why it mattered, current state.

## Where to look

| File / folder | Purpose |
|---------------|---------|
| plan.md | … |
| VERDICT.md | … |
| pr-status.md | … |
| research/ | … |
| design/ | … |
| debug/ | … |
```

### pr-status.md

Tracks the Pull Request for the session. Example:

```markdown
# PR Status — [SCOPE_TITLE]

## PR #[number]

| Field | Value |
|-------|-------|
| Repo | owner/repo |
| PR | [#390](https://github.com/owner/repo/pull/390) |
| Branch | `feature-branch` → `main` |
| Title | Add feature description |
| Status | **OPEN** / **OPEN (Draft)** / **MERGED** / **CLOSED** |
| Created | YYYY-MM-DD |

## Review Comments

### 1. [Topic] (reviewer, date)

**File:** path

**Comment:** "..."

**Status:** Addressed / Pending

---

## Outstanding Items

- [ ] Item 1
- [ ] Item 2
```

See `entries/2026-01-26_hd-crt-mode-switcher/pr-status.md` for a full example.

### VERDICT.md

Each session's `VERDICT.md` is written after development concludes. It captures:

- **Plan vs reality** — how far the shipped code deviated from the original plan
- **Unanticipated bugs** — root causes and fixes
- **Models used** — which AI handled which phases
- **What worked / what didn't** — concrete lessons learned

When closing a session, update **`README.md`** status and PR line to match.

## How This Is Used

This repository is fed into AI coding assistants (Cursor, Claude, etc.) as context during development. Rather than re-explaining project history each time, the relevant session folder is attached so the model has access to:

- What was tried before and why it failed
- Exact system states (SSH snapshots, log excerpts, config diffs)
- Root causes of past bugs and the fixes that resolved them
- Architectural decisions and reasoning

## Related commands

| Command | Purpose |
|---------|---------|
| `/batocera-kb-new` | Scaffold entry + wiki sync |
| `/batocera-kb-edit` | Update an in-flight entry |
| `/batocera-kb-status` | PR merge/close + wiki backlog sync |

Skill source: `.cursor/skills/batocera-kb/SKILL.md`

## Scope

Development efforts documented here include:

- **Batocera-CRT-Script** — CRT/HD mode switching, videomode preservation
- **BUA (batocera-unofficial-addons)** — Steam, Fightcade, add-on fixes
- **batocera.linux** — storage manager, mergerFS, core scripts
- **v43 / Wayland / X11** — display stack, dual-boot, tearing fixes
