# 07 — SSH snapshot during black screen (live capture)

**Date / time (device):** 2026-05-04, `Mon May  4 17:10:06 MDT 2026`  
**Context:** User reported black raster; SSH probe while screen unusable.

## X / display

| Check | Result |
|--------|--------|
| `/tmp/.X11-unix/` | **`X0` only** (no `X1`; single X server on **`:0`**) |
| `DISPLAY=:1.0` | **`Can't open display :1.0`** |
| `xrandr` (DISPLAY `:0.0`) | **`Screen 0: … current 384 x 224`** |
| Output | **`DP-1` connected primary**, EDID decodes as **Nanao MS929** (`fc … ms929`), **subconnector: VGA** |
| Listed modes (abbrev.) | **`641x480i` 59.98 +**, **`641x480` 60.00**, **`SR-1_384x224@59.60`** (Switchres block with timings 384×224 @ 59.60Hz, 15.50 kHz H) |

**Interpretation:** X framebuffer is on **384×224** (arcade / Switchres-class timing). Menu modes **641×480i** remain in the mode list with **`+`** on **641x480i** in the shorter `xrandr` listing; **`batocera-resolution currentMode` / `currentResolution`** over SSH returned **empty** in a quick probe (only **`getDisplayMode`** → **`xorg`**, **`currentOutput`** → **`DP-1`**). Matches earlier observation that Switchres/custom modes can leave **`listModes`** without a clean **`*`** marker.

## EmulationStation / Fightcade processes (snippet)

- **EmulationStation** running **windowed**: `--windowed --screensize 641 480`.
- **Fightcade:** `fc2-electron` (main + gpu + renderer), **`sym_wine.sh`**.
- **`xdg-open`** → **`switchres_fightcade_wrap.sh fcade://play/fbneo/sfiii3nr1`** still present in process list.
- **Wine / FBNeo:** `fcadefbneo.exe sfiii3nr1`, **`wineserver`**, **`wine`** launcher chain active.

**Interpretation:** Session is mid–**TEST GAME** path: Switchres has switched to **384×224**, Wine emu is running; wrapper has not finished (expected until emu exits). Black screen may be **CRT unsync** at this mode, **Electron UI not visible** at arcade timing, or game framebuffer not painting yet.

## Commands used (repeat probe)

```bash
export DISPLAY=:0.0
ls -la /tmp/.X11-unix/
xrandr | head -25
batocera-resolution getDisplayMode
batocera-resolution currentMode
batocera-resolution currentResolution
batocera-resolution currentOutput
ps aux | grep -iE 'fightcade|fcade|wine|electron|fcadefbneo|emulationstation|openbox' | grep -v grep
```

## Related KB entries

- `debug/06-es-round-trip-black-screen-retest-test-game.md` — ES round-trip vs in-session (hypothesis space).
- `debug/04-black-screen-test-game-switchres-active.md` — launch timing (sleep after `-k`).
