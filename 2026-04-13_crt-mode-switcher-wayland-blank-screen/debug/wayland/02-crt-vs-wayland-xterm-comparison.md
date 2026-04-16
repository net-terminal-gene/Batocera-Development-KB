# Debug Stage 02 — CRT Mode (X11) vs Wayland/HD Mode: xterm Behavior Comparison

**Date:** 2026-04-14

## CRT Mode (X11) — WORKING

**Boot:** `BOOT_IMAGE=/crt/linux` (X11 kernel, no Wayland)
**Display:** DP-1 at 769x576@50Hz via X.org (native X11, no XWayland)

### Shim on device (fresh CRT script install)

```bash
#!/bin/bash
DISPLAY=:0.0 xterm -fs 15 -maximized \
    +sb \
    -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 \
    -e /userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher.sh
```

No `bash -c` wrapper, no `TERM=xterm`. Passes the script directly to `-e`.

### Process chain (working, stable)

```
ES (PID 2460)
  → sh -c crt-launcher.sh ... -rom mode_switcher.sh (PID 3520-3523)
    → emulatorlauncher -system CRT -rom mode_switcher.sh (PID 3525)
      → /bin/bash /userdata/roms/crt/mode_switcher.sh (PID 3643)  [shim]
        → xterm -fs 15 -maximized +sb ... -e mode_switcher.sh (PID 3644)
          → /bin/bash mode_switcher.sh (PID 3645)  [real script, on pts/0]
            → dialog --title "*** WARNING ***" ... (PID 3650)  [on pts/0]
```

### emulatorlauncher environment (from es_launch_stdout.log)

Key env vars passed to the shim:
```
TERM=linux
DISPLAY=:0
XDG_RUNTIME_DIR=/var/run
WINDOWPATH=2
HOME=/userdata/system
```

No `WAYLAND_DISPLAY` (pure X11 session).

### Result

xterm opens, dialog renders, user can interact. Zero issues.

---

## Wayland/HD Mode — FAILING (xterm exits in < 1 second)

**Boot:** `BOOT_IMAGE=/boot/linux` (Wayland kernel)
**Display:** eDP-1 at 800x1280 (rotated 270) via labwc (Wayland compositor)
**X11:** XWayland on-demand via labwc (`xwaylandPersistence=no`)

### Shim tested (deployed from repo, modified during debug)

```bash
#!/bin/bash
DISPLAY=:0.0 TERM=xterm xterm -fs 15 -maximized -fg white -bg black \
    -fa "DejaVuSansMono" -en UTF-8 +sb \
    -e bash -i -c "DISPLAY=:0.0 /userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher.sh"
```

### Diagnostic results (automated tests from SSH)

**Test 1: xterm with `sleep 30` inside**
- Inner script started (wrote `INNER_STARTED` to /tmp file)
- xterm DEAD after 1 second (exit code 0)
- Inner script never reached `sleep 30` completion or `INNER_DONE`

**Test 2: xterm with dialog inside**
- Inner script started (wrote `DIALOG_START` to /tmp file)
- xterm DEAD after 1 second (exit code 0)
- dialog never returned an exit code

**Test 3: xterm with `-hold` flag (keeps window after command exits)**
- Same result: xterm DEAD after 500ms (exit code 0)

**Test 4: xterm without `-maximized`**
- Same result: xterm DEAD after 2 seconds (exit code 0)

Every variant exits in < 2 seconds with exit code 0, no xterm stderr output.

### XWayland state during tests

**Before first xterm launch:** No Xwayland process running (labwc starts it on-demand).

**During/after xterm launch:**
```
Xwayland :0 -rootless -core -terminate 10 -listenfd 30 -listenfd 31 -displayfd 86 -wm 72
```
Xwayland starts when xterm connects, remains alive (10s termination timer), but xterm still dies.

### labwc config (relevant)

```xml
<xwaylandPersistence>no</xwaylandPersistence>
```
Xwayland is NOT persistent. Started on-demand when X11 client connects, killed 10s after last client disconnects.

No window rules targeting xterm. ES has rules pinning it to eDP-1.

### Post-reboot behavior

After a clean reboot into Wayland/HD mode, the mode switcher worked on the first launch:
- Xwayland was already running (started by something during ES boot)
- xterm connected, dialog rendered, user interacted successfully

This suggests the failure may be related to Xwayland startup timing or stale state from previous sessions.

---

## Key Differences

| Aspect | CRT Mode (WORKS) | Wayland/HD Mode (FAILS) |
|--------|-------------------|-------------------------|
| Display server | X.org (native X11) | labwc (Wayland) + XWayland |
| X11 availability | Always on | On-demand (`xwaylandPersistence=no`) |
| xterm connects to | Native X display :0 | XWayland :0 (via Wayland compositor) |
| TERM from emulatorlauncher | `linux` | `linux` |
| WAYLAND_DISPLAY | not set | set (Wayland session) |
| xterm lifetime | Stable, stays open | Dies in < 1s (exit 0, no stderr) |
| xterm stderr | (none, works) | (none, but fails) |

## Open Questions

1. Why does xterm exit with code 0 and no stderr in Wayland mode?
2. Is XWayland on-demand startup racing with xterm connection?
3. Why did xterm work after a fresh reboot (Xwayland already running) but fail during the debug session (Xwayland not running)?
4. Does labwc or XWayland send WM_DELETE_WINDOW to xterm under some condition?
5. Would setting `xwaylandPersistence=yes` in labwc rc.xml fix the problem?
6. The working CRT shim passes `-e script.sh` directly. The Wayland shim used `-e bash -i -c "script.sh"`. Does this matter, or is XWayland the root cause regardless?
