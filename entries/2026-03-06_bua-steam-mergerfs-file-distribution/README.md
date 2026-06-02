# mergerfs File Distribution — Pin Addon/Tool Systems to Internal Drive

**Session:** `2026-03-06_bua-steam-mergerfs-file-distribution`  
**Status:** FIXED (CRT + Boot Guard) / DEFERRED (BUA scripts)  
**Primary repo:** batocera-unofficial-addons  
**PR:** See [pr-status.md](pr-status.md)

## What this is

mergerfs `category.create=mfs` policy routes new file creation to the drive with the most free space. This scatters addon/tool files (steam, crt, flatpak, ports) across external drives when those drives have more free space than the internal NVMe.

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
