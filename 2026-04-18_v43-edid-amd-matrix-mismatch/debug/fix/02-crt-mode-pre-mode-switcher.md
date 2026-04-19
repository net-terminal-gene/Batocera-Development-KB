# 02 - CRT mode, pre mode switcher (fix phase)

**Date:** 2026-04-19  
**Host:** `batocera.local` (`~/bin/ssh-batocera.sh`)  
**Purpose:** Same checkpoint as [pre-fix 02](../pre-fix/02-crt-mode-pre-mode-switcher.md): post-reboot CRT baseline **before** any HD↔CRT mode switcher round trip. Validates `generic_15.bin`, `BUILD_15KHz_Batocera.log`, and `xrandr` on the fix image (after [01](01-crt-script-pre-reboot.md)).

## Definition

- CRT Script v43 install completed and system rebooted.
- Single **X11** session; **DP-1** is CRT primary in the `xrandr` excerpt below.
- **No** HD / CRT mode switcher transition in this step yet.
- **Scope:** X11-only (not Wayland dual-boot).

## Commands run

```bash
batocera-version
stat /lib/firmware/edid/generic_15.bin
cat /userdata/system/logs/BootRes.log
grep -E 'EDID build|Parity decision|EDID PRE-bump|EDID post|Amd_NvidiaND|Intel_Nvidia|TYPE_OF_CARD|matrix|Monitor Type|Boot Resolution' \
  /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -60
edid-decode /lib/firmware/edid/generic_15.bin | head -55
DISPLAY=:0.0 xrandr | head -45
head -8 /userdata/system/videomodes.conf
```

Extra (same SSH session): `cat /proc/cmdline`, `TYPE_OF_CARD_DRIVERS.info`.

## Captured output

### batocera-version

```
43ov 2026/04/07 09:23
```

([Inference] Leading `43ov` may be a display or copy artifact; build is stock **43** from image date.)

### `generic_15.bin` (stat)

```
File: /lib/firmware/edid/generic_15.bin
Size: 128
Modify: 2026-04-19 18:50:07.000000000 +0200
Access: (0644/-rw-r--r--)
```

### `BootRes.log`

```
Monitor Type: generic_15
Boot Resolution: 768x576@25
```

### `BUILD_15KHz_Batocera.log` (filtered)

```
Parity decision: interlace_force_even=1 (engine=DCN)
DEBUG: EDID PRE-bump applied; EDID will be generated at 769x576
EDID build: switchres 769 576 25 -f 769x576@25 -i switchres.ini -e  (IFE=1, engine=DCN)
DEBUG: EDID post-adjust check -> TYPE_OF_CARD='AMD/ATI' (norm='AMD/ATI'), Drivers_Nvidia_CHOICE='NONE' (norm='NONE'), H_RES_EDID(before)=769
```

**Interpretation:** Native path: **768×576@25** choice, pre-bump **769**, **not** `switchres 1280 …`. **IFE=1**, **DCN**.

### `edid-decode` (head)

Hex + parsed block (truncated in log): **DTD 1: 769x1152i** ~24.97 Hz, **15.641 kHz**; product name **`generic_15`**; serial **`Switchres200`**; range **49-65 Hz V**, **15-15 kHz H**; physical **485 mm x 364 mm** on DTD.

### `xrandr` (head)

```
Screen 0: minimum 320 x 200, current 769 x 576, maximum 16384 x 16384
DP-1 connected primary 769x576+0+0 (normal left inverted right x axis y axis) 485mm x 364mm
   769x576i      49.97 +
   769x576       50.00*
```

Active: **769×576 @ 50 Hz** progressive (`*`).

### `videomodes.conf` (head)

```
240x240.60.00001:240x240 1.0:0:0 15KHz 60Hz
256x192.60.00002:256x192 1.0:0:0 15KHz 60Hz
...
```

15 kHz-style keys; **no** `1280x*` lead-in on these lines.

### `/proc/cmdline` (EDID-related)

```
... drm.edid_firmware=DP-1:edid/generic_15.bin video=DP-1:e ...
```

### `TYPE_OF_CARD_DRIVERS.info`

```
AMD/ATI
AMDGPU
```

## Findings

| Check | Result |
|-------|--------|
| Wrong superres matrix (`1280` in `EDID build:`) | **Not observed** |
| `TYPE_OF_CARD` in `BUILD` excerpt | **AMD/ATI** |
| DCN / parity | **IFE=1**, engine **DCN** |
| On-disk EDID mtime | **2026-04-19 18:50:07** (+0200) |
| Kernel loaded EDID params | **Yes** (`drm.edid_firmware` + `video=DP-1:e` on cmdline) |

## Next

- **03:** [03-mode-switcher-crt-to-hd-pre-reboot.md](03-mode-switcher-crt-to-hd-pre-reboot.md) (CRT→HD pre-reboot). Ladder twin: [pre-fix 03](../pre-fix/03-mode-switcher-crt-to-hd-pre-reboot.md).

## Reference

- [00-v43-x11-first-boot.md](00-v43-x11-first-boot.md)  
- [01-crt-script-pre-reboot.md](01-crt-script-pre-reboot.md)  
- [../pre-fix/02-crt-mode-pre-mode-switcher.md](../pre-fix/02-crt-mode-pre-mode-switcher.md)
