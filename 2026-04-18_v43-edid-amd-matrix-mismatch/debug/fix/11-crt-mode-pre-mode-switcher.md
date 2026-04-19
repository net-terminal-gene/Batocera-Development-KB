# 11 - CRT mode, pre mode switcher (after 480i HD→CRT, fix phase)

**Date:** 2026-04-19  
**Host:** `batocera.local` (`~/bin/ssh-batocera.sh`)  
**Scope:** X11-only ([../README.md](../README.md)).

## Definition

- **After reboot** following [10-mode-switcher-hd-to-crt-pre-reboot.md](10-mode-switcher-hd-to-crt-pre-reboot.md) (**`Boot_480i`**, **`641x480.60.00052`**, then reboot).
- **CRT live** on **DP-1** at **641×480 @ 60 Hz** in **`xrandr`** (confirmed: **landed in 480i**).
- **Before** another mode switcher action: third CRT baseline, same style as [02-crt-mode-pre-mode-switcher.md](02-crt-mode-pre-mode-switcher.md) and [07-crt-mode-pre-mode-switcher.md](07-crt-mode-pre-mode-switcher.md).

There is **no** pre-fix **`11-*.md`**; this step extends the fix ladder only.

## Follow-up (at time of this capture)

The **`crt_boot_display.txt`** sidecar from [09A](09A-boot-resolution-reprompt-after-crt-to-hd-save.md) was **not yet on disk** in this snapshot (**`ls`** below has no **`crt_boot_display.txt`**). It was **implemented in `02_hd_output_selection.sh`** and **validated** in [12-mode-switcher-crt-to-hd-pre-reboot.md](12-mode-switcher-crt-to-hd-pre-reboot.md).

## Commands run

```bash
batocera-version
grep -n global.videomode /userdata/system/batocera.conf
grep -n global.videooutput /userdata/system/batocera.conf
grep -n es.resolution /userdata/system/batocera.conf | head -6
DISPLAY=:0.0 xrandr | head -28
cat /userdata/system/logs/BootRes.log
stat /lib/firmware/edid/generic_15.bin
edid-decode /lib/firmware/edid/generic_15.bin | head -50
cat /proc/cmdline
grep APPEND /boot/boot/syslinux/syslinux.cfg /boot/EFI/batocera/syslinux.cfg /boot/EFI/syslinux.cfg
head -6 /userdata/system/videomodes.conf
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_mode.txt
ls /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/
grep EDID /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -12
grep Parity /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -5
grep 'Mode switch' /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -6
```

## Captured output

### batocera-version

```
43ov 2026/04/07 09:23
```

([Inference] Treat as Batocera **43** if the **`ov`** suffix is a terminal artifact.)

### `batocera.conf` (video)

```
384:global.videomode=641x480.60.00052
385:global.videooutput=DP-1
386:es.resolution=641x480.60.00052
```

### `DISPLAY=:0.0 xrandr` (head)

```
Screen 0: minimum 320 x 200, current 641 x 480, maximum 16384 x 16384
DP-1 connected primary 641x480+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   769x576i      49.97 +
   641x480       60.00* 
```

**Active:** **641×480 @ 60.00** on **DP-1** primary (`*`). **769×576i** still listed (not active).

### `BootRes.log`

```
Monitor Type: generic_15
Boot Resolution: 768x576@25
```

**Note:** **`BootRes.log`** still reports the **768×576@25** installer-style line, while **`batocera.conf`** and **`xrandr`** show **480i-class** runtime. Treat **`BootRes`** as **not authoritative** for this post-switcher boot until you decide to align logging with **`global.videomode`**.

### `/lib/firmware/edid/generic_15.bin` (stat)

```
Size: 128
Modify: 2026-04-19 10:50:07.000000000 -0600
```

### `edid-decode` (head)

Same **generic_15** class as [02](02-crt-mode-pre-mode-switcher.md) / [07](07-crt-mode-pre-mode-switcher.md): **DTD 1: 769×1152i** ~24.97 Hz, **15.641 kHz**, product **`generic_15`**, serial **`Switchres200`**, **485 mm × 364 mm**.

### `/proc/cmdline`

```
... drm.edid_firmware=DP-1:edid/generic_15.bin video=DP-1:e ...
```

### Syslinux (**`drm.edid_firmware`** on)

- **`/boot/boot/syslinux/syslinux.cfg`**
- **`/boot/EFI/batocera/syslinux.cfg`**
- **`/boot/EFI/syslinux.cfg`**

### `videomodes.conf` (head)

```
240x240.60.00001:240x240 1.0:0:0 15KHz 60Hz
256x192.60.00002:256x192 1.0:0:0 15KHz 60Hz
...
```

### `mode_backups/crt_mode/video_settings/`

**`video_mode.txt`:** `global.videomode=641x480.60.00052`  
**Directory listing:** `available_modes.txt`, `available_outputs.txt`, `es_resolution.txt`, `video_mode.txt`, `video_output.txt`, `video_output2.txt`, `video_output3.txt` (no **`crt_boot_display.txt`** sidecar).

### `BUILD_15KHz_Batocera.log` (filtered tails)

**EDID:**

```
DEBUG: EDID PRE-bump applied; EDID will be generated at 769x576
EDID build: switchres 769 576 25 -f 769x576@25 -i switchres.ini -e  (IFE=1, engine=DCN)
DEBUG: EDID post-adjust check -> TYPE_OF_CARD='AMD/ATI' (norm='AMD/ATI'), Drivers_Nvidia_CHOICE='NONE' (norm='NONE'), H_RES_EDID(before)=769
```

**Parity:**

```
Parity decision: interlace_force_even=1 (engine=DCN)
```

**Mode switcher (recent):**

```
[19:16:51]: Mode switch UI completed successfully
```

(Older **`Mode switch UI started`** lines remain earlier in the file from the **10** ladder.)

## Comparison: **11** vs **02** vs **07** (fix phase)

| Item | [02](02-crt-mode-pre-mode-switcher.md) (first CRT) | [07](07-crt-mode-pre-mode-switcher.md) (CRT after 576i switch) | **11** (CRT after **480i** switch) |
|------|----------------------------------|--------------------------------|-------------------------------------|
| **`global.videomode`** | **769×576.50.00053** | **769×576.50.00053** | **641×480.60.00052** |
| **`xrandr` current** | **769×576** | **769×576** | **641×480** |
| **`EDID build:`** | **769 576 25** | **769 576 25** | **769 576 25** (unchanged profile path) |
| **`BootRes` line** | **768×576@25** | **768×576@25** | **768×576@25** (stale vs live **480i**) |

No **`1280×`** superres branch in **`EDID build`** in this capture.

## Next

- **12:** [12-mode-switcher-crt-to-hd-pre-reboot.md](12-mode-switcher-crt-to-hd-pre-reboot.md) (3rd **CRT→HD** pre-reboot; same filename pattern as **08**). **09A** sidecar validated on device in that capture.

## Reference

- [02-crt-mode-pre-mode-switcher.md](02-crt-mode-pre-mode-switcher.md)  
- [07-crt-mode-pre-mode-switcher.md](07-crt-mode-pre-mode-switcher.md)  
- [10-mode-switcher-hd-to-crt-pre-reboot.md](10-mode-switcher-hd-to-crt-pre-reboot.md)  
- [09A-boot-resolution-reprompt-after-crt-to-hd-save.md](09A-boot-resolution-reprompt-after-crt-to-hd-save.md)
