# 12 - Mode switcher CRT to HD, pre-reboot (third pass, fix phase)

**Date:** 2026-04-19  
**Host:** `batocera.local` (`~/bin/ssh-batocera.sh`)  
**Scope:** X11-only ([../README.md](../README.md)).

## Definition

- **Third** **CRT to HD** via mode switcher (**`target: hd`**), **after** [11-crt-mode-pre-mode-switcher.md](11-crt-mode-pre-mode-switcher.md) (**480i** CRT baseline) **with** [09A](09A-boot-resolution-reprompt-after-crt-to-hd-save.md) **sidecar** deployed in **`02_hd_output_selection.sh`** on the device.
- **Pre-reboot:** **`batocera.conf`** already **HDMI-2** + **`videomode=default`**; **live** session still **CRT-primary** on **DP-1** (**641×480**) until reboot.

Same filename pattern as [08-mode-switcher-crt-to-hd-pre-reboot.md](08-mode-switcher-crt-to-hd-pre-reboot.md) (CRT→HD pre-reboot slug).

## Commands run

```bash
batocera-version
grep -n global.videooutput /userdata/system/batocera.conf
grep -n global.videomode /userdata/system/batocera.conf
DISPLAY=:0.0 xrandr | head -24
grep APPEND /boot/boot/syslinux/syslinux.cfg /boot/EFI/batocera/syslinux.cfg /boot/EFI/syslinux.cfg
cat /proc/cmdline
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/video_output.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_output.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_mode.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/crt_boot_display.txt
grep -F '11:27' /userdata/system/logs/BUILD_15KHz_Batocera.log
grep -F '11:39' /userdata/system/logs/BUILD_15KHz_Batocera.log
grep -F '11:40' /userdata/system/logs/BUILD_15KHz_Batocera.log
tail -20 /userdata/system/logs/display.log
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

### `DISPLAY=:0.0 xrandr` (head)

```
Screen 0: minimum 320 x 200, current 641 x 480, maximum 16384 x 16384
DP-1 connected primary 641x480+0+0 ...
   769x576i      49.97 +
   641x480       60.00* 
```

**Live** still **DP-1** primary **641×480**; **reboot pending** for **HDMI-2** desktop.

### `APPEND` (all three paths)

**Vanilla** (no **`drm.edid_firmware`**, no **`video=DP-1:e`**) on **`/boot/boot/syslinux/syslinux.cfg`**, **`/boot/EFI/batocera/syslinux.cfg`**, **`/boot/EFI/syslinux.cfg`**.

### `/proc/cmdline` (this boot)

Still **CRT** boot params:

```
... drm.edid_firmware=DP-1:edid/generic_15.bin video=DP-1:e ...
```

### `mode_backups/` (`video_settings`)

| File | Content |
|------|---------|
| `hd_mode/.../video_output.txt` | `global.videooutput=HDMI-2` |
| `crt_mode/.../video_output.txt` | `global.videooutput=DP-1` |
| `crt_mode/.../video_mode.txt` | `global.videomode=641x480.60.00` (**`currentMode`** string after sync; note **truncated** vs canonical **`641x480.60.00052`** in earlier steps) |
| **`crt_mode/.../crt_boot_display.txt`** | **`Boot_480i 1.0:0:0 15KHz 60Hz`** (**sidecar retained** full **`Boot_`** label) |

### `BUILD_15KHz_Batocera.log` (**09A** validation)

**First `target: hd` open after sidecar present** (boot **recognized** without re-picking **`Boot_480i`**):

```
[11:27:51]: Mode switch UI started for target: hd
[11:27:51]: Config check - HD: HDMI-2, CRT: DP-1, Boot: Boot_480i 1.0:0:0 15KHz 60Hz
[11:27:51]: Needs - HD: false, CRT: false, Boot: false, All configured: true
```

Second open (same session / user returned to menu):

```
[11:39:53]: Mode switch UI started for target: hd
[11:39:53]: Config check - HD: HDMI-2, CRT: DP-1, Boot: Boot_480i 1.0:0:0 15KHz 60Hz
[11:39:53]: Needs - HD: false, CRT: false, Boot: false, All configured: true
```

**Save completion** (synced **`video_mode`** + **sidecar** log):

```
[11:40:02]: Saving selections - HD: HDMI-2, CRT: DP-1, Boot: Boot_480i 1.0:0:0 15KHz 60Hz
[11:40:02]: Converting boot mode - input: 'Boot_480i 1.0:0:0 15KHz 60Hz', output: '641x480.60.00052'
[11:40:02]: Saved synced CRT mode: 641x480.60.00 (from currentMode, display: Boot_480i 1.0:0:0 15KHz 60Hz)
[11:40:02]: Saved CRT boot display name (crt_boot_display.txt sidecar)
[11:40:02]: Mode switch UI completed successfully
```

Then **`03`** **HD** restore block (syslinux to HD, **`es.resolution=default`**, etc.) follows in the same minute.

### `display.log` (tail)

Still **DP-1**, **`setMode: 641x480.60.00`** (pre-reboot **CRT** stack).

## Findings

| Check | Result |
|-------|--------|
| **`Boot:`** in **`Config check`** with **`video_mode.txt`** = **`641x480.60.00`** (non-mappable id vs **`videomodes.conf`**) | **Filled** with **`Boot_480i …`** from **`crt_boot_display.txt`** (**09A** fix verified on device). |
| **`Saved synced CRT mode`** still runs | **Yes**; **sidecar** written **after** so **`Boot_`** label **persists** for next **HD** session. |
| **On-disk `APPEND`** | **Vanilla** (HD next boot). |
| **`/proc/cmdline`** | Still **CRT** until reboot. |

## Comparison: **08** vs **12** (both CRT→HD pre-reboot)

| Item | [08](08-mode-switcher-crt-to-hd-pre-reboot.md) (2nd pass, **576i** era) | **12** (3rd pass, **480i** + sidecar) |
|------|--------------------------------|----------------------------------------|
| **`Boot:`** in **`Config check`** | **`HDMI-2`** filled (from **`mode_backups`**) | **`Boot_480i …`** filled (**sidecar** + backups) |
| **`crt_boot_display.txt`** | **Not present** yet | **`Boot_480i …`** present |
| **`video_mode.txt`** after save | **`769x576.49.97`** (synced) | **`641x480.60.00`** (synced) |

## Next

- **13:** [13-hd-mode-pre-mode-switcher.md](13-hd-mode-pre-mode-switcher.md) (3rd HD post-reboot). Same slug style as **04** / **09**.

## Reference

- [08-mode-switcher-crt-to-hd-pre-reboot.md](08-mode-switcher-crt-to-hd-pre-reboot.md)  
- [11-crt-mode-pre-mode-switcher.md](11-crt-mode-pre-mode-switcher.md)  
- [09A-boot-resolution-reprompt-after-crt-to-hd-save.md](09A-boot-resolution-reprompt-after-crt-to-hd-save.md)
