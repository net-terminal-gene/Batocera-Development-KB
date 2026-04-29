# Batocera-Development-KB

Knowledge base for Batocera-related development. Covers multiple projects: [Batocera-CRT-Script](https://github.com/ZFEbHVUE/Batocera-CRT-Script), [batocera-unofficial-addons](https://github.com/batocera-unofficial-addons/batocera-unofficial-addons), [batocera.linux](https://github.com/batocera-linux/batocera.linux), and others.

## Purpose

This repository preserves research, design documents, debug logs, and verdicts for Batocera development efforts. It serves as institutional memory so that future sessions have full context on past decisions, bugs encountered, fixes applied, and lessons learned — across CRT Script, BUA add-ons, storage manager, Wayland/X11, and more.

## Structure

All timestamped sessions are located in the `entries/` directory. Each session covers a specific development effort:

```
entries/
└── YYYY-MM-DD_short-description/
    ├── design/        — architecture and flow documents
    ├── research/      — live system findings and technical analysis
    ├── debug/         — step-by-step test logs and bug investigations
    ├── plan.md        — implementation plan for the session
    ├── pr-status.md   — PR tracking (required for new entries)
    └── VERDICT.md     — session retrospective and final assessment
```

**pr-status.md is required for all new entries.** Update it when a PR is created, merged, or closed. Use "No PR yet" or similar until a PR exists.

Entry names use scope prefixes when helpful (e.g. `bua-steam-*`, `bsm-mergerfs-*`, `crt-*`, `v43-*`).

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

## How This Is Used

This repository is fed into AI coding assistants (Cursor, Claude, etc.) as context during development. Rather than re-explaining project history each time, the relevant session folder is attached so the model has access to:

- What was tried before and why it failed
- Exact system states (SSH snapshots, log excerpts, config diffs)
- Root causes of past bugs and the fixes that resolved them
- Architectural decisions and reasoning

## Scope

Development efforts documented here include:

- **Batocera-CRT-Script** — CRT/HD mode switching, videomode preservation
- **BUA (batocera-unofficial-addons)** — Steam, Fightcade, add-on fixes
- **batocera.linux** — storage manager, mergerFS, core scripts
- **v43 / Wayland / X11** — display stack, dual-boot, tearing fixes
