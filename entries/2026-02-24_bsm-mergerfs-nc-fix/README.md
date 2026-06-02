# batocera-storage-manager mergerFS =NC Fix

**Session:** `2026-02-24_bsm-mergerfs-nc-fix`  
**Status:** FIXED  
**Primary repo:** batocera.linux  
**PR:** See [pr-status.md](pr-status.md)

## What this is

When external drives are merged into the mergerFS ROM pool via `batocera-storage-manager`, the internal NVMe base directory (`/userdata/.roms_base`) is mounted as a fully writable branch. With the `mfs` (Most Free Space) create policy, mergerFS silently routes new file writes to the NVMe when it has more free space than the external drives — even though the user's intent is for all new game files to land on external drives.

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
