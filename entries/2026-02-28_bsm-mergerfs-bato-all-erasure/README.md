# BATO-ALL ROMs Erasure (mergerFS)

**Session:** `2026-02-28_bsm-mergerfs-bato-all-erasure`  
**Status:** FIXED (2026-03-01)  
**Primary repo:** batocera.linux  
**PR:** See [pr-status.md](pr-status.md)

## What this is

**User-confirmed: ROM folders are being erased from BATO-ALL** when adding BATO-LG to the mergerFS pool. Occurred multiple times; user had to restore roms repeatedly.

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
