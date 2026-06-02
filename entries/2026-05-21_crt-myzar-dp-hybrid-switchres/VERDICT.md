# VERDICT — Myzar DisplayPort Hybrid Switchres

## Status: TBD

Cabinet **MAME + FBNeo Sai + Saturn (Beetle core)** validated (2026-05-22). Hybrid deploy, symlink/custom.sh, gameStop, and rotation split (`myzar-cabinet-rotate` for Sai only) stable. Session remains **TBD** until full emulator matrix + reboot regression.

## Summary

Hybrid Switchres on Myzar DP CRT works for **MAME** (normal `xrandr`, `-changeres`), **FBNeo Sai** (`ddpsdoj.zip` only: `xrandr right`, RA viewport 320×1280), and **Saturn** (Beetle core: `ratio=full`, viewport 0, `320×240` → 1280×240, **normal** xrandr). Regressions fixed 2026-05-22: MAME upside-down from broad `320×240` rotate; Sai flag cleared in `setMode`; Saturn pillarbox from core aspect/viewport + wrong SR width. See `debug/04-mame-fbneo-rotation-coexistence-pass.md`, `debug/saturn-beetle-core-crt.md`.

## Plan vs reality

- Planned: DP boot fix only → expanded to full hybrid Switchres + rotation-safe exit
- Per-game `rotate="270"` cfgs removed (opposite of early `myzar-mame-rotate` approach)
- Agent live display tests caused regressions; policy changed to read-only remote checks

## Root Causes

1. `/usr/bin` symlink reset + `custom.sh` early `exit 0`
2. `is_menu_mode` + `mame_running` blocked menu restore on gameStop
3. Rotation-lock and duplicate resolution scripts slowed exit
4. Bulk MAME rotate cfgs fought Switchres landscape timings
5. Broad `320×240` → `xrandr right` broke MAME (`dfkbl` upside down)
6. `setMode` cleared `myzar-cabinet-rotate` after `gameStart` set it — broke FBNeo Sai
7. Saturn: `Beetle Saturn.cfg` 640×480 viewport + aspect **core (22)**; SR `tail -1` picked **2048×240**
8. Saturn: mistaken Sai `xrandr right` path flipped picture (Saturn needs **normal**)

## Changes Applied

| File | Change |
|------|--------|
| `batocera-resolution-myzar.sh` | Hybrid menu/arcade paths; fixed `is_menu_mode` |
| `zzz-myzar-switchres.sh` | Background gameStart; fast gameStop |
| `custom.sh` | Symlinks before exit |
| `batocera-get-game-mode.sh` | `ddpsdoj` → `320x240.60.00` |
| `zzz-myzar-switchres.sh` | `myzar-cabinet-rotate` only `fbneo`+`ddpsdoj.zip`; sync `setMode` for Sai |
| `batocera-resolution-myzar.sh` | Read cabinet-rotate flag; **do not** rm flag in `setMode` |
| FBNeo Sai per-game cfg/opt | viewport 320×1280, TATE off, `ratio=full` — `debug/ddpsdoj-saidaioujou-known-good.md` |
| `batocera-resolution-myzar.sh` | SR pick **WIDTH×4** (not widest line at same height) |
| `Beetle Saturn.cfg` + `saturn.*` in `batocera.conf` | Core-wide stretch/timing — `debug/saturn-beetle-core-crt.md` |

## Validated titles (partial)

| Emulator | Game | ROM | Status |
|----------|------|-----|--------|
| FBNeo | DoDonPachi SaiDaiOuJou | `ddpsdoj.zip` | **PASS** (rotation + stretch) |
| MAME | DoDonPachi Dai-Ou-Jou (PGM) | `ddpdoj.zip` | **PASS** |
| MAME | Deathsmiles | `dfkbl.zip` | **PASS** (`320×240`, xrandr normal) |
| — | Coexistence MAME ↔ FBNeo Sai | — | **PASS** (user 2026-05-22) |
| Saturn | Batsugun (core defaults) | `Batsugun.chd` | **PASS** (stretch + rotation) |
| Saturn | Beetle core (all `.chd`) | system | **PASS** (core-wide config; per-ROM `videomode` for non-320×240) |
