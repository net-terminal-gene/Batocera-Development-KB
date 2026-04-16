# Debug 14 — Bootstrap Version: Mode Switcher CRT→HD Pre-Reboot

## Date: 2026-04-13

## Script Version

**v43.sh WITH full bootstrap (Insert A + B + C).**

## Action

User ran Mode Switcher from CRT mode and switched to HD. Capturing pre-reboot state.

## batocera.conf (Post-Switch, Prepared for HD Boot)

```
global.videomode   = 800x1280.59999   ← HD value restored from hd_mode backup
global.videooutput = eDP-1            ← correct for HD
es.resolution      = (empty)          ← cleared by mode switcher for HD mode
```

Note: `global.videomode=800x1280.59999` is the Steam Deck's native Wayland resolution key.
This was either present in batocera.conf before install (and captured by Insert A), or was
written by Batocera's Wayland setup. Either way the mode switcher correctly restored the HD state.

## mode_backups State

### crt_mode/video_settings/ (mode switcher overwrote bootstrap pre-seed on first run)

```
video_mode.txt   = global.videomode=641x480.59.98     ← xrandr preferred mode (overwritten by mode switcher)
video_output.txt = global.videooutput=DP-1            ← CORRECT (new prefix format from bootstrap)
```

The mode switcher overwrites the crt_mode backup on first CRT→HD switch with live xrandr values.
Our bootstrap pre-seed was replaced. `video_output.txt` format is now `global.videooutput=DP-1`
(correct prefix) because our Insert B pre-seeded it in the right format.

### hd_mode/video_settings/ (pre-seeded by bootstrap Insert A)

```
video_mode.txt   = global.videomode=default   ← captured at install (global.videomode was empty/default)
video_output.txt = global.videooutput=eDP-1  ← CORRECT (captured at install from batocera.conf)
```

## mode_metadata (crt_mode) — KEY FIX CONFIRMED

```
MODE=crt
TIMESTAMP=2026-04-13T20:54:14-06:00
BATOCERA_VERSION=43v 2026/04/01 18:32
VIDEO_OUTPUT=DP-1        ← FIXED — no longer eDP-1!
VIDEO_MODE=641x480.60.00
MONITOR_PROFILE=
BACKUP_SIZE_BYTES=59225
BACKUP_FILES_COUNT=20
```

**`VIDEO_OUTPUT=DP-1` is correct.** The eDP-1 first-run bug is fixed. Bootstrap wrote
`global.videooutput=DP-1` to batocera.conf before the first mode switcher run, so when the
mode switcher reads `global.videooutput` for metadata, it now gets `DP-1`.

## Summary of Bootstrap Improvements vs Baseline

| Issue | Baseline (CRT-Script-04-03) | Bootstrap version |
|-------|----------------------------|-------------------|
| ES Video Mode after install | AUTO | Boot_480i 1.0:0:0 15KHz 60Hz |
| mode_metadata VIDEO_OUTPUT | eDP-1 (wrong) | DP-1 (correct) |
| hd_mode backup at install | empty | pre-seeded with eDP-1 |
| crt_mode backup at install | empty | pre-seeded with DP-1 |
| global.videooutput in batocera.conf | eDP-1 (leftover) | DP-1 |

## Next Stage

→ `15-bootstrap-hd-mode-post-reboot.md` — Reboot into HD/Wayland, verify state.
