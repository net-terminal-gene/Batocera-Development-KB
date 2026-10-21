# Fightcade Flatpak — Cursor and Pad Settings (PC CRT/HD + Steam Deck)

**Session:** `2026-09-25_fightcade-cursor-pad-settings`  
**Status:** MERGED via PR #3 (2026-09-29)  
**Primary repo:** [net-terminal-gene/batocera-fightcade-flatpak](https://github.com/net-terminal-gene/batocera-fightcade-flatpak)  
**PR:** [#3](https://github.com/net-terminal-gene/batocera-fightcade-flatpak/pull/3) — see [pr-status.md](pr-status.md)

## What this is

**Internal maintainer notes only** (not end-user or repo README material). Captures Fightcade Flatpak pad-mouse cursor speeds, ES Advanced Game Options, gamepad combos, and PC X11 CRT/HD vs Steam Deck labwc HD behavior. Written so future you (and agents) do not break PC or reintroduce Deck lobby stutter when touching `fightcade-pad-mouse`.

## Where to look

| File / folder | Purpose |
|---------------|---------|
| [plan.md](plan.md) | Scope, files to document, validation checklist |
| [VERDICT.md](VERDICT.md) | Final outcome when the session closes |
| [pr-status.md](pr-status.md) | PR links, branch, merge state |
| [research/](research/) | **Settings tables, combos, platform matrix (start here)** |
| [design/](design/) | Architecture: pad-mouse, refresh split, pointer backends |
| [debug/](debug/) | Stutter loop root causes, verification commands |

Authoritative detail lives in **research/README.md** while drafting; **VERDICT.md** when the doc pass is done.
