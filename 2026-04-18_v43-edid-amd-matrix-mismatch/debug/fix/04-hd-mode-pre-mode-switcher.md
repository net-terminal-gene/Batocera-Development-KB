# 04 - HD mode, pre mode switcher (fix phase)

**Date:** 2026-04-19  
**Host:** `batocera.local` (`~/bin/ssh-batocera.sh`)  
**Purpose:** Same checkpoint as [pre-fix 04](../pre-fix/04-hd-mode-pre-mode-switcher.md): **X11** with **HDMI-2** desktop as primary after reboot from [03](03-mode-switcher-crt-to-hd-pre-reboot.md), **before** switching back toward CRT in the switcher.

**Scope:** X11-only. Not Wayland; not PR #395 dual-boot.

## Definition

- `global.videooutput=HDMI-2`, `global.videomode=default` (applied after reboot).
- No mode switcher action toward CRT yet in this step (HD desktop baseline).

## Commands run

```bash
batocera-version
grep -n 'global.video' /userdata/system/batocera.conf
grep -n 'global.videomode' /userdata/system/batocera.conf
DISPLAY=:0.0 xrandr
grep -A2 'MENU DEFAULT' /boot/boot/syslinux/syslinux.cfg | head -20
stat /lib/firmware/edid/generic_15.bin
tail -40 /userdata/system/logs/display.log
```

Extra (same session): **`grep APPEND`** on **`/boot/boot/syslinux/syslinux.cfg`**, **`/boot/EFI/batocera/syslinux.cfg`**, **`/boot/EFI/syslinux.cfg`**; **`ls /lib/firmware/edid/`**; **`cat /proc/cmdline`**.

(`xrandr` output in the log below is **`head -55`** from the capture pipe to keep the file readable.)

## Captured output

### batocera-version

```
43 2026/04/07 09:23
```

### `batocera.conf` (video)

```
384:global.videooutput2=none
385:global.videooutput=HDMI-2
386:global.videomode=default
```

(Commented `#global.videooutput` / `#global.videomode` lines omitted here; same pattern as pre-fix **04**.)

### `DISPLAY=:0.0 xrandr` (excerpt)

- **Screen:** current **3440 × 1440**.
- **DP-1:** **connected**, not primary; CRT-capable mode list still present.
- **HDMI-2:** **connected primary** **3440×1440+0+0**; **3440×1440 @ 59.97** marked **`*+`**.

### `syslinux` (**MENU DEFAULT** excerpt)

```
	MENU DEFAULT
	LINUX /boot/linux
	APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
```

### `APPEND` lines (all three paths)

```
/boot/boot/syslinux/syslinux.cfg:	APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
/boot/boot/syslinux/syslinux.cfg:	APPEND label=BATOCERA vt.global_cursor_default=0
/boot/EFI/batocera/syslinux.cfg:	APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
/boot/EFI/batocera/syslinux.cfg:	APPEND label=BATOCERA vt.global_cursor_default=0
/boot/EFI/syslinux.cfg:	APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
/boot/EFI/syslinux.cfg:	APPEND label=BATOCERA vt.global_cursor_default=0
```

**No** `drm.edid_firmware` or **`video=DP-1:e`** on any of these lines at capture time.

### `/proc/cmdline` (this boot)

```
BOOT_IMAGE=/boot/linux label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0 initrd=/boot/initrd.gz
```

**No** `drm.edid_firmware` / **`video=`** CRT overrides in the **running** kernel cmdline after this HD reboot (contrast with [03](03-mode-switcher-crt-to-hd-pre-reboot.md), where **`/proc/cmdline`** still had CRT EDID params **before** that reboot).

### `/lib/firmware/edid/generic_15.bin` and directory

```
stat: cannot statx '/lib/firmware/edid/generic_15.bin': No such file or directory
ls: cannot access '/lib/firmware/edid/': No such file or directory
```

Stronger than pre-fix **04** (which only showed **`stat`** failure): here the whole **`/lib/firmware/edid/`** path is **absent** in this root view on the HD boot. Re-check from a CRT-focused boot or after CRT restore if you need the blob on disk for comparison.

### `display.log` (tail excerpt)

- **Splash:** preferred **HDMI-2**; fallback path then **HDMI-A-2** selected.
- **Checker:** **`Explicit video outputs configured ( HDMI-2 none)`**; settled list **`[DP-1 HDMI-2]`**; **`Invalid output - none`** during validation (same harmless pattern as pre-fix **04** when **`videooutput2=none`**).
- **`set user output: HDMI-2 as primary`**
- **`setMode: default`** on **HDMI-2**

## Findings

| Check | Result |
|-------|--------|
| Primary output | **HDMI-2** @ **3440×1440** |
| **DP-1** | **Connected**, non-primary |
| On-disk **`APPEND`** (boot + EFI copies) | **Vanilla** (no CRT EDID params) |
| **`/proc/cmdline`** | **Vanilla** (no **`drm.edid_firmware`**) on this boot |
| **`generic_15.bin` / `/lib/firmware/edid/`** | **Not visible** in this capture |

## Note vs pre-fix 04

Pre-fix **04** still showed **`drm.edid_firmware`** on **`APPEND`** while on **HDMI** desktop. This fix run: **on-disk** and **live cmdline** both **omit** CRT EDID after the HD reboot, consistent with **HD restore** having propagated vanilla syslinux **before** this boot ([03](03-mode-switcher-crt-to-hd-pre-reboot.md) on-disk state).

## Next

- **05:** Skipped in fix phase (expected behavior; [pre-fix 05](../pre-fix/05-mode-switcher-hd-to-crt-no-boot-recognition.md)).
- **06:** [06-mode-switcher-hd-to-crt-pre-reboot.md](06-mode-switcher-hd-to-crt-pre-reboot.md) (HD→CRT pre-reboot).

## Reference

- [03-mode-switcher-crt-to-hd-pre-reboot.md](03-mode-switcher-crt-to-hd-pre-reboot.md)  
- [../pre-fix/04-hd-mode-pre-mode-switcher.md](../pre-fix/04-hd-mode-pre-mode-switcher.md)
