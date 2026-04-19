# 02 — CRT mode, pre mode switcher

**Date:** 2026-04-19 (capture time on device; session date 2026-04-18)  
**Host:** `batocera.local` (SSH)  
**Purpose:** Post-install CRT baseline **before** any HD↔CRT mode switcher round trip. Validates `generic_15.bin`, `BUILD_15KHz_Batocera.log`, and `xrandr` on a known-good AMD install (same run as [01-crt-script-pre-reboot.md](01-crt-script-pre-reboot.md)).

## Definition

- CRT Script v43 install completed and system rebooted.
- Single **X11** session, CRT on **DP-1**.
- **No** HD Mode / CRT Mode switcher transition exercised in this phase (fresh CRT profile only).
- **Scope:** X11-only. “HD mode” elsewhere in the project can mean Wayland dual-boot; **this session does not** test that. Here, CRT mode is **15 kHz CRT on X11** before any HDMI-focused switcher step.

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

## Captured output

### Version

```
43ov 2026/04/07 09:23
```

([Inference] Leading `43ov` may be display or copy artifact; build matches prior `43 2026/04/07 09:23`.)

### `generic_15.bin`

```
File: /lib/firmware/edid/generic_15.bin
Size: 128
Modify: 2026-04-19 01:25:00.000000000 +0200
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

**Interpretation:** Native matrix choice **768×576@25** → pre-bump **769** for EDID generation; **not** `switchres 1280 …` (superres branch). `IFE=1` matches **DCN** parity path in v43.

### `edid-decode` (head)

- Preferred detailed timing: **769×1152i** @ ~24.97 Hz, **15.641 kHz** horizontal.
- Product name: **`generic_15`**
- Serial string: `Switchres200`
- Physical size reported: **485 mm × 364 mm** (DTD block)
- Analog display / RGB characteristics present in base block.

### `xrandr` (CRT output)

```
Screen 0: minimum 320 x 200, current 769 x 576, maximum 16384 x 16384
DP-1 connected primary 769x576+0+0 (...) 485mm x 364mm
   769x576i      49.97 +
   769x576       50.00*
```

Active mode: **769×576 @ 50 Hz** (progressive line marked `*`).

### `videomodes.conf` (head)

First lines use **15KHz** mode naming and `240x240.60.00001` style keys (consistent with **Amd_NvidiaND_IntelDP** pack), not a `1280x*` superres-first list.

## Findings

| Check | Result |
|-------|--------|
| Wrong superres matrix (`1280` in `EDID build:`) | **Not observed** — build uses **769 576 25** |
| `TYPE_OF_CARD` in log | **AMD/ATI** |
| `Intel_Nvidia_NOUV` / superres branch | **No evidence** in grep excerpt |
| DCN / interlace parity | **IFE=1**, engine **DCN** |
| On-disk EDID mtime | After install (2026-04-19 01:25) |

## Comparison to tester report

Tester saw **1280×240**-style preferred EDID and suspected wrong **else** branch. **This AMD lab run** shows the **if** branch behavior end-to-end: menu native list (01), log `switchres 769 576 25`, and EDID name `generic_15` without 1280-wide DTD in the decoded head.

## Next

- **03-*.md:** After a deliberate **CRT↔HDMI (X11)** step via the mode switcher (or parallel to tester logs), re-check `edid-decode`, `BUILD` grep, and `xrandr` to see if anything regresses. Still **X11-only**, not Wayland dual-boot.

## Reference

- [00-v43-x11-first-boot.md](00-v43-x11-first-boot.md)
- [01-crt-script-pre-reboot.md](01-crt-script-pre-reboot.md)
