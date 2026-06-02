# CRT Tools on Boot Drive (mergerFS Conflict)

**Session:** `2026-02-25_crt-tools-nvme-mergerfs`  
**Status:** FIXED  
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script  
**PR:** See [pr-status.md](pr-status.md)

## What this is

With the mergerFS `=NC` fix applied, new file writes to `/userdata/roms/` go to external drives, not the boot drive. The Batocera-CRT-Script mode switcher **requires** CRT Tools (`/userdata/roms/crt/`) to be on the **Batocera boot drive** (NVMe, SATA, or microSD) during HD/CRT mode switches because:

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
