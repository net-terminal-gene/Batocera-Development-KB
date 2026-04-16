# Debug Stage 04 — HD/Wayland Mode: Post-Mode-Switcher Launch (Fresh Boot)

**Date:** 2026-04-14
**State:** Fresh boot into Wayland/HD mode, DP-1 plugged in, mode switcher launched from ES.

## User observation

Black screen on eDP-1 (Steam Deck display). No visible UI.

## Process chain (alive and stable)

```
ES (PID 2862)
  → sh -c crt-launcher.sh ... -rom mode_switcher.sh (PIDs 4029-4032)
    → emulatorlauncher -system CRT -rom mode_switcher.sh (PID 4034)
      → /bin/bash /userdata/roms/crt/mode_switcher.sh (PID 4230)  [shim]
        → xterm -fs 15 -maximized +sb ... -e mode_switcher.sh (PID 4231)
          → /bin/bash mode_switcher.sh (PID 4250)  [real script, pts/0]
            → dialog --menu "Current Mode: HD Mode" ... switch_crt (PID 4261)
```

All processes alive. dialog waiting for user input. xterm stable (not dying).

## XWayland

```
Xwayland :0 -rootless -core -terminate 10 -listenfd 30 -listenfd 31 -displayfd 83 -wm 79
PID: 4233 (started on-demand when xterm connected)
```

Started on-demand. Alive and stable.

## Confirmed bugs

### Bug #1: Window placement (CONFIRMED)

xterm with `-maximized` and no position hint opens on DP-1 (the CRT DAC at x=800), not eDP-1 (at x=1440). The mode switcher dialog is running and interactive but invisible to the user because DP-1 is a 640x480 VGA output going to a CRT that's off.

Display topology at time of launch:
```
DP-1:  640x480 @ 59.94 Hz, Position: 800,0  (leftmost)
eDP-1: 800x1280 @ 60 Hz,   Position: 1440,0 (to the right)
```

### Bug #2: xterm death (NOT REPRODUCED)

xterm is alive and stable on fresh boot. The < 1 second death observed in the previous debug session was NOT reproduced here. This supports the hypothesis that the death was caused by stale XWayland state from repeated rapid launch/kill cycles, not by the normal first-launch path.

## Conclusions

1. **The placement bug is the real user-facing problem.** On a fresh CRT-to-HD switch with DP-1 plugged in, the user gets a black screen every time. The mode switcher is running but invisible.

2. **The xterm death bug may be a secondary issue** that only manifests after XWayland has been started and stopped multiple times in the same session (e.g., launching and cancelling the mode switcher repeatedly, or SSH-based diagnostic tests). Needs further testing to confirm.

3. **Fix priority:** Solve the placement bug first. The geometry-hint approach from `design/attempted-stemdeck-specific-fix.sh` (query wlr-randr for eDP-1 position, use `-geometry COLSxROWS+X+Y`) would address this. Needs generalization beyond eDP-1 hardcoding.
