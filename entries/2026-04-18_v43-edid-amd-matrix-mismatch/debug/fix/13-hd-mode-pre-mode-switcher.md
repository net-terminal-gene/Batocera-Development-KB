# 13 - HD mode, pre mode switcher (third pass, fix phase)

**Date:** 2026-04-19  
**Host:** `batocera.local` (`~/bin/ssh-batocera.sh`)  
**Purpose:** Post-reboot **HD** desktop **after** [12-mode-switcher-crt-to-hd-pre-reboot.md](12-mode-switcher-crt-to-hd-pre-reboot.md) (third **CRT→HD** completion, **480i** + **09A** sidecar era), **before** another mode switcher action.

**Scope:** X11-only ([../README.md](../README.md)).

## Definition

- **`global.videooutput=HDMI-2`**, **`global.videomode=default`**, **`es.resolution=default`** (post-reboot from **12**).
- Same slug pattern as [04-hd-mode-pre-mode-switcher.md](04-hd-mode-pre-mode-switcher.md) and [09-hd-mode-pre-mode-switcher.md](09-hd-mode-pre-mode-switcher.md).

There is **no** pre-fix **`13-*.md`**; this step extends the fix ladder only.

## Commands run

```bash
batocera-version
grep -n global.videooutput /userdata/system/batocera.conf
grep -n global.videomode /userdata/system/batocera.conf
grep -n es.resolution /userdata/system/batocera.conf | head -6
DISPLAY=:0.0 xrandr | head -35
grep APPEND /boot/boot/syslinux/syslinux.cfg /boot/EFI/batocera/syslinux.cfg /boot/EFI/syslinux.cfg
cat /proc/cmdline
stat /lib/firmware/edid/generic_15.bin
ls -la /lib/firmware/edid/
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/crt_boot_display.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_mode.txt
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
386:es.resolution=default
392:global.videooutput2=none
```

### `DISPLAY=:0.0 xrandr` (head)

- **Screen:** current **3440 × 1440**.
- **DP-1:** **connected**, not primary; **640×480** family modes listed.
- **HDMI-2:** **connected primary** **3440×1440+0+0**; **3440×1440 @ 59.97** marked **`*+`**.

### `APPEND` (all three paths)

**Vanilla** on **`/boot/boot/syslinux/syslinux.cfg`**, **`/boot/EFI/batocera/syslinux.cfg`**, **`/boot/EFI/syslinux.cfg`**.

### `/proc/cmdline` (this boot)

```
BOOT_IMAGE=/boot/linux label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0 initrd=/boot/initrd.gz
```

### `/lib/firmware/edid/generic_15.bin`

```
stat: cannot statx '/lib/firmware/edid/generic_15.bin': No such file or directory
ls: cannot access '/lib/firmware/edid/': No such file or directory
```

Same as [04](04-hd-mode-pre-mode-switcher.md) / [09](09-hd-mode-pre-mode-switcher.md): path **not** visible during **HD** session.

### `mode_backups/crt_mode/video_settings/` (CRT intent on disk)

| File | Content |
|------|---------|
| **`crt_boot_display.txt`** | **`Boot_480i 1.0:0:0 15KHz 60Hz`** (**sidecar** still present after **HD** boot) |
| **`video_mode.txt`** | **`global.videomode=641x480.60.00`** (synced string from last **CRT→HD** save; unchanged by **HD** desktop alone) |

### `display.log` (tail)

- Splash prefers **HDMI-2**; DRM **HDMI-A-2**.
- **`Explicit video outputs configured ( HDMI-2 none)`** → **`Invalid output - none`** (same quirk as **04** / **09**).
- **`Checker: Timed out waiting for EmulationStation web server. Aborting trigger.`** (once) before **`set user output: HDMI-2 as primary`**.
- **`setMode: default`** on **HDMI-2**.

## Comparison: **13** vs **04** vs **09** (fix phase)

| Item | [04](04-hd-mode-pre-mode-switcher.md) (1st HD) | [09](09-hd-mode-pre-mode-switcher.md) (2nd HD) | **13** (3rd HD) |
|------|--------------------------------|-------------------|-----------------|
| **Prior CRT→HD** | [03](03-mode-switcher-crt-to-hd-pre-reboot.md) | [08](08-mode-switcher-crt-to-hd-pre-reboot.md) | [12](12-mode-switcher-crt-to-hd-pre-reboot.md) |
| **`videooutput` / `videomode` / `es.resolution`** | **HDMI-2** / **default** / (capture variant) | **HDMI-2** / **default** | **HDMI-2** / **default** / **default** |
| **`xrandr` primary** | **3440×1440** | **3440×1440** | **3440×1440** |
| **`APPEND` + `cmdline`** | **Vanilla** | **Vanilla** | **Vanilla** |
| **`crt_boot_display.txt`** | N/A (pre sidecar) | Not in **09** capture focus | **`Boot_480i …`** present |
| **ES web timeout lines** in tail | (see **04** file) | **Two** | **One** |

**Conclusion:** Third **HD** landing matches prior **HD** snapshots; **CRT** backup still carries **480i** boot label and synced **`video_mode.txt`** for the next **HD→CRT**.

## Next

- **14:** [14-mode-switcher-hd-to-crt-pre-reboot.md](14-mode-switcher-hd-to-crt-pre-reboot.md) (3rd **HD→CRT** pre-reboot; **09A** no re-pick boot).

## Reference

- [04-hd-mode-pre-mode-switcher.md](04-hd-mode-pre-mode-switcher.md)  
- [09-hd-mode-pre-mode-switcher.md](09-hd-mode-pre-mode-switcher.md)  
- [12-mode-switcher-crt-to-hd-pre-reboot.md](12-mode-switcher-crt-to-hd-pre-reboot.md)
