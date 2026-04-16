# Debug Stage X11-01 — CRT/X11 Mode: Blank Screen (Only Game Art Visible)

**Date:** 2026-04-14
**Hardware:** PC with HDMI-2 (HD) and DP-1 (CRT via DAC)
**State:** Fresh CRT Script install, CRT Mode, X11 kernel, no Wayland. Video Output not explicitly assigned in HD Mode before running CRT Script.

## User Observation

After launching the Mode Switcher from ES in CRT Mode, the user sees only the ES game-art launching screen. No xterm terminal appears. The mode switcher appears to hang with no UI.

## Investigation

### System State at Launch

```
X display :0 owner: /usr/bin/X :0 (PID 2051)
X display topology (xrandr):
  Screen 0: current 769 x 576
  DP-1 connected primary 769x576+0+0

Openbox WM: PID 2219 (openbox --config-file /etc/openbox/rc.xml)
ES: PID 2849 (emulationstation --windowed --screensize 769 576 --screenoffset 00 00)
labwc: NOT running (X11 mode confirmed)

batocera.conf:
  global.videooutput=DP-1
  global.videomode=769x576.50.00060
```

### xterm Is Running — But Not Visible

Despite the user seeing only game art, xterm and dialog are both alive:

```
PID 3638  /bin/bash /userdata/roms/crt/mode_switcher.sh  [shim]
PID 3640  xterm -fs 15 -maximized +sb ... -e mode_switcher.sh
PID 3641  /bin/bash .../Geometry_modeline/mode_switcher.sh  [on pts/0]
PID 3647  dialog --title *** WARNING *** ... [waiting for input]
```

xterm window confirmed via xdotool:
```
Window 14680076 (class: xterm, name: "mode_switcher.sh")
  Position: 0,0 (screen: 0)
  Geometry: 769x576
  Active window: YES (keyboard focus confirmed)
```

ES window:
```
Window 8388619 (class: EmulationStation, name: "EmulationStation")
  Position: 0,0 (screen: 0)
  Geometry: 769x576
  Visible (onlyvisible): YES — ES is visually on top
```

xterm's X socket connection confirmed:
```
ss -xp: xterm (PID 3640, fd 3) <-> X server (PID 2051) via /tmp/.X11-unix/X0
```

### Root Cause: Openbox Fullscreen Z-Order + ES SDL Re-Raise

**Openbox rc.xml (from /etc/openbox/rc.xml):**
```xml
<application type="normal">
  <fullscreen>yes</fullscreen>
  <decor>no</decor>
</application>
```

This forces ALL normal-type windows into Openbox's fullscreen layer. Both ES (which ES requests as windowed) and xterm (which requests -maximized) are forced to fullscreen state by Openbox.

In Openbox's EWMH stacking order:
- Fullscreen layer > Above layer > Normal layer > Below layer

Both ES and xterm land in the same "fullscreen" Z-layer. Within that layer, Z-order is last-raised wins.

ES's SDL2 render loop appears to call XRaiseWindow or SDL_RaiseWindow while displaying the launching animation, keeping ES on top. xterm has keyboard focus (getactivewindow = 14680076) but is visually buried behind ES at the same position/size.

Manual `xdotool windowraise 14680076` brings xterm to the top temporarily, but ES reclaims it.

### Why This Wasn't Caught in Previous Testing

The Wayland/HD mode debug sessions (02-05 in wayland/) tested the Steam Deck where CRT mode works correctly. The Steam Deck CRT mode was confirmed working — but that test confirmed xterm stayed alive, not necessarily that it beat ES in Z-order. The Steam Deck may not exhibit the re-raise issue due to different SDL2 version, ES build, or rendering path.

This is the first test on a multi-output PC (HDMI-2 + DP-1) in CRT/X11 mode.

## Fix Strategy

Since override-redirect cannot be set on a mapped window, and `_NET_WM_STATE_ABOVE` is below fullscreen in Openbox's layer hierarchy, the reliable fix is:

**Background watcher in the shim:** After xterm spawns, poll for its window ID and call `xdotool windowraise` every 300ms for the lifetime of xterm. This keeps xterm at the top of the fullscreen layer despite ES attempting to re-raise.

Watcher logic:
1. xterm spawned in background (`&`)
2. Subshell polls `xdotool search --pid $XTERM_PID` up to 3s
3. Once window found: loop `xdotool windowraise $WID; sleep 0.3` while `kill -0 $XTERM_PID`
4. Main script: `wait $XTERM_PID`; then `kill $WATCHER_PID`

This runs only in X11 mode (`! pgrep -x labwc`). Wayland path unchanged (labwc rule handles placement there).

## Affected File

`Geometry_modeline/crt/mode_switcher.sh` — shim script

## Success Criteria

- [ ] Launch mode switcher in CRT mode: xterm is immediately visible on DP-1
- [ ] xterm remains visible while mode switcher is open (no flickering back to game art)
- [ ] Cancel/confirm from mode switcher: ES resumes normally
- [ ] HD/Wayland mode: no regression (labwc rule path unchanged)

## Result

TBD — fix being applied and deployed.
