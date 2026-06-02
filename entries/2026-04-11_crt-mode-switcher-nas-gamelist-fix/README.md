# CRT Mode Switcher: NAS Gamelist Visibility Fix

**Session:** `2026-04-11_crt-mode-switcher-nas-gamelist-fix`  
**Status:** FIXED  
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script  
**PR:** [#390](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/390) (OPEN) — see [pr-status.md](pr-status.md)

## What this is

After switching from CRT to HD mode, the `mode_switcher.sh` entry disappeared from the CRT system in EmulationStation. Users on NAS-backed ROM directories experienced this most severely. The issue was first surfaced during the `2026-04-06_crt-mode-switcher-empty-backups` session but the root cause was not identified at that time.

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
