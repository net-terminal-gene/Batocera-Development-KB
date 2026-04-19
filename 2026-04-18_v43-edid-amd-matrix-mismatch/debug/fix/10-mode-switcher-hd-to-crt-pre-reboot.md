# 10 - Mode switcher HD to CRT, pre-reboot (second cycle, fix phase)

**Date:** 2026-04-19  
**Host:** `batocera.local` (`~/bin/ssh-batocera.sh`)  
**Scope:** X11-only ([../README.md](../README.md)).

## Observer note (Mikey)

This is the **second full HD→CRT** leg after [09-hd-mode-pre-mode-switcher.md](09-hd-mode-pre-mode-switcher.md). **`Config check`** still showed **`Boot:`** empty at **`19:08:06`** (same **`09A`** situation: backup **`video_mode.txt`** had been replaced with a **`currentMode`** string that does not reverse-map to **`Boot_…`**). The boot picker ran; **you chose `Boot_480i 1.0:0:0 15KHz 60Hz`** (480i / NTSC-style boot) instead of staying on **576i**.

## Definition

- **HD→CRT** via mode switcher (**`target: crt`**), **before reboot** onto the CRT-primary layout.
- **`batocera.conf`** already **CRT-oriented** (**`DP-1`**, **`641x480.60.00052`**); **live** **`xrandr`** still **HDMI-2** primary **3440×1440** until reboot.
- Twin concept: [pre-fix 10](../pre-fix/10-mode-switcher-hd-to-crt-pre-reboot.md) (that capture kept **576i**; this one documents **480i** after the **09A** empty-boot path).

## Commands run

```bash
batocera-version
grep -n global.videooutput /userdata/system/batocera.conf
grep -n global.videomode /userdata/system/batocera.conf
grep -n es.resolution /userdata/system/batocera.conf | head -8
DISPLAY=:0.0 xrandr | head -26
grep APPEND /boot/boot/syslinux/syslinux.cfg /boot/EFI/batocera/syslinux.cfg /boot/EFI/syslinux.cfg
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/video_output.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_output.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_mode.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/es_resolution.txt
grep 'Mode switch UI started' /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -8
# plus targeted BUILD lines (see Captured output)
```

## Captured output

### batocera-version

```
43ov 2026/04/07 09:23
```

([Inference] Treat as Batocera **43** if the **`ov`** suffix is a terminal capture artifact, same as [06](06-mode-switcher-hd-to-crt-pre-reboot.md).)

### `batocera.conf` (video-related, pre-reboot CRT intent)

```
384:global.videomode=641x480.60.00052
385:global.videooutput=DP-1
386:es.resolution=641x480.60.00052
```

### `DISPLAY=:0.0 xrandr` (head)

- **Screen:** current **3440 × 1440**.
- **HDMI-2:** **connected primary** **3440×1440** (`*+`).
- **DP-1:** connected, **not** primary; mode list includes **640×480** family.

**Interpretation:** **userdata** already targets **CRT** at **480i-class** mode id **`641x480.60.00052`**; **live** stack still **HD** until reboot.

### `APPEND` (all three paths checked)

**CRT** parameters present on **`/boot/boot/syslinux/syslinux.cfg`**, **`/boot/EFI/batocera/syslinux.cfg`**, **`/boot/EFI/syslinux.cfg`**:

```
... drm.edid_firmware=DP-1:edid/generic_15.bin video=DP-1:e
```

### `mode_backups/` (`video_settings`)

| File | Content |
|------|---------|
| `hd_mode/video_settings/video_output.txt` | `global.videooutput=HDMI-2` |
| `crt_mode/video_settings/video_output.txt` | `global.videooutput=DP-1` |
| `crt_mode/video_settings/video_mode.txt` | `global.videomode=641x480.60.00052` |
| `crt_mode/video_settings/es_resolution.txt` | `es.resolution=641x480.60.00052` |

### `BUILD_15KHz_Batocera.log` (this run)

**`target: crt`** session start (empty **Boot** in **`Config check`**, boot picker):

```
[19:08:06]: Mode switch UI started for target: crt
[19:08:06]: Config check - HD: HDMI-2, CRT: DP-1, Boot: 
[19:08:06]: Needs - HD: false, CRT: false, Boot: true, All configured: false
[19:08:06]: Boot resolution selection started
```

**User choice: 480i boot** (then save and **`03`** restore activity):

```
[19:16:49]: User selected boot resolution: Boot_480i 1.0:0:0 15KHz 60Hz
[19:16:50]: Boot resolution confirmed: Boot_480i 1.0:0:0 15KHz 60Hz
[19:16:51]: Saving selections - HD: HDMI-2, CRT: DP-1, Boot: Boot_480i 1.0:0:0 15KHz 60Hz
[19:16:51]: Converting boot mode - input: 'Boot_480i 1.0:0:0 15KHz 60Hz', output: '641x480.60.00052'
[19:16:51]: Saved boot mode ID: 641x480.60.00052 (display: Boot_480i 1.0:0:0 15KHz 60Hz)
[19:16:51]: Mode switch UI completed successfully
```

**`03_backup_restore`** tail (CRT restore used backed-up **`es.resolution`**):

```
[19:16:55]: Using backed-up es.resolution=641x480.60.00052 (full precision)
[19:16:55]: Set es.resolution=641x480.60.00052 in both config files
```

(Pre-reboot capture taken during / after that restore block.)

## Comparison: fix **06** vs fix **10**

| Item | [06](06-mode-switcher-hd-to-crt-pre-reboot.md) (first HD→CRT) | **10** (second HD→CRT) |
|------|--------------------------------|------------------------|
| **Boot in `Config check`** | **Empty** then user picked **576i** | **Empty** at **`19:08:06`** ([09A](09A-boot-resolution-reprompt-after-crt-to-hd-save.md)), user picked **480i** |
| **`Converting boot mode` output** | **`769x576.50.00053`** | **`641x480.60.00052`** |
| **Live `xrandr` primary** | HDMI-2 @ 3440×1440 | Same pattern |
| **`APPEND` EDID on disk** | Present on all three paths | Same |

## Next

- **11:** [11-crt-mode-pre-mode-switcher.md](11-crt-mode-pre-mode-switcher.md) (post-reboot CRT, **480i** landed; same filename pattern as **02** / **07**). Pre-fix ladder ends at **10**; no pre-fix **11** file.

## Reference

- [06-mode-switcher-hd-to-crt-pre-reboot.md](06-mode-switcher-hd-to-crt-pre-reboot.md)  
- [09-hd-mode-pre-mode-switcher.md](09-hd-mode-pre-mode-switcher.md)  
- [09A-boot-resolution-reprompt-after-crt-to-hd-save.md](09A-boot-resolution-reprompt-after-crt-to-hd-save.md)  
- [../pre-fix/10-mode-switcher-hd-to-crt-pre-reboot.md](../pre-fix/10-mode-switcher-hd-to-crt-pre-reboot.md)
