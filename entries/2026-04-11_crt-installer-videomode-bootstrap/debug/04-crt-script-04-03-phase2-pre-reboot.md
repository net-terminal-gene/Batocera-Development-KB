# Debug 04 — CRT-Script-04-03: Phase 2 Complete, Pre-Reboot

## Date: 2026-04-13

## Script Version

**CRT-Script-04-03** — original script WITHOUT videomode-bootstrap changes.

## Action

Phase 2 ran from within CRT/X11 mode (booted via Phase 1 CRT kernel). Phase 2 completed. System is pre-reboot — capturing state before the CRT reboot that will test actual display output.

## batocera.conf State (Post-Phase-2)

```
global.videomode   = (empty — NOT written by Phase 2)
global.videooutput = eDP-1   ← UNCHANGED from Wayland pre-install state
es.resolution      = 641x480.60.00000
```

### Raw relevant lines from batocera.conf

```
#global.videomode=CEA 4 HDMI
global.videooutput=eDP-1
es.resolution=641x480.60.00000
```

**Key finding:** The original Phase 2 does NOT write `global.videomode` or `global.videooutput`.
- `global.videooutput` remains `eDP-1` (the Wayland laptop screen value from before the install).
- `es.resolution` is written by Phase 2: `641x480.60.00000` — corresponds to `Boot_480i 1.0:0:0 15KHz 60Hz`.
- `global.videomode` is left empty.

## mode_backups State

```
(empty — no files created by Phase 2)
```

This confirms the known bug: Phase 2 does not pre-populate mode switcher backup dirs.

## syslinux.cfg (Post-Phase-2)

```
LABEL crt
    MENU DEFAULT
    MENU LABEL Batocera CRT (X11)
    LINUX /crt/linux
    APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
           mitigations=off  usbhid.jspoll=0 xpad.cpoll=0
           drm.edid_firmware=DP-1:edid/ms929.bin video=DP-1:e
    INITRD /crt/initrd-crt.gz
```

Phase 2 added `drm.edid_firmware=DP-1:edid/ms929.bin video=DP-1:e`. Now the CRT entry is complete.

## EDID Firmware

```
/lib/firmware/edid/ms929.bin   ← installed by Phase 2
```

## videomodes.conf Boot_ entries

```
641x480.60.00059:Boot_480i 1.0:0:0 15KHz 60Hz
769x576.50.00060:Boot_576i 1.0:0:0 15KHz 50Hz
1028x576.50.00061:Boot_576p 1.0:0:0 15KHz 50Hz
```

Selected mode (es.resolution): `641x480.60.00000` → `Boot_480i` (480i/60Hz, NTSC).

## Resolution ID State (X11, Pre-Reboot — EDID Not Yet Active)

```
batocera-resolution listModes:
  641x480.60.00059:Boot_480i 1.0:0:0 15KHz 60Hz    ← selected
  769x576.50.00060:Boot_576i 1.0:0:0 15KHz 50Hz
  1028x576.50.00061:Boot_576p 1.0:0:0 15KHz 50Hz

es.resolution      = 641x480.60.00000
global.videomode   = (empty)
```

### xrandr (Pre-Reboot — EDID Firmware Not Loaded Yet)

```
eDP-1  connected primary 1280x800+0+0 right   — Steam Deck display, ACTIVE
DP-1   connected 640x480+800+0                 — DAC, only 640x480 (pre-EDID reboot)
```

## Xorg conf.d (Post-Phase-2)

```
10-monitor.conf        ← NEW: ignores eDP-1, enables DP-1
20-amdgpu.conf.bak
20-modesetting.conf    ← NEW: forces modesetting driver for AMD
20-radeon.conf.bak
40-input-touchpad.conf
80-nvidia-egpu.conf
99-avoid-joysticks.conf
99-nvidia.conf
```

`15-crt-monitor.conf` absent — written by `boot-custom.sh` at next boot.

## Key Observations

1. **`global.videooutput=eDP-1` stays** — Phase 2 does not change it. The CRT display works anyway because `drm.edid_firmware` + `video=DP-1:e` (kernel) and `10-monitor.conf` (Xorg) force DP-1 regardless of batocera.conf.

2. **`global.videomode` not set** — Phase 2 does not write it. This is the key difference from our bootstrap change. The original script leaves it empty and the display works.

3. **`es.resolution=641x480.60.00000`** — This is what batocera-standalone uses for xrandr setMode. It maps to `Boot_480i` (480i/60Hz). The resolution ID format in batocera.conf is `WxH.rate.NNNNN` where NNNNN is the videomodes.conf line number, but the stored value uses `00000`.

4. **Bootstrap Step 2 target**: The correct CRT mode to derive is `Boot_480i 1.0:0:0 15KHz 60Hz` (not 576i as assumed in earlier planning). The exact Boot_ mode depends on what the user selected during Phase 2 — our grep needs to match the H_RES_EDID x V_RES_EDID values set by the script for the selected profile.

5. **mode_backups empty** — Confirmed: without our bootstrap changes, no backup files exist after Phase 2.

## Next Stage

→ `05-crt-script-04-03-post-reboot.md` — Power cycle and boot into CRT, verify display output and full runtime state.
