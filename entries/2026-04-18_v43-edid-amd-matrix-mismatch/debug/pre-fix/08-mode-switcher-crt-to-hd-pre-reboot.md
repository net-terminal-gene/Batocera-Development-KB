# 08 — Mode switcher CRT→HD, pre-reboot (second pass)

**Date:** 2026-04-19 (capture)  
**Host:** `batocera.local` (SSH)  
**Scope:** **X11-only** ([README](README.md)).

## Definition

- **Second** **CRT → HD** run via HD/CRT Mode Switcher (**target: hd**), **after** [07-crt-mode-pre-mode-switcher.md](07-crt-mode-pre-mode-switcher.md) (CRT stable post round trip).
- **Pre-reboot:** `batocera.conf` already points at **HDMI-2** + **`videomode=default`**; **live X** can still show **CRT** on **DP-1** until reboot.

Compare to first pass: [03-mode-switcher-crt-to-hd-pre-reboot.md](03-mode-switcher-crt-to-hd-pre-reboot.md) (CRT→HD when **`mode_backups/`** was not yet populated from a completed switcher save).

## Commands run

```bash
batocera-version
grep -n 'global.video' /userdata/system/batocera.conf
grep -n 'global.videomode' /userdata/system/batocera.conf
DISPLAY=:0.0 xrandr | head -22
grep 'APPEND' /boot/boot/syslinux/syslinux.cfg | head -3
cat .../mode_backups/hd_mode/video_settings/video_output.txt
cat .../mode_backups/crt_mode/video_settings/video_output.txt
grep -E 'Mode switch|Config check|Saving selections' /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -20
tail -25 /userdata/system/logs/display.log
```

## Captured output

### Version

```
43 2026/04/07 09:23
```

### `batocera.conf` (video-related)

```
384:global.videooutput=HDMI-2
385:global.videomode=default
392:global.videooutput2=none
```

### `xrandr` (head)

```
Screen 0: ... current 769 x 576 ...
DP-1 connected primary 769x576+0+0 ...
   ...
   769x576       50.00*
```

**Live session still CRT-primary** on **DP-1** at capture; reboot pending to land on **HDMI-2**

### `syslinux` `APPEND` (first lines)

```
APPEND ... drm.edid_firmware=DP-1:edid/generic_15.bin video=DP-1:e
```

Same pattern as [03](03-mode-switcher-crt-to-hd-pre-reboot.md): CRT EDID still on cmdline until next boot applies switcher overlay.

### `mode_backups/` (video_output)

```
global.videooutput=HDMI-2
global.videooutput=DP-1
```

### `BUILD_15KHz_Batocera.log` (mode switcher, tail)

Second **target: hd** run (timestamps **17:50:49**–**17:51:06**):

```
[17:50:49]: Mode switch UI started for target: hd
[17:50:49]: Config check - HD: HDMI-2, CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[17:51:06]: Saving selections - HD: HDMI-2, CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[17:51:06]: Mode switch UI completed successfully
```

**Contrast with first `target: hd`** in this log (**01:31:40**):

```
[01:31:40]: Config check - HD: , CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
```

On the **second** CRT→HD pass, **`HD:`** is already **`HDMI-2`** from **`mode_backups/`** (no empty HD slot). The wizard had **full** triple recognition without re-entering HD output from scratch.

### `display.log` (tail)

Still **DP-1** primary, **769×576 @ 50.00** (pre-reboot).

## Findings

| Item | First CRT→HD ([03](03-mode-switcher-crt-to-hd-pre-reboot.md)) | **08** (second CRT→HD) |
|------|--------------------------------|------------------------|
| `Config check` HD field | **Empty** (first `hd` save) | **HDMI-2** filled |
| `batocera.conf` at pre-reboot | HDMI-2 + default (from ES path in that session) | Same pattern |
| Live `xrandr` | Mixed / dual-head per capture | **DP-1** CRT still primary until reboot |

## Next

- **09-*.md:** Post-reboot **HD** session (second **HD mode** baseline), comparable to [04-hd-mode-pre-mode-switcher.md](04-hd-mode-pre-mode-switcher.md).

## Reference

- [03-mode-switcher-crt-to-hd-pre-reboot.md](03-mode-switcher-crt-to-hd-pre-reboot.md)
- [07-crt-mode-pre-mode-switcher.md](07-crt-mode-pre-mode-switcher.md)
