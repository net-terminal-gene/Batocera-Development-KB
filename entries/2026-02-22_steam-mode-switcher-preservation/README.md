# Steam Mode Switcher Preservation

**Session:** `2026-02-22_steam-mode-switcher-preservation`  
**Status:** Superseded by BUA Approach  
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script  
**PR:** See [pr-status.md](pr-status.md)

## What this is

BUA (Batocera Unofficial Addons) Steam requires `steam.emulator=sh` and `steam.core=sh` in batocera.conf to run .sh launchers. When users switch between HD and CRT modes via the Mode Switcher, Steam config can be lost and games fail with:

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
