# 03 - Mode switcher CRT to HD, pre-reboot (fix phase)

**Date:** 2026-04-19  
**Host:** `batocera.local` (`~/bin/ssh-batocera.sh`)  
**Purpose:** Same checkpoint as [pre-fix 03](../pre-fix/03-mode-switcher-crt-to-hd-pre-reboot.md): after aiming **X11** at **HDMI-2** (`batocera.conf`) via mode switcher, **before** reboot. Compare live stack vs persisted boot files.

**Scope:** X11-only. Not Wayland; not PR #395 two-kernel dual-boot.

## Definition

- Follows [02-crt-mode-pre-mode-switcher.md](02-crt-mode-pre-mode-switcher.md).
- **Pre-reboot:** `global.videooutput=HDMI-2`, `global.videomode=default`; live **X11** and **`/proc/cmdline`** may still reflect the **current** boot until the next power cycle.

## Commands run

```bash
batocera-version
cat /boot/boot/syslinux/syslinux.cfg
grep -n 'global.video' /userdata/system/batocera.conf
grep -n 'global.videomode' /userdata/system/batocera.conf
DISPLAY=:0.0 xrandr | head -35
test -f /boot/crt/linux; test -f /boot/hd/linux
ls -la /userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher_modules/
tail -80 /userdata/system/logs/display.log
```

Extra (same session): `grep APPEND /boot/EFI/batocera/syslinux.cfg`, `/boot/EFI/syslinux.cfg`, `cat /proc/cmdline`.

## Captured output

### batocera-version

```
43 2026/04/07 09:23
```

### `/userdata/system/batocera.conf` (video-related)

```
242:#global.videomode=CEA 4 HDMI
246:#global.videooutput=""
384:global.videooutput2=none
385:global.videooutput=HDMI-2
386:global.videomode=default
```

Same pattern as pre-fix **03**: policy targets **HDMI-2** with **default** videomode (not a **`Boot_*`** CRT line).

### `/boot/boot/syslinux/syslinux.cfg` (full cat)

`LABEL batocera` / **`LINUX /boot/linux`** / **`APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0`** (second `LABEL verbose` with shorter **APPEND**). **No** `drm.edid_firmware` or **`video=DP-1:e`** on these **APPEND** lines in the file on disk at capture time.

### `/boot/EFI/batocera/syslinux.cfg` and `/boot/EFI/syslinux.cfg` (**APPEND** grep)

Both files show the same **vanilla** **`APPEND`** lines (no **`drm.edid_firmware`**, no **`video=`** CRT overrides). **`/boot/EFI/syslinux.cfg`** exists on this image (**458** bytes, mtime **Apr 7** in `ls` from companion check).

### `/proc/cmdline` (this boot, immutable until reboot)

```
... drm.edid_firmware=DP-1:edid/generic_15.bin video=DP-1:e ...
```

So: **on-disk** syslinux copies already show **HD/vanilla** `APPEND`, while the **running kernel** still booted with **CRT EDID** cmdline parameters. Next boot should pick up the updated files.

### `DISPLAY=:0.0 xrandr` (head)

```
Screen 0: minimum 320 x 200, current 769 x 576, maximum 16384 x 16384
DP-1 connected primary 769x576+0+0 ... 485mm x 364mm
   769x576i      49.97*+
   769x576       50.00
```

**DP-1** still **primary** at **769×576**; preferred marker on **769x576i** at capture (differs from [02](02-crt-mode-pre-mode-switcher.md) where **50.00** progressive had `*`).

### Dual-boot markers

```
crt_no
hd_no
```

### `mode_switcher_modules/`

```
01_mode_detection.sh
02_hd_output_selection.sh
03_backup_restore.sh
04_user_interface.sh
```

### `display.log` (tail excerpt)

- **Splash**: preferred **DP-1**, matched and connected; DRM **DP-1**.
- **Checker**: explicit outputs **DP-1**; hotplug path; **setMode: 769x576.50.00** on **DP-1** (two configuration-loop passes in tail).

Running display policy still centered on **DP-1** / **769×576** while **`batocera.conf`** already names **HDMI-2**.

## Findings

| Item | Observation |
|------|----------------|
| `global.videooutput` | **HDMI-2** |
| Live **`xrandr`** / **`display.log`** | Still **DP-1**, **769×576** |
| On-disk **`APPEND`** (`/boot/boot/.../syslinux.cfg`, **`EFI/batocera`**, **`EFI/syslinux.cfg`**) | **Vanilla** (no **`drm.edid_firmware`**) at capture |
| **`/proc/cmdline`** | Still includes **`drm.edid_firmware=...`** and **`video=DP-1:e`** for this boot |
| Dual-boot path | **Absent** (expected for X11-only) |

**Note vs pre-fix 03:** Pre-fix capture still had **CRT `APPEND`** on **`/boot/boot/syslinux/syslinux.cfg`**. This fix run shows **vanilla `APPEND` already written** to the checked paths while the session has not rebooted yet, matching **HD restore propagates to all syslinux locations** behavior.

## Next

- **04:** [04-hd-mode-pre-mode-switcher.md](04-hd-mode-pre-mode-switcher.md) (HD desktop post-reboot). Twin: [pre-fix 04](../pre-fix/04-hd-mode-pre-mode-switcher.md).

## Reference

- [02-crt-mode-pre-mode-switcher.md](02-crt-mode-pre-mode-switcher.md)  
- [../pre-fix/03-mode-switcher-crt-to-hd-pre-reboot.md](../pre-fix/03-mode-switcher-crt-to-hd-pre-reboot.md)
