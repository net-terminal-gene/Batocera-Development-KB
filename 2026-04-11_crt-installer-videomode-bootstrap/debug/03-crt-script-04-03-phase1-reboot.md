# Debug 03 — CRT-Script-04-03: Phase 1 Complete, Rebooted into CRT/X11

## Date: 2026-04-13

## Script Version

**CRT-Script-04-03** — original script WITHOUT videomode-bootstrap changes. This is the known-good baseline.

## Action

Phase 1 ran from Wayland/HD mode. System rebooted. Now running in CRT/X11 mode (Phase 2 has not run yet).

## Boot Environment

```
/proc/cmdline:
BOOT_IMAGE=/crt/linux label=BATOCERA console=tty3 quiet loglevel=0
vt.global_cursor_default=0 initrd=/crt/initrd-crt.gz
```

**Note:** NO `drm.edid_firmware` or `video=DP-1:e` in kernel parameters yet. Phase 1 installs the CRT kernel/initrd and sets `DEFAULT crt` but does NOT add EDID firmware parameters — that is Phase 2's job.

## batocera.conf State (Unchanged by Phase 1)

```
global.videomode   = (empty)
global.videooutput = eDP-1    ← still the Wayland setting from stage 01
es.resolution      = (empty)
```

### Raw relevant lines from batocera.conf

```
#global.videomode=CEA 4 HDMI
global.videooutput=eDP-1
```

Phase 1 did NOT write `global.videomode` or modify `global.videooutput`. Confirmed: the installer does not bootstrap these values.

## mode_backups State

```
(empty — no files)
```

## syslinux.cfg (Post-Phase-1)

```
DEFAULT crt
...
LABEL crt
    MENU DEFAULT
    MENU LABEL Batocera CRT (X11)
    LINUX /crt/linux
    APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
    INITRD /crt/initrd-crt.gz
```

No `drm.edid_firmware=DP-1:edid/ms929.bin` or `video=DP-1:e` yet — these are added by Phase 2.

## Resolution ID State (X11, Phase 1 — No EDID Firmware Yet)

```
batocera-resolution currentMode  = (empty)
batocera-resolution listModes    = max-640x480:maximum 640x480   (no Boot_ modes yet)
es.resolution                    = (empty)
global.videomode                 = (empty)
```

### xrandr outputs

```
eDP-1  connected primary 1280x800+0+0 right   — Steam Deck internal, ACTIVE at 800x1280*@60Hz
DP-1   connected 640x480+800+0                 — DAC connected but only 640x480 available
```

### EDID firmware

```
/lib/firmware/edid/   — does not exist yet
```

### Xorg conf.d files present

```
20-amdgpu.conf
20-radeon.conf
40-input-touchpad.conf
80-nvidia-egpu.conf
99-avoid-joysticks.conf
99-nvidia.conf
```

No `10-monitor.conf`, `15-crt-monitor.conf`, or `20-modesetting.conf` yet — these are written by Phase 2.

## Key Observations

1. **Phase 1 purpose confirmed:** Gets the system into X11/CRT boot. Does NOT configure the CRT display (no EDID, no 15kHz modes, no monitor Xorg config).
2. **eDP-1 is still primary** — the Steam Deck screen is the active display at 1280x800. The CRT is on DP-1 at 640x480 only.
3. **No Boot_ modes available** — `videomodes.conf` not yet installed for 15kHz. Phase 2 installs it.
4. **batocera.conf unchanged** — `global.videooutput=eDP-1` persists from Wayland. Phase 2 will reconfigure this (or not, depending on what version of the script is run).
5. **`batocera-resolution listModes` WORKS in X11** — unlike Wayland where it returned empty. This confirms the Bootstrap Step 2 (derive CRT Boot_ mode) must run from X11 context, not Wayland.

## Next Stage

→ `04-crt-script-04-03-phase2-complete.md` — Run Phase 2 of CRT-Script-04-03, capture full state post-install before reboot.
