# BUA Steam Per-Game VIDEO MODE Fix

**Session:** `2026-02-22_bua-steam-videomode-fix`  
**Status:** FIXED (batocera-unofficial-addons)  
**Primary repo:** batocera-unofficial-addons  
**PR:** [#142](https://github.com/batocera-unofficial-addons/batocera-unofficial-addons/pull/142) (MERGED) — see [pr-status.md](pr-status.md)

## What this is

When using BUA (Batocera Unofficial Addons) Steam with per-game VIDEO MODE settings (e.g. 854x480 for Crystal Breaker on CRT), the selected mode was not applied at launch. The display remained at boot resolution (e.g. 769x576).

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
