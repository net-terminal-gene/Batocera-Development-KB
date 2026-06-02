# CRT / HD display logging accuracy

**Session:** `2026-04-19_crt-hd-display-logging-accuracy`  
**Status:** TBD  
**Primary repo:** ZFEbHVUE/Batocera-CRT-Script  
**PR:** None yet — see [pr-status.md](pr-status.md)

## What this is

Several logs used during HD/CRT and mode-switcher debugging can **disagree with each other** or with **live `batocera.conf` / `xrandr`**, which wastes time and invites false root-cause theories.

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
