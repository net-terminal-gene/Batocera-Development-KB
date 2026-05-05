# 03 — Street Fighter III room, pre–TEST GAME

**When:** 2026-05-04 (SSH snapshot). User joined an **SFIII** room; **TEST GAME not** started yet.

---

## Compared to [02-fightcade-ui-only.md](02-fightcade-ui-only.md)

Display stack matches **Fightcade-open baseline**: **641×480 interlaced** on **DP-1**. No extra Openbox clients vs idle Fightcade UI.

---

## Resolutions

```text
$ export DISPLAY=:0.0
$ batocera-resolution currentMode
641x480.59.98

$ batocera-resolution currentResolution
641x480

$ batocera-resolution getDisplayMode
xorg
```

```text
Screen 0: minimum 320 x 200, current 641 x 480, maximum 16384 x 16384
DP-1 connected primary 641x480+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   641x480i      59.98*+
   641x480       60.00
```

---

## Windows (`wmctrl -l`)

**Count: 2** (unchanged)

```text
0x00c0000b  0 BATOCERA EmulationStation
0x01200001  0 BATOCERA Fightcade - Online retro gaming
```

---

## Processes

| Check | Result |
|--------|--------|
| **`switchres_fightcade_wrap.sh`** | **Not** running |
| **`fcadefbneo.exe` / `pgrep -f fcadefbneo`** | **Not** running (no emulator yet) |
| **`switchres` binary (`pgrep switchres`)** | **Not** running at snapshot |
| **`fc2-electron`** | Running (same pattern as step 02) |
| **`sym_wine.sh`** | Still present (PID 5292 in this capture) |

---

## `fightcade.log` (last 60 lines)

Tail includes **`Switchres: Calculating best video mode for 384x224@59.599491`** and **`XRANDR ... duplicate request`** interleaved with **`fc2-electron is running`**, then **`Launching Fightcade`** at **05:28:30**. So either Fightcade or an earlier action in the session touched Switchres before TEST GAME, or log order reflects buffered writes. **Worth re-tailing immediately after TEST GAME** to correlate.

---

## Summary

| Metric | Value |
|--------|--------|
| **Mode** | `641x480.59.98`, **`641x480i`*** |
| **Windows** | **2** |
| **Emulator** | **Not** started |
| **Wrapper** | **Not** active |

---

## Next

Run **TEST GAME** once; after the wrapper delay (and note black vs picture), ping for **`04-test-game-street-fighter-iii-first-attempt.md`** with the same SSH bundle.
