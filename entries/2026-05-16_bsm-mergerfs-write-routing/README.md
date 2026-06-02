# mergerFS Write Routing and S12populateshare Awareness

**Session:** `2026-05-16_bsm-mergerfs-write-routing`  
**Status:** TBD  
**Primary repo:** batocera.linux  
**PR:** None yet — see [pr-status.md](pr-status.md)

## What this is

When multiple drives are merged via `batocera-storage-manager`, users have no control over which drive receives new content. Two separate issues compound:

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
