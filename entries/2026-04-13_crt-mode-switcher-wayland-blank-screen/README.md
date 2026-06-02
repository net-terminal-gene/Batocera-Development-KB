# CRT Mode Switcher: eDP-1 Blank When Launched from Wayland HD Mode

**Session:** `2026-04-13_crt-mode-switcher-wayland-blank-screen`  
**Status:** FIXED  
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script  
**PR:** [#395](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/395) (OPEN) — see [pr-status.md](pr-status.md)

## What this is

When the Mode Switcher is launched from Wayland/HD mode (as a "game" from EmulationStation), the Steam Deck's eDP-1 display goes blank. The mode switcher has no visible UI on any screen. The system is stuck with a blank eDP-1 and no way to interact with the mode switcher.

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
