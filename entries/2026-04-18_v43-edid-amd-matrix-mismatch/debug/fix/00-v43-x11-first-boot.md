# 00 - v43 X11 first boot (local AMD lab, fix phase)

**Date:** 2026-04-19  
**Host:** `batocera.local` (SSH via `~/bin/ssh-batocera.sh`)  
**Capture:** Live remote commands below (not a template).

**Purpose:** Same baseline as [pre-fix 00](../pre-fix/00-v43-x11-first-boot.md): Batocera version, GPU, `TYPE_OF_CARD` helper file, `generic_15.bin`, `BUILD_15KHz_Batocera.log` EDID lines, `xrandr`.

## Context

Fix-phase step **00** on the **current** image. This capture is **after** reflashing or resetting userdata: **CRT Script is not installed** on this host yet (`/userdata/system/Batocera-CRT-Script` absent), so several paths match a **vanilla X11 first boot** like pre-fix 00 (no `generic_15.bin`).

**Test scope:** X11 only. Not Wayland / not PR #395 dual-boot.

## Commands run

```bash
batocera-version
DISPLAY=:0.0 xrandr | head -40
stat /lib/firmware/edid/generic_15.bin
cat /userdata/system/logs/TYPE_OF_CARD_DRIVERS.info
grep -E 'EDID build|Parity decision|EDID PRE-bump|Amd_NvidiaND|Intel_Nvidia_NOUV' \
  /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -30
lspci | grep -iE 'vga|3d|display'
```

**Note:** `ssh-batocera.sh` / Tcl: avoid unescaped `$VAR` in the quoted remote string; literals like `DISPLAY=:0.0` are fine.

## Captured output

### batocera-version

```
43 2026/04/07 09:23
```

### lspci (GPU)

```
03:00.0 VGA compatible controller: Advanced Micro Devices, Inc. [AMD/ATI] Navi 32 [Radeon RX 7700 XT / 7800 XT] (rev ff)
```

### TYPE_OF_CARD_DRIVERS.info

```
MISSING (file not present)
```

### stat generic_15.bin

```
stat: cannot statx '/lib/firmware/edid/generic_15.bin': No such file or directory
```

### BUILD_15KHz_Batocera.log (grep tail)

```
(no output; log file not present on this userdata)
```

### DISPLAY=:0.0 xrandr | head -40

```
Screen 0: minimum 320 x 200, current 4080 x 1440, maximum 16384 x 16384
DP-1 connected primary 640x480+0+0 (normal left inverted right x axis y axis) 0mm x 0mm
   640x480       60.00*   59.94
   ...
HDMI-2 connected 3440x1440+640+0 (normal left inverted right x axis y axis) 797mm x 334mm
   3440x1440     59.97*+  ...
```

(Full 50-line head capture stored in session; layout matches pre-fix 00: **DP-1** 640x480 primary, **HDMI-2** 3440x1440, desktop span **4080x1440**.)

### Extra checks (same SSH session)

| Check | Result |
|-------|--------|
| `/boot/EFI/syslinux.cfg` | **No such file** on this image |
| `/boot/EFI/batocera/syslinux.cfg` | Present (458 bytes, factory **APPEND**, no `drm.edid_firmware`) |
| `/boot/boot/syslinux.cfg` | Same size/date as EFI batocera copy |
| `/proc/cmdline` (filtered) | `BOOT_IMAGE=/boot/linux` only in excerpt; **no** `drm.edid_firmware` |
| `/userdata/system/Batocera-CRT-Script` | **Absent** |
| `/boot/boot/overlay` | **Absent** |

## Findings

| Item | Value |
|------|--------|
| Batocera | 43 (build **2026/04/07 09:23**) |
| GPU | AMD Navi 32 (RX 7700 XT / 7800 XT) |
| `TYPE_OF_CARD_DRIVERS.info` | **Not present** (install script not run) |
| `generic_15.bin` | **Not present** |
| `BUILD_15KHz_Batocera.log` | **Not present** |
| X11 | DP-1 640x480 primary; HDMI-2 3440x1440; span 4080x1440 |

## Next

1. Step 01 (install complete, pre-reboot): [01-crt-script-pre-reboot.md](01-crt-script-pre-reboot.md).
2. After reboot with CRT EDID: [02-crt-mode-pre-mode-switcher.md](02-crt-mode-pre-mode-switcher.md).

## Cross-reference

- Pre-fix baseline: [../pre-fix/00-v43-x11-first-boot.md](../pre-fix/00-v43-x11-first-boot.md) (had `TYPE_OF_CARD` = AMD/ATI after prior lab work; this flash does not yet).
- Syslinux layout note for this board: **no** `/boot/EFI/syslinux.cfg`; ZFE fix scans candidates in order, first hit with `drm.edid_firmware` wins once CRT install writes it (often **`EFI/batocera/syslinux.cfg`** here).
