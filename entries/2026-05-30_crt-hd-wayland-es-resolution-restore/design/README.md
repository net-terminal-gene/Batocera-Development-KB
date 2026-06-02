# Design — HD Mode Wayland es.resolution Restore Fix

## Architecture

### Batocera HD boot (Wayland)

```
batocera-boot.conf (es.resolution)  ← boot authority for primary screen
        ↓
emulationstation-standalone
        ↓
batocera-resolution setMode (wlr-randr on labwc)
        ↓
ES launch → currentMode logged
        ↓
udev DRM HOTPLUG=1 → batocera-switch-screen-checker-delayed (2s)
        ↓
ES quit + display reconfigure loop
```

### Mode switcher HD restore (today)

```
hd_mode/video_settings/video_mode.txt  ─┐
hd_mode/video_settings/es_resolution.txt ┼→ restore_video_settings()
hd_mode/userdata_configs/batocera.conf   ─┘   (priority / guard bugs)
        ↓
batocera.conf + batocera-boot.conf
        ↓
reboot → Wayland boot
```

### Target flow (fixed)

```
Mode switcher UI: user picks HD output + video mode (incl. max-1920x1080)
        ↓
Save: video_mode.txt + es_resolution.txt + both conf files (same value)
        ↓
Optional: touch /tmp/no-hotplug before reboot
        ↓
Boot: es.resolution from boot conf matches user choice
        ↓
No 165Hz spike → no hotplug storm
```

## Key Batocera references

- `emulationstation-standalone` line ~198: `-f "$BOOTCONF" es.resolution`
- `batocera-switch-screen-checker`: `/tmp/no-hotplug` bypass
- udev: `/etc/udev/rules.d/80-switch-screen.rules`

## CRT vs HD

| | CRT (X11) | HD (Wayland) |
|---|-----------|--------------|
| Compositor | Xorg | labwc |
| Resolution tool | xrandr | wlr-randr |
| Boot mode | Boot_ modeline / explicit videomode | **es.resolution** in boot conf |
| This bug | Not observed | Black screen on switch |
