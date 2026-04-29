# Wayland Mode Switcher First Boot — 2026-02-22 00:28 UTC

**Purpose:** State after launching Mode Switcher from Wayland HD mode (to switch back to CRT). This is the HD->CRT leg of the roundtrip.

## System State

| Item | Value |
|------|-------|
| Uptime | 1 minute |
| Kernel | 6.18.9 (Wayland) |
| Boot image | `BOOT_IMAGE=/boot/linux` |
| Display | Wayland (`XDG_SESSION_TYPE=wayland`, `WAYLAND_DISPLAY=wayland-0`, `LABWC_VER=0.9.3`) |

## batocera.conf Video Entries

```
global.videooutput=eDP-1
global.videooutput2=none
```

No `global.videomode` — clean HD state.

## Emulatorlauncher Log — Key Lines

```
'videomode': 'default'
minTomaxResolution
video mode before minmax: 800x1280.59999
current video mode: 800x1280.59999
wanted video mode: default
resolution: 1280x800
```

No mode change — `videomode=default`. Mode Switcher launched cleanly on Wayland.

## stderr

Only `evmapy: no process found` (normal).

## Assessment

Mode Switcher launched cleanly on Wayland HD. No mode changes triggered. Controller working via evmapy. User is now running the HD->CRT switch inside the Mode Switcher. After this, system will shut down and power-on into CRT — that's the critical test where `global.videomode` gets restored and the wrapper needs to work.
