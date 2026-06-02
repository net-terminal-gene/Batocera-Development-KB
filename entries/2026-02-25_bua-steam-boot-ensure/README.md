# BUA Steam Boot-Time Ensure

**Session:** `2026-02-25_bua-steam-boot-ensure`  
**Status:** PR #145 MERGED 2026-02-27 (`39e84f8d`)  
**Primary repo:** batocera-unofficial-addons  
**PR:** [#145](https://github.com/batocera-unofficial-addons/batocera-unofficial-addons/pull/145) (MERGED) — see [pr-status.md](pr-status.md)

## What this is

BUA (Batocera Unofficial Addons) Steam requires `steam.emulator=sh` and `steam.core=sh` in batocera.conf to run .sh launchers. When Batocera is updated (e.g. v42 → v43), batocera.conf can be overwritten or merged in a way that drops steam.* entries—games then fail with:

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
