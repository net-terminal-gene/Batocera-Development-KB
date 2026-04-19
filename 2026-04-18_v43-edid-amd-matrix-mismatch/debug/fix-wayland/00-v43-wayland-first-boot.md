# 00 - v43 Wayland first boot (fix-wayland)

**Date:** 2026-04-19 (placeholder; set from capture)  
**Host:** (e.g. `batocera.local`, SSH)  
**Compositor / session:** **Wayland** (not X11)  
**Scope:** [fix-wayland README](README.md) — baseline **before** CRT Script **X11** install.

## Definition

- Stock **v43** (or target image) on **Wayland** **HD** path: no CRT overlay X11 stack yet.
- Establishes **`batocera.conf`**, **boot**, and **output** picture for **`01`** and later.

## Commands run

```bash
# Fill when documenting (Wayland-appropriate; no xrandr on pure Wayland)
batocera-version
# batocera-settings-get global.videooutput
# batocera-settings-get global.videomode
# cat /proc/cmdline
# grep APPEND /boot/EFI/syslinux.cfg /boot/boot/syslinux.cfg 2>/dev/null | head -10
```

## Captured output

*(Mikey: paste SSH or local notes here. Step marked **done** on device; body can stay thin until you file captures.)*

## Notes

- **Do not** assume **`DISPLAY=:0.0 xrandr`** until **01** (X11 / CRT install) is complete.

## Next

- **01:** [01-crt-x11-install-from-wayland-hd.md](01-crt-x11-install-from-wayland-hd.md)
