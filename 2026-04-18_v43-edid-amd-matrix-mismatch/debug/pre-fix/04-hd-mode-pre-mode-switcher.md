# 04 — HD mode, pre mode switcher

**Date:** 2026-04-19 (capture)  
**Host:** `batocera.local` (SSH)  
**Purpose:** **X11** session with **HDMI desktop** as primary (**HD mode**), **before** any **CRT↔HDMI** mode switcher action back toward CRT. Follows reboot after [03-mode-switcher-crt-to-hd-pre-reboot.md](03-mode-switcher-crt-to-hd-pre-reboot.md).

## Definition

- `global.videooutput=HDMI-2`, `global.videomode=default` (same lines as pre-reboot in 03; now applied after reboot).
- **Not** Wayland; **not** dual-kernel PR #395 path.
- **No** mode switcher run yet in this phase (baseline for “desktop on HDMI” before switching back to CRT for round-trip tests).

## Commands run

```bash
batocera-version
grep -n 'global.video' /userdata/system/batocera.conf
grep -n 'global.videomode' /userdata/system/batocera.conf
DISPLAY=:0.0 xrandr
grep -A2 'MENU DEFAULT' /boot/boot/syslinux/syslinux.cfg | head -20
stat /lib/firmware/edid/generic_15.bin
tail -40 /userdata/system/logs/display.log
```

## Captured output

### Version

```
43 2026/04/07 09:23
```

### `batocera.conf` (video)

```
384:global.videooutput2=none
385:global.videooutput=HDMI-2
386:global.videomode=default
```

### `xrandr` (summary)

- **Screen:** current **3440 × 1440** (desktop on ultrawide).
- **DP-1:** connected, **not** primary; modes list includes CRT-capable timings (CRT still attached).
- **HDMI-2:** **connected primary** **3440×1440+0+0**, preferred **3440×1440 @ 59.97** (`*+`).

### `syslinux` (default entry)

`APPEND` still includes:

```
drm.edid_firmware=DP-1:edid/generic_15.bin video=DP-1:e
```

Kernel cmdline continues to load CRT EDID for **DP-1** even while ES/X11 is using **HDMI-2** as primary (same pattern as 03).

### `/lib/firmware/edid/generic_15.bin`

```
stat: cannot statx '/lib/firmware/edid/generic_15.bin': No such file or directory
```

[Inference] Path may differ by overlay mount, or file not merged into current root view in HD boot; **02** had the file after CRT-focused boot. Worth re-checking from CRT boot or `ls /lib/firmware/edid/` when comparing to tester’s reinstall scenario.

### `display.log` (tail)

- Splash targets **HDMI-2**; DRM connector **HDMI-A-2**.
- `Checker: Explicit video outputs configured ( HDMI-2 none)` — note **`global.videooutput2=none`** in conf; log shows `Invalid output - none` during validation (harmless if primary is correct).
- `set user output: HDMI-2 as primary`
- `setMode: default` on **HDMI-2**

## Findings

| Check | Result |
|-------|--------|
| Primary output | **HDMI-2** @ **3440×1440** |
| CRT **DP-1** | Still **connected**, non-primary |
| `syslinux` CRT EDID params | Still present on **DP-1** |
| `generic_15.bin` at stat path | **Missing** in this capture (see inference above) |

## Next

- **05-*.md:** After **HD→CRT** via mode switcher (or reinstall), compare EDID matrix / `BUILD` log / `edid-decode` to **02** and to tester report.

## Reference

- [03-mode-switcher-crt-to-hd-pre-reboot.md](03-mode-switcher-crt-to-hd-pre-reboot.md)
- [02-crt-mode-pre-mode-switcher.md](02-crt-mode-pre-mode-switcher.md)
