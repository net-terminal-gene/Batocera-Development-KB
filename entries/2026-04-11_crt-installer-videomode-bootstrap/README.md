# CRT Installer: Bootstrap global.videooutput and Mode Switcher Backups

**Session:** `2026-04-11_crt-installer-videomode-bootstrap`  
**Status:** FIXED  
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script  
**PR:** [#395](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/395) (MERGED) — see [pr-status.md](pr-status.md)

## What this is

The CRT installer now writes `global.videooutput`, `global.videomode`, and `es.resolution` to `batocera.conf` at install time, and pre-seeds the mode switcher backup directories for both HD and CRT modes. After a full baseline test (stages 00–10) using the original unmodified script, the bootstrap changes were implemented and validated end-to-end (stages 11–14) on v43 hardware with an AMD GPU and ms929 EDID. ES Video Mode now shows the correct Boot_ entry immediately after first CRT boot. The mode_metadata eDP-1 first-run bug is fixed. CRT→HD mode switching works correctly.

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
