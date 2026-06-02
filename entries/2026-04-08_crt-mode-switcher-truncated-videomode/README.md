# Mode Switcher: Truncated global.videomode — ES Shows "Auto"

**Session:** `2026-04-08_crt-mode-switcher-truncated-videomode`  
**Status:** FIXED  
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script  
**PR:** [#395](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/395) (MERGED) — see [pr-status.md](pr-status.md)

## What this is

After the mode switcher saves CRT settings, `global.videomode` in `batocera.conf` contains a truncated mode ID (e.g. `769x576.50.00`) that doesn't match any entry in `batocera-resolution listModes` (which expects `769x576.50.00060`). ES can't find a match, so it displays "Auto" in System Settings > Video Mode.

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
