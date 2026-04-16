# BUA Steam — Non-Steam Games via Auto-Scraper Only

## Agent/Model Scope

Composer. No live testing yet — on vacation with laptop + Steam Deck.

## Problem

Non-Steam games added to Steam via "Add a Non-Steam Game" do not appear in EmulationStation. The production `create-steam-launchers2.sh` only scans `appmanifest_*.acf` (real Steam games). Non-Steam games are stored in `shortcuts.vdf` (binary format) with synthetic shortcut IDs — the script ignores them entirely.

A separate "Add Non-Steam Games" app was developed (`2026-03-07_bua-steam-add-non-steam-game-app`) that bypasses Steam's UI entirely. BUA maintainer feedback suggests the simpler path: extend the existing auto-scraper to also read `shortcuts.vdf`, so users who add games through Steam's normal UI get automatic ES integration with zero new apps.

## Root Cause

`create-steam-launchers2.sh` (production) loops every 5 seconds but only reads `appmanifest_*.acf`. Non-Steam shortcuts live in `shortcuts.vdf` — a different binary file with a different format. The script never touches it.

Steam's CLI (`-applaunch`, `steam://rungameid/`) does not reliably launch non-Steam shortcut IDs (see `2026-03-06_bua-steam-non-steam-game-launchers/debug/FAILURES.md`). Proton direct launch (`proton run`) is the only working approach.

## Prior Art

- `2026-03-06_bua-steam-non-steam-game-launchers` — Proved Proton direct launch works, built `shortcuts.vdf` parser, extended `create-steam-launchers2.sh` in local branch (not merged to main)
- `2026-03-07_bua-steam-add-non-steam-game-app` — Standalone app that bypasses Steam UI entirely (drop exe in folder → auto-setup). Working but has Steam Deck controller bug. May be unnecessary if auto-scraper approach is sufficient.

## Solution

Ship only the `create-steam-launchers2.sh` extension from the `2026-03-06` session. No separate app needed.

### What the auto-scraper extension does

After the existing `appmanifest_*.acf` loop, add a `shortcuts.vdf` scan that:

1. Finds `shortcuts.vdf` in `Steam/userdata/*/config/`
2. Parses binary format with inline Python (stdlib only — no `vdf` module)
3. Extracts: shortcut ID, AppName, Exe path, StartDir
4. Resolves `/root/` paths to Steam addon dir (bwrap sandbox mapping)
5. Generates Proton direct launcher (`.sh`), padtokey profile (`.keys`), and `gamelist.xml` entry

### User flow (no new app, no code the user touches)

1. Open Steam (Big Picture or Desktop Mode)
2. Add game via "Add a Non-Steam Game" in Steam's UI
3. Set Proton in game properties (Compatibility → Force)
4. Launch game once from Big Picture (creates `compatdata/` prefix)
5. Exit Steam → auto-scraper picks up `shortcuts.vdf` entry → game appears in ES

### What already exists in local branch

The `create-steam-launchers2.sh` in the `fix-fightcade-libcups` branch already has this code (lines 179-309). It was developed and validated in the `2026-03-06` session against Maldita Castilla on the live Batocera system.

### What needs to happen

1. Extract the `shortcuts.vdf` changes from current branch into a clean PR (or fold into existing PR)
2. BUA maintainer indicated they can push live updates to the script — coordinate on merge path
3. Decide fate of standalone app (`add-non-steam-game.sh`) — defer or drop

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera-unofficial-addons | `steam/extra/create-steam-launchers2.sh` | Add `shortcuts.vdf` scan + Proton direct launcher generation after appmanifest loop |

## Validation

- [ ] Verify local branch `create-steam-launchers2.sh` non-Steam section still works (test on Batocera)
- [ ] Clean commit / PR with just the auto-scraper extension
- [ ] User flow: add non-Steam game in Steam Desktop Mode → exit → game appears in ES
- [ ] User flow: launch non-Steam game from ES → Proton direct launch → game runs
- [ ] Hotkey+Start exits game and returns to ES

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

