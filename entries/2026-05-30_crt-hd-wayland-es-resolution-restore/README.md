# HD Mode Wayland es.resolution Restore Fix

**Session:** `2026-05-30_crt-hd-wayland-es-resolution-restore`  
**Status:** TBD  
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script  
**PR:** None yet — see [pr-status.md](pr-status.md)

## What this is

CRT→HD mode switch (or HD reboot after switch) often lands on a **black screen** on DP-1 (ASUS VG34V ultrawide). CRT Mode (X11) on the same port works. User can recover manually via SSH (`wlr-randr`, ES restart) but the issue repeats every switch until config is hand-fixed.

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
