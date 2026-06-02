# BUA Steam — Add Non-Steam Game to ES App

**Session:** `2026-03-07_bua-steam-add-non-steam-game-app`  
**Status:** TBD  
**Primary repo:** batocera-unofficial-addons  
**PR:** None yet — see [pr-status.md](pr-status.md)

## What this is

Adding a non-Steam game to EmulationStation currently requires multiple manual steps: copying files to the right directory, entering Steam Desktop Mode, adding the game via "Add a Non-Steam Game", setting Proton, launching once from Big Picture to create the Wine/Proton prefix, then waiting for the launcher generator to pick it up.

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
