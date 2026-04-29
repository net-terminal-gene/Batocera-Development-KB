# Debug Stage 03 — HD/Wayland Mode: Pre-Mode-Switcher State

**Date:** 2026-04-14
**State:** Fresh boot into Wayland/HD mode, DP-1 (CRT DAC) plugged in, mode switcher NOT yet launched.

## Boot

```
BOOT_IMAGE=/boot/linux (Wayland kernel)
uptime: 0 min
```

## Display Topology (wlr-randr)

```
DP-1 "(null) (null) (DP-1 via VGA)"
  Enabled: yes
  Mode: 640x480 @ 59.94 Hz
  Position: 800,0

eDP-1 "Valve Corporation ANX7530 U 0x00000001 (eDP-1)"
  Enabled: yes
  Mode: 800x1280 @ 60 Hz (preferred, current)
  Position: 1440,0
  Transform: 270
  Scale: 1.0
```

Extended desktop: DP-1 at x=800, eDP-1 at x=1440 (to the right of DP-1).

## Processes

```
labwc PID 1914 (Wayland compositor)
emulationstation PID 2862
backglass launched on DP-1 (OffsetX=1280, 640x480)
```

No Xwayland process running yet. X0 socket exists (owned by labwc PID 1914) but Xwayland is on-demand (`xwaylandPersistence=no`).

## Shim on device

```bash
#!/bin/bash
DISPLAY=:0.0 xterm -fs 15 -maximized \
    +sb \
    -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 \
    -e /userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher.sh
```

Clean original from fresh CRT script install. No `bash -c` wrapper, no `TERM=xterm`.

## display.log highlights

```
Checker: Explicit video outputs configured ( eDP-1). Skipping docked detection.
Standalone: Auto-selected second video output: DP-1
setOutput: wlr-randr --output eDP-1 --on --output DP-1 --on
Standalone: Launching backglass on 'DP-1' with OffsetX=1280
```

DP-1 is active as an extended desktop with backglass window. This is the same topology that caused the wrong-display placement bug previously.

## XWayland State

- X0 socket: `/tmp/.X11-unix/X0` (exists, owned by labwc PID 1914)
- X0-lock: PID 1914 (labwc)
- Xwayland process: **NOT running** (on-demand, no X11 clients yet)

## What Happens Next

User will launch the mode switcher from ES. If xterm triggers Xwayland on-demand startup, the question is whether xterm survives or dies in < 1 second (as observed in earlier debug session before reboot).
