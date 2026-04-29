# 09 - HD mode, pre mode switcher (second pass, fix phase)

**Date:** 2026-04-19  
**Host:** `batocera.local` (`~/bin/ssh-batocera.sh`)  
**Purpose:** Same checkpoint as [pre-fix 09](../pre-fix/09-hd-mode-pre-mode-switcher.md): **second** **HD** desktop baseline **after reboot** from [08-mode-switcher-crt-to-hd-pre-reboot.md](08-mode-switcher-crt-to-hd-pre-reboot.md), **before** another mode switcher action.

**Scope:** X11-only ([../README.md](../README.md)).

## Definition

- **`global.videooutput=HDMI-2`**, **`global.videomode=default`** (post-reboot from **08**).
- Parallels [04-hd-mode-pre-mode-switcher.md](04-hd-mode-pre-mode-switcher.md) (first HD baseline); this step checks **repeatability** after the **07 → 08** loop.

## Commands run

```bash
batocera-version
grep -n 'global.video' /userdata/system/batocera.conf
grep -n 'global.videomode' /userdata/system/batocera.conf
DISPLAY=:0.0 xrandr | head -35
grep APPEND /boot/boot/syslinux/syslinux.cfg /boot/EFI/batocera/syslinux.cfg /boot/EFI/syslinux.cfg
cat /proc/cmdline
stat /lib/firmware/edid/generic_15.bin
ls -la /lib/firmware/edid/
tail -40 /userdata/system/logs/display.log
```

## Captured output

### batocera-version

```
43 2026/04/07 09:23
```

### `batocera.conf` (video-related)

```
384:global.videooutput=HDMI-2
385:global.videomode=default
392:global.videooutput2=none
```

(Plus commented **`#global.videomode`** / **`#global.videooutput`** lines elsewhere.)

### `DISPLAY=:0.0 xrandr` (head)

- **Screen:** current **3440 × 1440**.
- **DP-1:** **connected**, not primary; low-res CRT-style mode list still present.
- **HDMI-2:** **connected primary** **3440×1440+0+0**; **3440×1440 @ 59.97** marked **`*+`**.

### `APPEND` (all three paths)

**Vanilla** on **`/boot/boot/syslinux/syslinux.cfg`**, **`/boot/EFI/batocera/syslinux.cfg`**, **`/boot/EFI/syslinux.cfg`** (no **`drm.edid_firmware`**, no **`video=DP-1:e`**).

Matches [04](04-hd-mode-pre-mode-switcher.md) fix-phase capture: **HD** boot with **clean** kernel params on disk and in **`/proc/cmdline`**.

### `/proc/cmdline` (this boot)

```
BOOT_IMAGE=/boot/linux label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0 initrd=/boot/initrd.gz
```

### `/lib/firmware/edid/generic_15.bin`

```
stat: cannot statx '/lib/firmware/edid/generic_15.bin': No such file or directory
ls: cannot access '/lib/firmware/edid/': No such file or directory
```

Same as [04](04-hd-mode-pre-mode-switcher.md): EDID blob path **not** visible in this root view during **HD** session.

### `display.log` (tail)

- Splash prefers **HDMI-2**; DRM **HDMI-A-2**.
- **`Explicit video outputs configured ( HDMI-2 none)`** → **`Invalid output - none`** (same quirk as **04**).
- **`set user output: HDMI-2 as primary`**, **`setMode: default`** on **HDMI-2**.
- **`Checker: Timed out waiting for EmulationStation web server. Aborting trigger.`** (twice) before **`set user output`**.

## Comparison: 09 vs 04 (fix phase)

| Item | [04](04-hd-mode-pre-mode-switcher.md) (first HD) | **09** (second HD) |
|------|--------------------------------|-------------------|
| **Prior step** | Reboot after [03](03-mode-switcher-crt-to-hd-pre-reboot.md) | Reboot after [08](08-mode-switcher-crt-to-hd-pre-reboot.md) |
| **`videooutput` / `videomode`** | **HDMI-2** / **default** | **Same** |
| **`xrandr` primary** | **3440×1440** on **HDMI-2** | **Same** |
| **On-disk `APPEND` + `cmdline`** | **Vanilla** | **Vanilla** |
| **`stat generic_15.bin`** | **No such file** | **No such file**; **`edid/`** dir missing too |
| **`display.log`** | **HDMI-2** + **`none`** invalid output | **Same pattern** |

**Conclusion:** Second **HD** landing matches first **HD** snapshot on this image after the round trip.

## Note vs pre-fix 09

[Pre-fix 09](../pre-fix/09-hd-mode-pre-mode-switcher.md) quoted **`APPEND`** with **`drm.edid_firmware=DP-1:…`** still on cmdline. **This** capture (post-**`03_backup_restore.sh`** work) aligns with fix **04**: **vanilla** **`APPEND`** and **`/proc/cmdline`** at **HD** boot.

## Next

- **09A:** [09A-boot-resolution-reprompt-after-crt-to-hd-save.md](09A-boot-resolution-reprompt-after-crt-to-hd-save.md) if the boot picker asks again from **HD** (why that happens with current **`02_hd_output_selection.sh`** save logic).
- **10:** [10-mode-switcher-hd-to-crt-pre-reboot.md](10-mode-switcher-hd-to-crt-pre-reboot.md) (2nd **HD→CRT** pre-reboot; **480i** boot choice). Twin: [pre-fix 10](../pre-fix/10-mode-switcher-hd-to-crt-pre-reboot.md).

## Reference

- [04-hd-mode-pre-mode-switcher.md](04-hd-mode-pre-mode-switcher.md)  
- [08-mode-switcher-crt-to-hd-pre-reboot.md](08-mode-switcher-crt-to-hd-pre-reboot.md)  
- [../pre-fix/09-hd-mode-pre-mode-switcher.md](../pre-fix/09-hd-mode-pre-mode-switcher.md)
