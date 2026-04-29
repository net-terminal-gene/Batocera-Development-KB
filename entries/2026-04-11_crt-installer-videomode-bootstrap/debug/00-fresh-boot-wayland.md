# Debug 00 — Fresh Boot: Wayland (Baseline, No Bootstrap Changes)

## Date: 2026-04-13

## Purpose

Establish a clean baseline before running the CRT script. This is a fresh Batocera v43 flash on Steam Deck, booted in Wayland/HD mode. Testing with the **original** CRT script (WITHOUT the videomode-bootstrap changes) to verify what worked before and what state the installer produces naturally.

## Hardware

- Device: Steam Deck (AMD APU / Vangogh)
- CRT adapter: Cable Matters DP-to-VGA DAC
- Display: 15kHz CRT (PAL 576i, 50Hz)
- EDID profile: ms929.bin

## System State at Fresh Boot (Wayland)

```
global.videomode  = (empty — not set)
global.videooutput = (empty — not set)
es.resolution     = (empty — not set)
```

### syslinux.cfg (head)

```
UI menu.c32
TIMEOUT 10
TOTALTIMEOUT 300
SAY Booting Batocera.linux...
MENU CLEAR
MENU TITLE Batocera.linux
MENU HIDDEN
```

(Standard Batocera default — no CRT entry yet.)

### mode_backups directory

```
(not present — fresh flash)
```

## Resolution ID State (Wayland)

```
batocera-resolution listModes  = (empty — does not work in Wayland without X display)
batocera-resolution currentMode = (empty)
es.resolution                  = (empty)
global.videomode               = (empty)
```

### batocera-drminfo current output (Wayland)
```
0.0:EDP 800x1280 60Hz (800x1280*)   ← eDP-1, Steam Deck internal, ACTIVE
```
(DP-1 not yet connected at this stage)

### DRM sysfs modes (eDP-1)
```
800x1280
800x600
640x480
256x160
```

**Key observation:** In Wayland, resolution IDs are plain `WxH` strings (e.g. `800x1280`). There is no `Boot_` prefix, no `.Hz` suffix. `batocera-resolution listModes` returns nothing. The concept of a "videomode ID" that batocera.conf stores is NOT populated by Wayland ES — only `global.videooutput` and `es.resolution` are written by the ES System Settings UI.

## Notes

- `batocera.conf` has NO `global.videomode`, `global.videooutput`, or `es.resolution` set.
- The system is in pure factory Wayland state.
- Ready to run the original CRT script (without bootstrap changes).

## Next Stage

→ `01-script-run-no-bootstrap.md` — Run original CRT script, capture batocera.conf + backup state post-install.
