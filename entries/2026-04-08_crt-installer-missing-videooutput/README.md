# CRT Installer: Missing global.videooutput in batocera.conf

**Session:** `2026-04-08_crt-installer-missing-videooutput`  
**Status:** TBD  
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script  
**PR:** [#395](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/395) (MERGED) — see [pr-status.md](pr-status.md)

## What this is

After reflashing to Wayland v43 and installing the CRT Script + X11, the first reboot to CRT mode produces a black screen. EmulationStation is running but rendering to `eDP-1` (the factory Wayland default) while X11/CRT is on `DP-1`.

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
