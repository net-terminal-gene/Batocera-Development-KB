# CRT vertical autoconfig script (libretro cores)

**Session:** `2026-05-22_crt-vertical-autoconfig-script`  
**Status:** TBD (implementation not started in Batocera-CRT-Script)  
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script  
**PR:** None yet — see [pr-status.md](pr-status.md)

## What this is

Vertical CRT on **vanilla** Batocera + CRT Script needs consistent **`batocera.conf`** keys and **RetroArch per-core / per-content** files across several libretro systems (**PC Engine**, **PC Engine CD**, **SNES**, **FinalBurn Neo**, **Neo Geo** via FBNeo, **Vectrex** via vecx, etc.). Doing this by hand per title does not scale and is easy to get wrong (videomode strings, `ratio`, core options, rotation).

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
