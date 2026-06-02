# BUA Steam — Non-Steam Games via Auto-Scraper Only

**Session:** `2026-03-09_bua-steam-non-steam-auto-scraper`  
**Status:** TBD  
**Primary repo:** batocera-unofficial-addons  
**PR:** None yet — see [pr-status.md](pr-status.md)

## What this is

Non-Steam games added to Steam via "Add a Non-Steam Game" do not appear in EmulationStation. The production `create-steam-launchers2.sh` only scans `appmanifest_*.acf` (real Steam games). Non-Steam games are stored in `shortcuts.vdf` (binary format) with synthetic shortcut IDs — the script ignores them entirely.

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
