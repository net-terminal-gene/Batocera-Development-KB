# CRT Mode Switcher: First-Run Pre-Selects eDP-1 as CRT Output

**Session:** `2026-04-13_crt-mode-switcher-firstrun-output-bug`  
**Status:** FIXED (superseded by installer bootstrap)  
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script  
**PR:** #395 — see [pr-status.md](pr-status.md)

## What this is

When the Mode Switcher runs for the first time after a CRT Script install, it pre-selects **eDP-1** as the CRT output. This is wrong — eDP-1 is the laptop's internal display, not the CRT. The CRT is connected on DP-1.

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
