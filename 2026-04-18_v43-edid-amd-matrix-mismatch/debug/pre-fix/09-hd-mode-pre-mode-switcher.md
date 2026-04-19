# 09 — HD mode, pre mode switcher (second pass)

**Date:** 2026-04-19 (capture)  
**Host:** `batocera.local` (SSH)  
**Scope:** **X11-only** ([README](README.md)).

## Definition

- **After reboot** following [08-mode-switcher-crt-to-hd-pre-reboot.md](08-mode-switcher-crt-to-hd-pre-reboot.md) (second **CRT→HD** switcher completion).
- **HD mode:** **HDMI-2** desktop, **`videomode=default`**.
- **Before** another mode switcher action: parallels [04-hd-mode-pre-mode-switcher.md](04-hd-mode-pre-mode-switcher.md) (first HD baseline after install-driven path).

## Commands run

```bash
batocera-version
grep -n 'global.video' /userdata/system/batocera.conf
grep -n 'global.videomode' /userdata/system/batocera.conf
DISPLAY=:0.0 xrandr | head -22
grep 'APPEND' /boot/boot/syslinux/syslinux.cfg | head -2
stat /lib/firmware/edid/generic_15.bin
tail -30 /userdata/system/logs/display.log
```

## Captured output

### Version

```
43 2026/04/07 09:23
```

### `batocera.conf` (video)

```
384:global.videooutput=HDMI-2
385:global.videomode=default
392:global.videooutput2=none
```

### `xrandr` (head)

- **Screen:** current **3440 × 1440**.
- **DP-1:** connected, not primary.
- **HDMI-2:** **connected primary** **3440×1440+0+0**, preferred **3440×1440 @ 59.97** (`*+`).

### `syslinux` `APPEND`

```
... drm.edid_firmware=DP-1:edid/generic_15.bin video=DP-1:e
```

Same as [04](04-hd-mode-pre-mode-switcher.md): CRT EDID firmware still named for **DP-1** on kernel cmdline while runtime uses **HDMI-2**.

### `/lib/firmware/edid/generic_15.bin`

```
stat: cannot statx '/lib/firmware/edid/generic_15.bin': No such file or directory
```

Same observation as [04](04-hd-mode-pre-mode-switcher.md): path not visible in this root view during HD boot; CRT session [02](02-crt-mode-pre-mode-switcher.md)/[07](07-crt-mode-pre-mode-switcher.md) had the file.

### `display.log` (tail)

- Splash / **HDMI-2** / DRM **HDMI-A-2**.
- `Explicit video outputs configured ( HDMI-2 none)` → **`Invalid output - none`** (see [04](04-hd-mode-pre-mode-switcher.md)).
- **`set user output: HDMI-2 as primary`**, **`setMode: default`** on **HDMI-2**.

## Comparison: 09 vs 04

| Item | [04](04-hd-mode-pre-mode-switcher.md) (first HD) | **09** (second HD) |
|------|--------------------------------|-------------------|
| Path | After [03](03-mode-switcher-crt-to-hd-pre-reboot.md) (first CRT→HD) | After [08](08-mode-switcher-crt-to-hd-pre-reboot.md) (second CRT→HD) |
| `videooutput` / `videomode` | HDMI-2 / default | Same |
| `xrandr` primary | 3440×1440 on HDMI-2 | Same |
| `stat generic_15.bin` | Failed at path | Failed at path |
| Syslinux `APPEND` | DP-1 EDID params | Same |

Functionally the same **HD desktop** snapshot; **09** confirms repeatability after the **07 → 08** loop.

## Next

- **10-*.md** (if needed): another **HD→CRT** pre-reboot, or jump to **re-run installer** test matrix for EDID bug.

## Reference

- [04-hd-mode-pre-mode-switcher.md](04-hd-mode-pre-mode-switcher.md)
- [08-mode-switcher-crt-to-hd-pre-reboot.md](08-mode-switcher-crt-to-hd-pre-reboot.md)
