# 10 — Mode switcher HD→CRT, pre-reboot (second full cycle)

**Date:** 2026-04-19 (capture)  
**Host:** `batocera.local` (SSH)  
**Scope:** **X11-only** ([README](README.md)).

## Definition

- **HD→CRT** via mode switcher (**target: crt**) **after** [09-hd-mode-pre-mode-switcher.md](09-hd-mode-pre-mode-switcher.md) (second HD desktop session).
- **Pre-reboot:** `batocera.conf` already switched toward **CRT**; **live** session can still show **HDMI** until reboot.
- Compare to [06-mode-switcher-hd-to-crt-pre-reboot.md](06-mode-switcher-hd-to-crt-pre-reboot.md) (first HD→CRT after the initial **04** HD session).

## Observer note (Mikey)

**CRT Boot** is shown in the switcher this time, and **that matches expectations.** The first time you complete a switcher flow **from HD mode**, the tool writes **`crt_mode/video_settings/`** (including boot resolution) into **`mode_backups/`**. Once that exists, **`get_crt_boot_resolution()`** can resolve **`Boot_*`** from **backup** even when live **`batocera.conf`** has **`global.videomode=default`** in HD mode ([05](05-mode-switcher-hd-to-crt-no-boot-recognition.md)). So later **HD→CRT** runs can show **Boot** as **already known** instead of empty.

In short: you are not “losing” boot forever; the **first** full save (especially the first **target: hd** completion that persists the triple) is what seeds **settings** the wizard reads back.

## Commands run

```bash
grep -n 'global.video' /userdata/system/batocera.conf
grep -n 'global.videomode' /userdata/system/batocera.conf
DISPLAY=:0.0 xrandr | head -18
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_mode.txt
grep -E 'Mode switch|Config check|Saving selections|Converting boot' /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -25
```

## Captured output

### `batocera.conf` (pre-reboot, switched toward CRT)

```
384:global.videomode=769x576.50.00053
385:global.videooutput=DP-1
```

### `xrandr` (head)

**Screen** still **3440 × 1440**; **HDMI-2** primary **3440×1440** (`*+`). **DP-1** connected, not primary. Reboot pending for CRT-primary layout.

### `crt_mode` backup `video_mode.txt`

```
global.videomode=769x576.50.00053
```

### `BUILD_15KHz_Batocera.log` (latest `target: crt`)

```
[01:56:11]: Mode switch UI started for target: crt
[01:56:11]: Config check - HD: HDMI-2, CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[01:56:13]: Saving selections - HD: HDMI-2, CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[01:56:13]: Converting boot mode - input: 'Boot_576i 1.0:0:0 15KHz 50Hz', output: '769x576.50.00053'
[01:56:13]: Mode switch UI completed successfully
```

## Comparison: first vs second HD→CRT `Config check`

| Run | When | `Boot:` in `Config check` |
|-----|------|----------------------------|
| First HD→CRT | [06](06-mode-switcher-hd-to-crt-pre-reboot.md) `@01:40:29` | **Empty** (live HD had `videomode=default`) |
| **This run** | `@01:56:11` | **`Boot_576i 1.0:0:0 15KHz 50Hz`** populated |

After [08](08-mode-switcher-crt-to-hd-pre-reboot.md) / [09](09-hd-mode-pre-mode-switcher.md), **`Config check` for `target: hd`** already showed **Boot** filled (**17:50:49**). The pipeline had **mode_backups** in a good state, so **HD→CRT** could read boot without treating it as missing.

## Reference

- [05-mode-switcher-hd-to-crt-no-boot-recognition.md](05-mode-switcher-hd-to-crt-no-boot-recognition.md)
- [06-mode-switcher-hd-to-crt-pre-reboot.md](06-mode-switcher-hd-to-crt-pre-reboot.md)
- [09-hd-mode-pre-mode-switcher.md](09-hd-mode-pre-mode-switcher.md)
