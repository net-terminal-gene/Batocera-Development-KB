# 03 — Mode switcher CRT→HD, pre-reboot

**Date:** 2026-04-19 (capture)  
**Host:** `batocera.local` (SSH)  
**Purpose:** Snapshot **after** moving toward **HDMI / desktop output** (CRT→“HD” on **X11**) via mode switcher / ES settings, **before** reboot. Compares persisted config vs still-running CRT stack.

**Test scope:** **X11 only.** This is **not** a transition to **Wayland** or a second **HD kernel** (PR #395 dual-boot). Same Batocera **xorg** stack; output selection moves from CRT (**DP-1**) toward **HDMI-2** in `batocera.conf`.

## Definition

- Follows [02-crt-mode-pre-mode-switcher.md](02-crt-mode-pre-mode-switcher.md) baseline.
- **Pre-reboot:** `global.videooutput` already points at the HD physical output (**HDMI-2**); kernel cmdline and/or overlay may still reflect CRT until next boot.

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

## Captured output

### Version

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

ES/display policy is aimed at **HDMI-2** with **default** videomode (HD path), not a `Boot_*` CRT line.

### `/boot/boot/syslinux/syslinux.cfg` (excerpt)

Single **MENU DEFAULT** entry; kernel **APPEND** still includes CRT EDID:

```
LABEL batocera
	MENU LABEL Batocera.linux (^normal)
	MENU DEFAULT
	LINUX /boot/linux
	APPEND label=BATOCERA ... drm.edid_firmware=DP-1:edid/generic_15.bin video=DP-1:e
	INITRD /boot/initrd.gz
```

**No** second `LABEL` for a separate kernel was present in this file at capture time. **No** `/boot/crt/linux` or `/boot/hd/linux` marker files.

**Expected for this test:** We are **not** using PR #395’s **two-kernel** Wayland/X11 dual-boot. A **single** `LABEL batocera` and **no** `/boot/crt/linux` are normal for **X11-only** Batocera with the mode switcher swapping overlays on reboot, not evidence of a “missing” HD kernel entry.

### `DISPLAY=:0.0 xrandr` (excerpt)

```
Screen 0: ... current 769 x 576 ...
DP-1 connected primary 769x576+0+0 ... 485mm x 364mm
   769x576i      49.97*+
   769x576       50.00
```

CRT output **DP-1** still active; preferred mode **769x576i** at capture (vs [02](02-crt-mode-pre-mode-switcher.md) where **50.00*** was progressive).

### `display.log` (tail)

- `Splash` / `Checker`: preferred and settled output **DP-1**; explicit video outputs **DP-1**.
- `setMode: 769x576.50.00` on **DP-1** (two passes: ES restart after hotplug path).

Running stack is still **CRT resolution on DP-1** while `batocera.conf` already names **HDMI-2** for `global.videooutput`.

### Mode switcher modules (install layout)

```
01_mode_detection.sh
02_hd_output_selection.sh
03_backup_restore.sh
04_user_interface.sh
```

Present under `Geometry_modeline/mode_switcher_modules/` (timestamps align with CRT Script install).

## Findings

| Item | Observation |
|------|----------------|
| `global.videooutput` | **HDMI-2** (HD monitor) |
| Live primary / `display.log` | Still **DP-1**, **769×576** |
| `syslinux` `APPEND` | Still **`drm.edid_firmware=DP-1:edid/generic_15.bin`** |
| Dual-boot path markers | Absent (**expected** for X11-only; not testing Wayland dual-boot) |

This is the expected **split** before reboot: userdata points at **HDMI-2**; firmware cmdline and current **X11** session can still be CRT on **DP-1** until reboot applies the switcher’s boot overlay and display pipeline.

## Next

- **04-*.md:** Post-reboot with **HDMI-2** as target (still **X11**): `xrandr`, `batocera.conf`, `syslinux` again, and whether `generic_15.bin` / EDID firmware still appear on `APPEND`.

## Reference

- [02-crt-mode-pre-mode-switcher.md](02-crt-mode-pre-mode-switcher.md)
