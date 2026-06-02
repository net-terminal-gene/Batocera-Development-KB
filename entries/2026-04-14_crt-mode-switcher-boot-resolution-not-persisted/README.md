# CRT Mode Switcher: CRT Boot Resolution Does Not Persist After HD-to-CRT Switch

**Session:** `2026-04-14_crt-mode-switcher-boot-resolution-not-persisted`  
**Status:** FIXED  
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script  
**PR:** [#395](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/395) (MERGED) — see [pr-status.md](pr-status.md)

## What this is

After using the mode switcher to go from HD Mode back to CRT Mode, the CRT boot resolution does not persist. ES shows "Auto" instead of the correct Boot_576i entry. The user believed this was addressed by `2026-04-11_crt-installer-videomode-bootstrap` (FIXED), but that fix covers the INSTALL path. This bug is on the MODE SWITCH backup/restore path.

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
