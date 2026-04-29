# 14 - Mode switcher HD to CRT, pre-reboot (third cycle, fix phase)

**Date:** 2026-04-19  
**Host:** `batocera.local` (`~/bin/ssh-batocera.sh`)  
**Scope:** X11-only ([../README.md](../README.md)).

## Observer note (Mikey)

**Third HD→CRT** after [13-hd-mode-pre-mode-switcher.md](13-hd-mode-pre-mode-switcher.md). **`Config check`** showed **`Boot: Boot_480i …` filled** and **`Needs … Boot: false`** (**no** **`Boot resolution selection started`**). This is the expected **09A** sidecar behavior on **HD→CRT**: **`crt_boot_display.txt`** supplies the **`Boot_`** label while **`video_mode.txt`** still holds a non-mappable synced id (**`641x480.60.00`** in **13**; here backups show full **`641x480.60.00052`** after **HD→CRT** save used **`Saved boot mode ID`**).

## Definition

- **HD→CRT** via mode switcher (**`target: crt`**), **before reboot** onto CRT-primary layout.
- Follows **13**; same slug pattern as [06-mode-switcher-hd-to-crt-pre-reboot.md](06-mode-switcher-hd-to-crt-pre-reboot.md) and [10-mode-switcher-hd-to-crt-pre-reboot.md](10-mode-switcher-hd-to-crt-pre-reboot.md).

## Commands run

```bash
batocera-version
grep -n global.videooutput /userdata/system/batocera.conf
grep -n global.videomode /userdata/system/batocera.conf
grep -n es.resolution /userdata/system/batocera.conf | head -6
DISPLAY=:0.0 xrandr | head -26
grep APPEND /boot/boot/syslinux/syslinux.cfg /boot/EFI/batocera/syslinux.cfg /boot/EFI/syslinux.cfg
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/video_output.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_output.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_mode.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/es_resolution.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/crt_boot_display.txt
grep 'Mode switch UI started' /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -6
grep -F '19:44' /userdata/system/logs/BUILD_15KHz_Batocera.log
grep -F '19:45:1' /userdata/system/logs/BUILD_15KHz_Batocera.log | head -20
```

## Captured output

### batocera-version

```
43ov 2026/04/07 09:23
```

([Inference] Treat as Batocera **43** if the **`ov`** suffix is a terminal artifact.)

### `batocera.conf` (video-related, pre-reboot CRT intent)

```
384:global.videomode=641x480.60.00052
385:global.videooutput=DP-1
386:es.resolution=641x480.60.00052
```

### `DISPLAY=:0.0 xrandr` (head)

- **Screen:** current **3440 × 1440**.
- **HDMI-2:** **connected primary** **3440×1440** (`*+`).
- **DP-1:** connected, **not** primary.

**Interpretation:** **userdata** already targets **CRT** (**480i** mode id); **live** stack still **HD** until reboot.

### `APPEND` (all three paths)

**CRT** **`drm.edid_firmware=DP-1:edid/generic_15.bin`** and **`video=DP-1:e`** on **`/boot/boot/syslinux/syslinux.cfg`**, **`/boot/EFI/batocera/syslinux.cfg`**, **`/boot/EFI/syslinux.cfg`**.

### `mode_backups/` (`video_settings`)

| File | Content |
|------|---------|
| `hd_mode/.../video_output.txt` | `global.videooutput=HDMI-2` |
| `crt_mode/.../video_output.txt` | `global.videooutput=DP-1` |
| `crt_mode/.../video_mode.txt` | `global.videomode=641x480.60.00052` |
| `crt_mode/.../es_resolution.txt` | `es.resolution=641x480.60.00052` |
| **`crt_mode/.../crt_boot_display.txt`** | **`Boot_480i 1.0:0:0 15KHz 60Hz`** |

### `BUILD_15KHz_Batocera.log` (**09A** on **HD→CRT**)

**`target: crt`** start (**Boot** already known, **no** boot picker):

```
[19:44:22]: Mode switch UI started for target: crt
[19:44:22]: Config check - HD: HDMI-2, CRT: DP-1, Boot: Boot_480i 1.0:0:0 15KHz 60Hz
[19:44:22]: Needs - HD: false, CRT: false, Boot: false, All configured: true
```

**Save** (from **HD**, **`Saved boot mode ID`** branch, not **`Saved synced CRT mode`**):

```
[19:45:10]: Saving selections - HD: HDMI-2, CRT: DP-1, Boot: Boot_480i 1.0:0:0 15KHz 60Hz
[19:45:10]: Converting boot mode - input: 'Boot_480i 1.0:0:0 15KHz 60Hz', output: '641x480.60.00052'
[19:45:10]: Saved boot mode ID: 641x480.60.00052 (display: Boot_480i 1.0:0:0 15KHz 60Hz)
[19:45:10]: Saved CRT boot display name (crt_boot_display.txt sidecar)
[19:45:10]: Mode switch UI completed successfully
```

Then **`03`** CRT restore (**`Using backed-up es.resolution=641x480.60.00052`** in tail capture).

### Absence of boot picker

No **`Boot resolution selection started`** line between **`19:44:22`** and **`19:45:10`**.

## Comparison: **10** vs **14** (both HD→CRT from **HD**)

| Item | [10](10-mode-switcher-hd-to-crt-pre-reboot.md) (pre-sidecar / stale **`video_mode`**) | **14** (post-**09A** + **12**/**13**) |
|------|--------------------------------|----------------------------------------|
| **`Boot:`** in **`Config check`** | **Empty** → boot picker | **`Boot_480i …`** filled, **`All configured: true`** |
| **User had to pick boot again** | **Yes** | **No** |

## Next

- **15** when ready: post-reboot CRT baseline (same slug as **02** / **07** / **11**: **`15-crt-mode-pre-mode-switcher.md`**), unless you stop the ladder here.

## Reference

- [10-mode-switcher-hd-to-crt-pre-reboot.md](10-mode-switcher-hd-to-crt-pre-reboot.md)  
- [13-hd-mode-pre-mode-switcher.md](13-hd-mode-pre-mode-switcher.md)  
- [09A-boot-resolution-reprompt-after-crt-to-hd-save.md](09A-boot-resolution-reprompt-after-crt-to-hd-save.md)
