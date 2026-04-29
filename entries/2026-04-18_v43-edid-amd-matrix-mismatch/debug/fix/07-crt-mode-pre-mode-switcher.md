# 07 - CRT mode, pre mode switcher (after HD round trip, fix phase)

**Date:** 2026-04-19  
**Host:** `batocera.local` (`~/bin/ssh-batocera.sh`)  
**Scope:** X11-only ([../README.md](../README.md)).

## Definition

- **After reboot** following [06-mode-switcher-hd-to-crt-pre-reboot.md](06-mode-switcher-hd-to-crt-pre-reboot.md) (**target: crt** + save, then reboot).
- CRT live on **DP-1** with **`769x576.50.00053`** in **`batocera.conf`** ( **`Boot_576i`** class).
- **Before** another mode switcher action: second CRT baseline vs [02-crt-mode-pre-mode-switcher.md](02-crt-mode-pre-mode-switcher.md).

## Commands run

```bash
batocera-version
grep -n 'global.video' /userdata/system/batocera.conf
grep -n 'global.videomode' /userdata/system/batocera.conf
DISPLAY=:0.0 xrandr | head -25
cat /userdata/system/logs/BootRes.log
grep -E 'EDID build|Parity decision|EDID PRE-bump|Mode switch|Config check|Saving selections' \
  /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -40
stat /lib/firmware/edid/generic_15.bin
edid-decode /lib/firmware/edid/generic_15.bin | head -45
```

Extra (same session): **`grep … videomode` / `grep … videooutput`** separately (clearer than **`global.video`** alone); **`cat /proc/cmdline`**; **`grep drm.edid_firmware`** on three syslinux paths; **`head -5 videomodes.conf`**.

## Captured output

### batocera-version

```
43ov 2026/04/07 09:23
```

([Inference] Treat as Batocera **43** if the `ov` suffix is a terminal artifact.)

### `batocera.conf` (video)

```
384:global.videomode=769x576.50.00053
385:global.videooutput=DP-1
```

### `xrandr` (head)

```
Screen 0: minimum 320 x 200, current 769 x 576, maximum 16384 x 16384
DP-1 connected primary 769x576+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   769x576i      49.97 +
   769x576       50.00*
```

Active: **769×576 @ 50 Hz** progressive (`*`).

### `BootRes.log`

```
Monitor Type: generic_15
Boot Resolution: 768x576@25
```

### `BUILD_15KHz_Batocera.log` (filtered tail)

```
Parity decision: interlace_force_even=1 (engine=DCN)
DEBUG: EDID PRE-bump applied; EDID will be generated at 769x576
EDID build: switchres 769 576 25 -f 769x576@25 -i switchres.ini -e  (IFE=1, engine=DCN)
DEBUG: EDID post-adjust check -> TYPE_OF_CARD='AMD/ATI' (norm='AMD/ATI'), Drivers_Nvidia_CHOICE='NONE' (norm='NONE'), H_RES_EDID(before)=769
[18:53:32]: Mode switch UI started for target: hd
[18:53:32]: Config check - HD: , CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[18:53:40]: Saving selections - HD: HDMI-2, CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[18:53:40]: Mode switch UI completed successfully
[18:57:51]: Mode switch UI started for target: crt
[18:57:51]: Config check - HD: HDMI-2, CRT: DP-1, Boot: 
[18:57:59]: Saving selections - HD: HDMI-2, CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[18:57:59]: Mode switch UI completed successfully
```

**EDID build** remains **`switchres 769 576 25`** (not **`1280`**).

### `/lib/firmware/edid/generic_15.bin` (stat)

```
Size: 128
Modify: 2026-04-19 10:50:07.000000000 -0600
```

( **`Birth`** / **`Change`** lines in raw capture reflect current view; **Modify** matches install-generation time.)

### `edid-decode` (head)

Same class as [02](02-crt-mode-pre-mode-switcher.md): **DTD 1: 769×1152i** ~24.97 Hz, **15.641 kHz**, product **`generic_15`**, serial **`Switchres200`**, **485 mm × 364 mm**.

### `/proc/cmdline`

```
... drm.edid_firmware=DP-1:edid/generic_15.bin video=DP-1:e ...
```

### Syslinux (**`drm.edid_firmware`** present on)

- **`/boot/boot/syslinux/syslinux.cfg`**
- **`/boot/EFI/batocera/syslinux.cfg`**
- **`/boot/EFI/syslinux.cfg`**

### `videomodes.conf` (head)

```
240x240.60.00001:240x240 1.0:0:0 15KHz 60Hz
256x192.60.00002:256x192 1.0:0:0 15KHz 60Hz
...
```

15 kHz pack style; no **`1280x*`** at top.

## Comparison: 07 vs 02 (fix phase)

| Item | [02](02-crt-mode-pre-mode-switcher.md) (first CRT) | **07** (CRT after HD then CRT) |
|------|----------------------------------|--------------------------------|
| **`EDID build:`** | **769 576 25** | **769 576 25** |
| **`TYPE_OF_CARD`** (post line) | **AMD/ATI** | **AMD/ATI** |
| **`generic_15.bin`** | 128 bytes | 128 bytes |
| **`xrandr`** | **769×576** on **DP-1**, `50.00*` | Same pattern |
| Path | Post-install reboot | + mode switcher **hd** then **crt** ([06](06-mode-switcher-hd-to-crt-pre-reboot.md)) + reboot |

No **`1280×`** superres branch in **`EDID build`** on this lab path after the round trip.

## Next

- **08:** [08-mode-switcher-crt-to-hd-pre-reboot.md](08-mode-switcher-crt-to-hd-pre-reboot.md) (2nd CRT→HD pre-reboot). Twin: [pre-fix 08](../pre-fix/08-mode-switcher-crt-to-hd-pre-reboot.md).

## Reference

- [02-crt-mode-pre-mode-switcher.md](02-crt-mode-pre-mode-switcher.md)  
- [06-mode-switcher-hd-to-crt-pre-reboot.md](06-mode-switcher-hd-to-crt-pre-reboot.md)  
- [../pre-fix/07-crt-mode-pre-mode-switcher.md](../pre-fix/07-crt-mode-pre-mode-switcher.md)
