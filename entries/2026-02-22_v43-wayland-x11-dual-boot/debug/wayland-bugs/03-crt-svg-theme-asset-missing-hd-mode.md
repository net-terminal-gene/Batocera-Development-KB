# 03 — CRT.svg Theme Asset Missing in Wayland HD Mode

**Date:** 2026-02-20 (logged), 2026-02-21 (fixed)
**Status:** FIXED

## Problem

The CRT Tools system logo (`CRT.svg` / `CRT.png`) is not visible in EmulationStation when booted into Wayland HD mode on a dual-boot system.

## Root Cause

The CRT Script copies theme assets to volatile paths inside the squashfs overlay:

```
/usr/share/emulationstation/themes/es-theme-carbon/art/logos/CRT.svg
/usr/share/emulationstation/themes/es-theme-carbon/art/consoles/CRT.png
```

These paths exist in `/usr/share/`, which is part of the read-only squashfs filesystem. They only persist across reboots via the overlay mechanism.

### Why it worked before (single-boot X11)

In single-boot X11, two mechanisms kept the assets available:

1. **CRT mode**: The overlay at `/boot/boot/overlay` contains the copied files, so they persist across reboots.
2. **HD mode**: `boot-custom.sh` (created by mode_switcher) runs on boot and copies assets from `/boot/crt_theme_assets/` back into `/usr/share/`.

### Why it fails in dual-boot Wayland HD mode

Both mechanisms are disabled:

1. **Overlay deleted**: The overlay contamination fix actively deletes `/boot/boot/overlay` when switching CRT→HD. This removes CRT.svg from the overlay.
2. **`boot-custom.sh` skipped**: The `is_dualboot_system` gate at `03_backup_restore.sh` line 824 skips `boot-custom.sh` creation for dual-boot with the comment: "Wayland has its own boot env".

### Relevant code

`03_backup_restore.sh` lines 822-825:
```bash
# Create HD mode boot-custom.sh (copies CRT theme assets from /boot to /usr/share/ on boot)
# Dual-boot: skip — Wayland boots its own kernel/initrd; no boot-custom.sh needed
if is_dualboot_system; then
    echo "Dual-boot: skipping boot-custom.sh creation (Wayland has its own boot env)" >> "$LOG_FILE"
```

`Batocera-CRT-Script-v43.sh` line 5073:
```bash
cp /userdata/system/Batocera-CRT-Script/Geometry_modeline/CRT.svg /usr/share/emulationstation/themes/es-theme-carbon/art/logos/CRT.svg
```

## Fix Applied

**Approach:** Option 1 — Wayland-compatible `boot-custom.sh` (theme-asset-only version).

In `03_backup_restore.sh`, the `is_dualboot_system` gate that previously skipped `boot-custom.sh` creation entirely now creates a **minimal dual-boot version** that only copies CRT.svg and CRT.png. No X11 configs, no VNC — Wayland-safe.

The fix:
1. Copies CRT.png and CRT.svg to `/boot/crt_theme_assets/` (persistent boot partition)
2. Creates `/boot/boot-custom.sh` that runs via `S00bootcustom` init script (before ES starts)
3. On every boot, copies from `/boot/crt_theme_assets/` → `/usr/share/emulationstation/themes/es-theme-carbon/art/`

### Why `/userdata/themes/` override didn't work

The mode_switcher already copied files to `/userdata/themes/es-theme-carbon/art/logos/CRT.svg`, but ES doesn't merge partial theme directories from `/userdata/themes/` with the complete theme in `/usr/share/`. Since `/userdata/themes/es-theme-carbon/` had no `theme.xml`, ES loaded the full theme from `/usr/share/` only.
