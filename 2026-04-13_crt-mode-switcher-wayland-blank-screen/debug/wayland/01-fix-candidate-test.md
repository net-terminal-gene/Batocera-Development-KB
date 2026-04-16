# Debug Stage 01 — Fix Candidate: wlr-randr DP-1 Suppression

**Date:** 2026-04-14
**State:** Wayland/HD mode, DP-1 (CRT DAC) plugged in, fresh boot

## What Was Changed

`Geometry_modeline/crt/mode_switcher.sh` expanded from a one-liner to a script that:
1. Checks `WAYLAND_DISPLAY` + `wlr-randr` + DP-1 enabled
2. If all true: `wlr-randr --output DP-1 --off`
3. Spawns `DISPLAY=:0.0 xterm -fs 15 -maximized ...`
4. On exit: restores DP-1 if it was disabled

## Pre-Test Verification Commands

```bash
# Confirm DP-1 is currently extended (before launching mode switcher)
wlr-randr

# Confirm the fix script is in place
cat /userdata/roms/crt/mode_switcher.sh

# Confirm WAYLAND_DISPLAY is set in the ES environment
# (ES should export it; visible in emulatorlauncher env)
cat /proc/$(pgrep emulationstation | head -1)/environ | tr '\0' '\n' | grep WAYLAND
```

## Test Procedure

1. From ES (HD mode), launch HD/CRT Mode Switcher from the CRT game list
2. Observe: xterm should appear on eDP-1 (Steam Deck screen)
3. Cancel the mode switcher (do not switch)
4. Observe: eDP-1 should return to normal ES; DP-1 should be re-enabled

## Success Criteria

- [ ] xterm UI visible on eDP-1 with DP-1 still physically connected
- [ ] Mode switcher menu is interactive (no blank screen)
- [ ] After cancel: ES resumes normally on eDP-1
- [ ] After cancel: DP-1 re-enabled (wlr-randr shows DP-1 enabled again)

## Post-Test Commands

```bash
# After cancel: verify DP-1 was restored
wlr-randr

# Check display log for any errors
tail -20 /userdata/system/logs/display.log
```

## Result

TBD — awaiting test on device.
