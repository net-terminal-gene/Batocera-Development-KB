# Fightcade Switchres CRT Integration

**Session:** `2026-05-04_bua-fightcade-switchres-crt`  
**Status:** PR #156 MERGED 2026-05-11 (`f40b58ad`) — full test matrix pass before merge  
**Primary repo:** batocera-unofficial-addons  
**PR:** [#156](https://github.com/batocera-unofficial-addons/batocera-unofficial-addons/pull/156) (MERGED) — see [pr-status.md](pr-status.md)

## What this is

Fightcade on Batocera runs arcade games (FBNeo, GGPO FBA, Snes9x, Flycast) through Wine at whatever the desktop resolution is. On a CRT system with the Batocera-CRT-Script, games should switch to native arcade modelines via Switchres for pixel-perfect output, but Fightcade bypasses the entire Batocera emulator launch pipeline (EmulationStation, configgen, batocera-resolution). Games launch through `fcade://` URL scheme handled by an xdg-open shim, not through the normal resolution-switching path.

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
