# 08 - Mode switcher CRT to HD, pre-reboot (second pass, fix phase)

**Date:** 2026-04-19  
**Host:** `batocera.local` (`~/bin/ssh-batocera.sh`)  
**Scope:** X11-only ([../README.md](../README.md)).

## Definition

- **Second** **CRT to HD** via mode switcher (**`target: hd`**), **after** [07-crt-mode-pre-mode-switcher.md](07-crt-mode-pre-mode-switcher.md).
- **Pre-reboot:** **`batocera.conf`** already **HDMI-2** + **`videomode=default`**; **live** session can still show **CRT** on **DP-1** until reboot.

Compare first pass: [03-mode-switcher-crt-to-hd-pre-reboot.md](03-mode-switcher-crt-to-hd-pre-reboot.md).

## Commands run

```bash
batocera-version
grep -n 'global.videooutput' /userdata/system/batocera.conf
grep -n 'global.videomode' /userdata/system/batocera.conf
DISPLAY=:0.0 xrandr | head -22
grep APPEND /boot/boot/syslinux/syslinux.cfg /boot/EFI/batocera/syslinux.cfg /boot/EFI/syslinux.cfg
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/video_output.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_output.txt
grep -E 'Mode switch|Config check|Saving selections' /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -25
tail -25 /userdata/system/logs/display.log
```

Extra: **`cat /proc/cmdline`** (same SSH session).

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

(Plus commented **`#global.videomode`** / **`#global.videooutput`** lines elsewhere in file.)

### `xrandr` (head)

```
Screen 0: minimum 320 x 200, current 769 x 576, maximum 16384 x 16384
DP-1 connected primary 769x576+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   769x576i      49.97*+
   769x576       50.00  
```

**Live** stack still **CRT-primary** on **DP-1** at capture; **reboot pending** for **HDMI-2** desktop.

### `APPEND` (all three paths)

**Vanilla** (no **`drm.edid_firmware`**, no **`video=DP-1:e`**) on:

- **`/boot/boot/syslinux/syslinux.cfg`**
- **`/boot/EFI/batocera/syslinux.cfg`**
- **`/boot/EFI/syslinux.cfg`**

Same **on-disk** pattern as [03](03-mode-switcher-crt-to-hd-pre-reboot.md) after HD restore in this ladder: **HD** config already propagated to **all** checked locations **before** reboot.

### `/proc/cmdline` (this boot, unchanged until reboot)

```
... drm.edid_firmware=DP-1:edid/generic_15.bin video=DP-1:e ...
```

Still the **CRT boot** cmdline from the prior reboot (**07**); **next** boot will pick up the **vanilla** **`APPEND`** on disk.

### `mode_backups/` (`video_output.txt`)

**`hd_mode`:** `global.videooutput=HDMI-2`  
**`crt_mode`:** `global.videooutput=DP-1`

### `BUILD_15KHz_Batocera.log` (mode switcher, tail)

First **`target: hd`** in this file (from earlier in the same day):

```
[18:53:32]: Mode switch UI started for target: hd
[18:53:32]: Config check - HD: , CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[18:53:40]: Saving selections - HD: HDMI-2, CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
```

**Second** **`target: hd`** (this step):

```
[11:03:07]: Mode switch UI started for target: hd
[11:03:07]: Config check - HD: HDMI-2, CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[11:03:18]: Saving selections - HD: HDMI-2, CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[11:03:18]: Mode switch UI completed successfully
```

**Contrast:** second pass **`Config check`** already shows **`HD: HDMI-2`** (from **`mode_backups/`**), not an empty **HD** slot like the first **`target: hd`**.

### `display.log` (tail)

Still **DP-1** primary, **`setMode: 769x576.50.00`** on **DP-1** (pre-reboot).

## Findings

| Item | First CRT→HD [03](03-mode-switcher-crt-to-hd-pre-reboot.md) | **08** (second CRT→HD) |
|------|--------------------------------|------------------------|
| **`Config check` HD field** | **Empty** on first **`target: hd`** | **`HDMI-2`** already filled |
| **`batocera.conf`** pre-reboot | **HDMI-2** + **default** | **Same** |
| **On-disk `APPEND`** | **Vanilla** (fix **03** capture) | **Vanilla** |
| **`/proc/cmdline`** | Still had **CRT EDID** before that reboot | Still **CRT EDID** (this boot not rebooted yet) |
| **Live `xrandr`** | **DP-1** CRT until reboot | **DP-1** CRT until reboot |

## Next

- **09:** [09-hd-mode-pre-mode-switcher.md](09-hd-mode-pre-mode-switcher.md) (2nd HD post-reboot). Twin: [pre-fix 09](../pre-fix/09-hd-mode-pre-mode-switcher.md).

## Reference

- [03-mode-switcher-crt-to-hd-pre-reboot.md](03-mode-switcher-crt-to-hd-pre-reboot.md)  
- [07-crt-mode-pre-mode-switcher.md](07-crt-mode-pre-mode-switcher.md)  
- [../pre-fix/08-mode-switcher-crt-to-hd-pre-reboot.md](../pre-fix/08-mode-switcher-crt-to-hd-pre-reboot.md)
