# 03 — flycast: confirmed working (with fixes)

**Status:** PASS (first launch, fullscreen on CRT, vsync enabled)

---

## Issues found and fixed

### 1. Windowed mode (not fullscreen)

flycast config had `fullscreen = no`. On a bare X11 session at 640x480, the window happened to fill the screen, but explicit fullscreen is more reliable.

**Fix:** Added `patch_flycast_cfg()` that sets `fullscreen = yes` in `emu.cfg` before launch, restored from backup after exit.

### 2. Vsync disabled

`rend.vsync = no` can cause horizontal tearing on CRT, where the beam scans mid-frame update. Tearing is more visible on CRT than LCD.

**Fix:** `patch_flycast_cfg()` also sets `rend.vsync = yes`. Restored to original value after exit.

---

## Mandatory bundle

### xrandr during flycast TEST GAME

```text
Screen 0: minimum 320 x 200, current 640 x 480, maximum 16384 x 16384
DP-1 connected primary 640x480+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   641x480i      59.98 +
   641x480       60.00
   SR-1_640x480@59.94i  59.94*
```

### Modeline detail

```text
SR-1_640x480@59.94i  13.270MHz -HSync -VSync Interlace
    h: width   640 start  692 end  754 total  845 skew    0 clock  15.70KHz
    v: height  480 start  486 end  492 total  524           clock  59.94Hz
```

### Processes

```text
17475 /bin/bash .../bin/xdg-open fcade://play/flycast/flycast_mvsc2
17477 /bin/bash .../extra/switchres_fightcade_wrap.sh fcade://play/flycast/flycast_mvsc2
17654 .../usr/bin/flycast-dojo -config dojo:GameEntry=mvsc2 ...
17656 .../flycast/flycast.elf -config dojo:GameEntry=mvsc2 ...
```

### Config patched

```text
fullscreen = yes
rend.vsync = yes
```

### Games tested

| Game | ROM | Switchres | Refresh | Result |
|------|-----|-----------|---------|--------|
| Marvel vs Capcom 2 (Naomi) | `flycast_mvsc2` | 640x480i | 59.94 Hz | PASS |

### Scenarios tested

| Scenario | Result |
|----------|--------|
| First TEST GAME | PASS (fullscreen, good image) |
| With vsync + fullscreen patch | PASS (crisp, no tearing) |

---

## Notes

- flycast is a native Linux binary (`flycast.elf` AppImage), no Wine overhead.
- Config format: standard INI (`emu.cfg`), keys like `fullscreen = yes` under `[window]` and `rend.vsync = yes` under `[config]`.
- No resolution patching needed: flycast renders at `rend.Resolution = 480` which matches the 640x480 Switchres modeline.
- The 640x480 interlaced modeline at 15.70KHz is within 15kHz CRT range (interlaced doubles visible lines).
- Backup/restore via `.bak.switchres` copy, same pattern as FBNeo and snes9x.
