# Research — HD Mode Wayland es.resolution Restore Fix

## Findings (2026-05-30, BC-250 cabinet, SSH)

### Hardware / setup

- AMD BC-250, DP-1, ASUS VG34V ultrawide
- Physical DP switch: same GPU port, CRT path vs HD path
- CRT Mode: works reliably
- HD Mode: black screen after CRT→HD switch (recoverable via SSH)

### display.log signature (failure)

```
Standalone: Setting resolution for 'DP-1' to 'default'.
currentMode: '3440x1440@164.998993Hz'
Checker: Hotplug event detected.
Checker-Init: Storing settled display list: [ ]
Standalone: Invalid output - DP-1
Wayland compositor not ready. Exiting gracefully.  (repeated)
```

### display.log signature (success after manual fix)

```
Standalone: Setting resolution for 'DP-1' to '3440x1440.59973'.
```

### Config state observed

**Bad (after HD restore):**
```
global.videomode=default   # or 3440x1440.59973 in batocera.conf only
es.resolution=default      # in batocera-boot.conf
```

**User ES menu change (1080 max) — only one file updated:**
```
/userdata/system/batocera.conf: es.resolution=max-1920x1080
/boot/batocera-boot.conf:     es.resolution=3440x1440.59973  (stale)
```

### HD backup mismatch (mode_backups/hd_mode/video_settings/)

- `video_mode.txt`: `global.videomode=default` (or later manually fixed to 3440x1440.59973)
- `es_resolution.txt`: often missing or out of sync until hand-edited
- `userdata_configs/batocera.conf`: sometimes had correct mode while sidecars did not

### BUILD_15KHz_Batocera.log (mode switcher)

```
HD Mode: Restoring factory/clean state
Using backed-up es.resolution=default (full precision)
Set es.resolution=default in both config files
```

### Backglass NONE

- Writes `global.videooutput2=none`
- Log: `Invalid output - none` — validation clears it; not root cause
- Checker logs: `Explicit video outputs configured ( DP-1 none)`

### Recovery commands (SSH)

```bash
XDG_RUNTIME_DIR=/run WAYLAND_DISPLAY=wayland-0 wlr-randr --output DP-1 --on --mode 3440x1440@59.973
XDG_RUNTIME_DIR=/run WAYLAND_DISPLAY=wayland-0 batocera-resolution setOutput DP-1
batocera-es-swissknife --restart
```

### Related merged work

- PR #395: HD/CRT mode switcher + v43 dual-boot (base); this bug is post-merge regression on Wayland restore path
- `2026-04-08_crt-mode-switcher-truncated-videomode`: CRT precision sync (similar class of bug for CRT side)
