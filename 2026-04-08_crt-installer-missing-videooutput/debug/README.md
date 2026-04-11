# Debug — CRT Installer Missing global.videooutput

## Verification

```bash
# Check global.videooutput after install
ssh root@batocera.local "grep '^global.videooutput=' /userdata/system/batocera.conf"

# Check xrandr active output
ssh root@batocera.local "DISPLAY=:0 xrandr --current | head -5"

# Check ES is running on correct output
ssh root@batocera.local "pgrep -a emulationstation"

# Check kernel cmdline for CRT output
ssh root@batocera.local "cat /proc/cmdline"
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Black screen on first CRT boot (Wayland dual-boot) | `global.videooutput=eDP-1` in batocera.conf — installer never writes CRT output, factory Wayland default retained |
| ES running but CRT is black | `emulationstation-standalone` reads `global.videooutput` and targets wrong display |
| `batocera-resolution listOutputs` returns empty | Normal in X11/CRT mode — tool is DRM/Wayland-based |

## Black Screen Snapshot — Wayland Dual-Boot v43 (2026-04-07)

After reflashing to Wayland v43 and installing CRT Script + X11:

```
=== Version ===
43 2026/04/01 18:32

=== Kernel cmdline ===
BOOT_IMAGE=/crt/linux ... drm.edid_firmware=DP-1:edid/ms929.bin video=DP-1:e

=== Dual-boot ===
YES

=== X11 ===
xinit running, xrandr shows DP-1 connected primary 769x576+0+0

=== EmulationStation ===
Running (PID 2896, --screensize 769 576)

=== batocera.conf video settings ===
#global.videomode=CEA 4 HDMI        ← factory Wayland (commented out)
global.videooutput=eDP-1            ← factory Wayland default — WRONG
es.resolution=769x576.50.00000     ← correct CRT res

=== Xorg errors ===
None (clean startup)
```

Root cause: `global.videooutput=eDP-1` (factory default) never overwritten by installer.

## Post-Fix Snapshot — Wayland Dual-Boot v43 (2026-04-08)

After manually setting `global.videooutput=DP-1` and rebooting:

```
=== batocera.conf ===
global.videooutput=DP-1              ← correct
global.videomode=769x576.50.00       ← set by mode switcher restore
es.customsargs=--screensize 769 576 --screenoffset 00 00

=== xrandr ===
DP-1 connected primary 769x576+0+0 (769x576i @ 50Hz)

=== ES ===
Running, visible on CRT
```
