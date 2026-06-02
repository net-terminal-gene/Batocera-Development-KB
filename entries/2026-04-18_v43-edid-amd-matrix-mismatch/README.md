# v43 EDID Wrong Matrix on AMD Re-Install

**Session:** `2026-04-18_v43-edid-amd-matrix-mismatch`  
**Status:** PARTIAL (local lab closed; external report still open)  
**Primary repo:** batocera.linux  
**PR:** None yet — see [pr-status.md](pr-status.md)

## What this is

Tester (AMD RX6400 XT) reports that on a v43 install re-run after an HD↔CRT round trip, the regenerated `/lib/firmware/edid/generic_15.bin` contains the wrong modeset.

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
