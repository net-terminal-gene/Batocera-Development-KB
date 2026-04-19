# 07 — CRT mode, pre mode switcher (after HD round trip)

**Date:** 2026-04-19 (capture)  
**Host:** `batocera.local` (SSH)  
**Scope:** **X11-only** ([README](README.md)).

## Definition

- **After reboot** following [06-mode-switcher-hd-to-crt-pre-reboot.md](06-mode-switcher-hd-to-crt-pre-reboot.md) (mode switcher **target: crt** + save, then reboot).
- CRT is live again on **DP-1** with **`Boot_576i`-class** videomode in `batocera.conf`.
- **Before** another HD/CRT mode switcher action: second **CRT baseline** to compare against [02-crt-mode-pre-mode-switcher.md](02-crt-mode-pre-mode-switcher.md) (fresh install only).

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

## Captured output

### Version

```
43ov 2026/04/07 09:23
```

### `batocera.conf` (video)

```
384:global.videomode=769x576.50.00053
385:global.videooutput=DP-1
```

### `xrandr` (head)

```
Screen 0: ... current 769 x 576 ...
DP-1 connected primary 769x576+0+0 ...
   ...
   769x576       50.00*
```

**HDMI-2** not in this excerpt; session is **CRT-primary** (matches intent of post–HD→CRT reboot).

### `BootRes.log`

```
Monitor Type: generic_15
Boot Resolution: 768x576@25
```

### `BUILD_15KHz_Batocera.log` (filtered tail)

Includes **EDID** lines (install-time) and **mode switcher** lines from the HD/CRT runs:

```
Parity decision: interlace_force_even=1 (engine=DCN)
DEBUG: EDID PRE-bump applied; EDID will be generated at 769x576
EDID build: switchres 769 576 25 -f 769x576@25 -i switchres.ini -e  (IFE=1, engine=DCN)
[01:31:40]: Mode switch UI started for target: hd
...
[01:45:47]: Mode switch UI completed successfully
```

**EDID build** still **`switchres 769 576 25`** (native path, not `1280`).

### `/lib/firmware/edid/generic_15.bin`

Present (128 bytes). Timestamps in capture show **Modify** 2026-04-18 17:25 (TZ -0600).

### `edid-decode` (head)

- Preferred DTD **769×1152i**, **generic_15** name, **485 mm × 364 mm** (same class of EDID as [02](02-crt-mode-pre-mode-switcher.md)).

## Comparison: 07 vs 02 (both CRT, pre switcher)

| Item | [02](02-crt-mode-pre-mode-switcher.md) (first CRT) | **07** (CRT after HD↔CRT) |
|------|--------------------------------|---------------------------|
| `EDID build:` | `switchres 769 576 25` | Same pattern in log |
| `TYPE_OF_CARD` / parity | AMD/ATI, IFE=1 DCN | Same EDID lines |
| `generic_15.bin` | Present | Present |
| `xrandr` active | 769×576 (50 Hz `*` in 02) | **769×576** @ **50.00** `*` (progressive in 07 head) |
| Path | Install only | Install + mode switcher **hd** then **crt** ([06](06-mode-switcher-hd-to-crt-pre-reboot.md)) |

No **1280×** superres branch observed in **EDID build** on this lab path after the round trip.

## Next

- Further **HD↔CRT** cycles: repeat **03–07** pattern if chasing tester’s “wrong matrix after reinstall” (their failure mode was **re-run installer**, not mode switcher alone).

## Reference

- [02-crt-mode-pre-mode-switcher.md](02-crt-mode-pre-mode-switcher.md)
- [06-mode-switcher-hd-to-crt-pre-reboot.md](06-mode-switcher-hd-to-crt-pre-reboot.md)
