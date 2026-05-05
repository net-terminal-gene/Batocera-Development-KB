# 02 — Fightcade UI only (no TEST GAME)

**When:** 2026-05-04 (SSH snapshot while Fightcade main window is open; **TEST GAME not** launched in this step).

---

## Delta vs [01-baseline-after-reboot-pre-fightcade.md](01-baseline-after-reboot-pre-fightcade.md)

| | Step 01 (ES only) | This capture (Fightcade open) |
|--|---------------------|--------------------------------|
| **currentMode** | `641x480.60.00` | **`641x480.59.98`** |
| **xrandr active mode** | `641x480` **60.00*** (progressive) | **`641x480i` 59.98*** (interlaced) |
| **wmctrl windows** | 1 | **2** |

Fightcade launch path switched the desktop from **641×480 progressive** to **641×480i** on **DP-1**.

---

## Resolutions / stack

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
$ export DISPLAY=:0.0; xrandr
Screen 0: minimum 320 x 200, current 641 x 480, maximum 16384 x 16384
DP-1 connected primary 641x480+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   641x480i      59.98*+
   641x480       60.00
```

---

## Windows (`wmctrl -l`)

**Count: 2**

```text
0x00c0000b  0 BATOCERA EmulationStation
0x01200001  0 BATOCERA Fightcade - Online retro gaming
```

---

## X sockets

Still **`X0` only** (`/tmp/.X11-unix/`).

---

## Processes (relevant)

- **`fc2-electron`** (main, zygote, gpu, utility, renderer) under `/userdata/system/add-ons/fightcade/Fightcade/fc2-electron/`
- **`/userdata/system/add-ons/fightcade/extra/sym_wine.sh`** (bash parent for Wine symlink story)
- **`switchres_fightcade_wrap.sh`:** **not** in `pgrep` at this snapshot (expected at idle UI; wrapper runs when launching a `fcade://` game URL)

---

## Wrapper sanity (on device)

```text
$ bash -n /userdata/system/add-ons/fightcade/extra/switchres_fightcade_wrap.sh
(no output — OK)

$ wc -l .../switchres_fightcade_wrap.sh
345
```

Line ~271 on disk is inside **`wait_for_emulators()`**, not a stray `)` fragment.

---

## `fightcade.log` (tail)

Log still contains **older** lines from a prior session (**syntax error near `r it).`**, **`xdg-open` killed wrapper**). Current **`bash -n`** passes, so treat those lines as **historical** unless they reappear after a fresh tail following the next game launch.

Recent tail ends with **`Launching Fightcade`** / **`fc2-electron is running`** matching this session.

---

## Summary

| Metric | Value |
|--------|--------|
| **currentMode** | `641x480.59.98` |
| **Physical timing** | **Interlaced** `641x480i` active |
| **Openbox clients** | **2** (ES + Fightcade) |
| **fc2-electron** | Running |
| **switchres wrapper process** | Not running (UI idle) |

---

## Next step (checklist)

**Step 2 continuation:** launch **TEST GAME** once, wait through wrapper **`sleep`**, then capture again: **`xrandr`**, **`batocera-resolution`**, **`wmctrl -l`**, **`pgrep`**, **`tail fightcade.log`**.
