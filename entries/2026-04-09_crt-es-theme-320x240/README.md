# CRT EmulationStation Theme for 320x240

**Session:** `2026-04-09_crt-es-theme-320x240`  
**Status:** TBD  
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script  
**PR:** [#409](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/409) (MERGED) — see [pr-status.md](pr-status.md)

## What this is

No EmulationStation theme natively supports 320x240 CRT resolutions. The lowest resolution any theme targets is 640x480 (via GPi Case `tinyScreen` layouts in Carbon). When running ES at 320x240 on a CRT, text is unreadable (fonts render at 3-4px), UI elements overlap, and the interface is unusable.

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
