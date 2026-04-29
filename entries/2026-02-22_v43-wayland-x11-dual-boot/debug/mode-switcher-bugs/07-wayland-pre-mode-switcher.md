# Wayland HD Pre-Mode-Switcher — 2026-02-22 00:28 UTC

**Purpose:** State after power-on into Wayland HD mode, before launching Mode Switcher to switch back to CRT.

## System State

| Item | Value |
|------|-------|
| Uptime | <1 minute (fresh boot) |
| Kernel | 6.18.9 (Wayland) |
| Boot image | `BOOT_IMAGE=/boot/linux` (Wayland) |
| Syslinux default | `batocera` (Wayland — correct, currently running) |

## batocera.conf Video Entries

```
global.videooutput=eDP-1
global.videooutput2=none
```

No `global.videomode`, no `es.resolution` — clean HD state.

## CRT Backup Preserved

```
video_mode.txt: global.videomode=769x576.50.00
```

Correct value still intact — will be restored during HD->CRT switch.

## Theme Assets

`CRT.svg` present at `/usr/share/emulationstation/themes/es-theme-carbon/art/logos/CRT.svg` — visible in HD mode ES.

## Assessment

Wayland HD booted cleanly. `global.videooutput=eDP-1` set correctly. CRT backup has the correct `769x576.50.00` value ready for restore. CRT.svg theme asset loaded. Ready for HD->CRT Mode Switcher.
