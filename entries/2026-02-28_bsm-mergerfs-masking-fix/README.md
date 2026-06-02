# mergerFS Merge Move — Safe Masking Fix

**Session:** `2026-02-28_bsm-mergerfs-masking-fix`  
**Status:** FIXED  
**Primary repo:** batocera.linux  
**PR:** See [pr-status.md](pr-status.md)

## What this is

The erasure fix (mount guard) skips the merge move when the pool is still mounted. That prevents data loss but means the original move never runs. The move was intended to move "internal ROMs" to the base directory to prevent masking when adding a new drive. Masking can still occur: when .roms_base and an external drive (e.g. BATO-LG) both have the same path (e.g. megadrive), mergerFS shows one branch's content; the other is masked.

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
