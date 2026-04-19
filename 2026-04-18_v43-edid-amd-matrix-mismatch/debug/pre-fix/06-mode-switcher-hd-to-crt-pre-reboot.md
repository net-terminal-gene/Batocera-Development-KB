# 06 — Mode switcher HD→CRT, pre-reboot

**Date:** 2026-04-19 (capture)  
**Host:** `batocera.local` (SSH)  
**Scope:** **X11-only** ([README](README.md)).

## Definition

- User completed **HD/CRT Mode Switcher** with target **CRT** (`Mode switch UI completed successfully`).
- **Before reboot:** `batocera.conf` may already list CRT output and CRT videomode; the **live** X session can still match **HD** (HDMI primary) until reboot applies the switch.

Follows [04-hd-mode-pre-mode-switcher.md](04-hd-mode-pre-mode-switcher.md) / [05-mode-switcher-hd-to-crt-no-boot-recognition.md](05-mode-switcher-hd-to-crt-no-boot-recognition.md).

## Commands run

```bash
batocera-version
grep -n 'global.video' /userdata/system/batocera.conf
grep -n 'global.videomode' /userdata/system/batocera.conf
DISPLAY=:0.0 xrandr | head -22
grep -A3 'MENU DEFAULT' /boot/boot/syslinux/syslinux.cfg | head -8
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/video_output.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_output.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_mode.txt
grep -E 'Mode switch|Config check|Saving selections|Converting boot' /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -30
```

## Captured output

### Version

```
43ov 2026/04/07 09:23
```

([Inference] Treat as Batocera **43** if the `ov` suffix is a terminal artifact.)

### `batocera.conf` (video-related)

```
384:global.videomode=769x576.50.00053
385:global.videooutput=DP-1
```

(`grep` for `global.videooutput2` not shown in this capture; may still be `none` elsewhere in file.)

### `xrandr` (head)

- **Screen** current **3440 × 1440** (still desktop-sized).
- **HDMI-2** **connected primary** **3440×1440+0+0** (`*+`).
- **DP-1** connected, **not** primary in this snapshot.

**Interpretation:** Pre-reboot, **userdata** already points at **CRT** (`DP-1`, mode ID **769x576.50.00053**); **display** has not yet switched to CRT as primary (still **HDMI-2** until reboot / display service restart).

### `syslinux` (default entry)

`APPEND` still includes:

```
drm.edid_firmware=DP-1:edid/generic_15.bin video=DP-1:e
```

### `mode_backups/` (video settings)

| File | Content |
|------|---------|
| `hd_mode/video_settings/video_output.txt` | `global.videooutput=HDMI-2` |
| `crt_mode/video_settings/video_output.txt` | `global.videooutput=DP-1` |
| `crt_mode/video_settings/video_mode.txt` | `global.videomode=769x576.50.00053` |

### `BUILD_15KHz_Batocera.log` (mode switcher excerpts)

```
[01:31:40]: Mode switch UI started for target: hd
[01:31:40]: Config check - HD: , CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[01:32:06]: Saving selections - HD: HDMI-2, CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[01:32:06]: Converting boot mode - input: 'Boot_576i 1.0:0:0 15KHz 50Hz', output: '769x576.50.00053'
[01:32:06]: Mode switch UI completed successfully
[01:40:29]: Mode switch UI started for target: crt
[01:40:29]: Config check - HD: HDMI-2, CRT: DP-1, Boot: 
[01:45:47]: Saving selections - HD: HDMI-2, CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[01:45:47]: Converting boot mode - input: 'Boot_576i 1.0:0:0 15KHz 50Hz', output: '769x576.50.00053'
[01:45:47]: Mode switch UI completed successfully
```

Note **`Config check`** for **`target: crt`** shows **`Boot:`** empty at the start of that run (`01:40:29`), matching [05](05-mode-switcher-hd-to-crt-no-boot-recognition.md) (`videomode=default` in HD mode); user re-selected **Boot_576i** before save.

## Findings

| Check | Result |
|-------|--------|
| `batocera.conf` | CRT-oriented: **DP-1**, **769x576.50.00053** |
| Live `xrandr` primary | Still **HDMI-2** / **3440×1440** (pre-reboot) |
| `mode_backups/` | **HD** and **CRT** slots populated |
| Syslinux | CRT EDID params on **DP-1** (unchanged pattern) |

## Next

- **07-*.md:** Post-reboot **CRT** session: `xrandr` on **DP-1**, compare to [02](02-crt-mode-pre-mode-switcher.md), EDID / `BUILD` if re-checking matrix.

## Reference

- [05-mode-switcher-hd-to-crt-no-boot-recognition.md](05-mode-switcher-hd-to-crt-no-boot-recognition.md)
- [03-mode-switcher-crt-to-hd-pre-reboot.md](03-mode-switcher-crt-to-hd-pre-reboot.md)
