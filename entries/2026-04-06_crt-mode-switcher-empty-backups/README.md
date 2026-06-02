# Mode Switcher: Empty Backups on First Run

**Session:** `2026-04-06_crt-mode-switcher-empty-backups`  
**Status:** RESOLVED  
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script  
**PR:** #395 — see [pr-status.md](pr-status.md)

## What this is

Running `mode_switcher.sh` forces the user to re-pick all three mandatory settings (HD output, CRT output, boot resolution) because backup files don't exist yet.

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
