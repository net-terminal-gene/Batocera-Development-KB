# v43 Docked Detection Display Override

**Session:** `2026-03-28_v43-docked-detection-display-override`  
**Status:** FIXED  
**Primary repo:** batocera.linux  
**PR:** [#395](https://github.com/ZFEbHVUE/Batocera-CRT-Script/pull/395) (MERGED) — see [pr-status.md](pr-status.md)

## What this is

On Batocera v43, plugging in a second display causes the primary configured display to go blank. The system switches output to the newly connected display, ignoring the user's explicitly saved `global.videooutput` setting. Observed on Steam Deck (eDP-1 + DP-1 CRT) and confirmed on plain PC (HDMI-2 + DP-1). No CRT script required to reproduce — stock v43 behavior.

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
