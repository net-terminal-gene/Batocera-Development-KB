# Debug 08 — Mode Switcher: HD→CRT Switch, Pre-Reboot

## Date: 2026-04-13

## Script Version

**CRT-Script-04-03** — original script WITHOUT videomode-bootstrap changes.

## Action

User ran the Mode Switcher from Wayland HD mode (DP-1 unplugged) and switched to CRT mode. System is pre-reboot — capturing state before CRT boot.

Note: DP-1 was unplugged for this test to avoid the xterm-on-extended-desktop bug (`2026-04-13_crt-mode-switcher-wayland-blank-screen`). Mode Switcher appeared correctly on eDP-1 and the switch was completed successfully.

## batocera.conf State (Post-Switch, Prepared for CRT Boot)

```
global.videomode   = 641x480.59.98       ← TRUNCATED: xrandr mode ID, not Boot_ name
global.videooutput = DP-1                ← CORRECT
es.resolution      = 641x480.59.98       ← restored from crt_mode backup
```

The mode switcher restored CRT values from `crt_mode/video_settings/`. `global.videooutput=DP-1` is correct. Both `global.videomode` and `es.resolution` were written as `641x480.59.98` — the plain xrandr mode ID captured in stage 06, NOT a Boot_ name.

## mode_backups State

### crt_mode/video_settings/ (unchanged from stage 06)

```
video_output.txt   = global.videooutput=DP-1          ← CORRECT (xrandr source)
video_mode.txt     = global.videomode=641x480.59.98   ← truncated xrandr ID (not Boot_)
```

### hd_mode/video_settings/ (captured on this switch)

```
video_output.txt   = global.videooutput=eDP-1         ← CORRECT
(no video_mode.txt — global.videomode was empty in HD mode)
```

### mode_metadata (crt_mode) — unchanged from stage 06

```
MODE=crt
TIMESTAMP=2026-04-13T09:03:54-06:00     ← original CRT→HD switch timestamp (NOT updated)
VIDEO_OUTPUT=eDP-1                       ← BUG: still reads batocera.conf, not xrandr
VIDEO_MODE=
MONITOR_PROFILE=
BACKUP_SIZE_BYTES=59206
BACKUP_FILES_COUNT=20
```

### mode_metadata (hd_mode) — newly captured on this HD→CRT switch

```
MODE=hd
TIMESTAMP=2026-04-13T09:23:17-06:00     ← timestamp of this HD→CRT switch
VIDEO_OUTPUT=eDP-1                       ← CORRECT for HD (batocera.conf source is right here)
VIDEO_MODE=
MONITOR_PROFILE=none
BACKUP_SIZE_BYTES=13974
BACKUP_FILES_COUNT=9
```

## Key Findings

### 1. Truncated videomode is written back to batocera.conf on restore

The mode switcher restores `global.videomode` from `crt_mode/video_settings/video_mode.txt`, which contains `641x480.59.98` (captured from xrandr in stage 06). This value is written to batocera.conf:

```
global.videomode=641x480.59.98
```

This is NOT a Boot_ name. The correct value would be `Boot_576i 1.0:0:0 15KHz 50Hz` (or equivalent). This is the **truncated videomode bug** — the original capture (stage 06) stored a plain xrandr mode ID, and now the restore propagates it.

From stage 05 we know `global.videomode` is NOT read by the X11 standalone display script (which uses `es.resolution` instead). So for display output purposes this may be harmless. But it is wrong and worth fixing.

### 2. es.resolution is also set to the truncated value

```
es.resolution=641x480.59.98
```

`es.resolution` was restored from the crt_mode backup alongside `global.videomode`. Same source, same truncated value. This is what EmulationStation will use to set its render resolution. Whether `641x480.59.98` resolves to the correct 640x480 mode in ES's mode lookup is unknown — needs verification on next CRT boot (stage 09).

### 3. crt_mode metadata is not updated on restore

The `crt_mode/mode_metadata.txt` still has the original `TIMESTAMP=09:03:54` from the CRT→HD switch (stage 06). The HD→CRT restore does not update it. This is expected behavior — the metadata represents when the CRT backup was created, not when it was last restored.

### 4. hd_mode metadata correctly captures this HD→CRT switch

`hd_mode/mode_metadata.txt` was written fresh at `09:23:17` during this HD→CRT switch. `VIDEO_OUTPUT=eDP-1` is correct here because batocera.conf had `global.videooutput=eDP-1` in HD mode. This is the one case where reading batocera.conf for VIDEO_OUTPUT gives the right answer.

### 5. global.videooutput=DP-1 correctly written

The CRT output was correctly restored to `DP-1`. This is the value from `crt_mode/video_settings/video_output.txt` (xrandr source). This is correct and will ensure the X11 standalone script routes to DP-1.

## Summary Table

| Setting | Value Written | Correct? | Source |
|---------|--------------|----------|--------|
| `global.videomode` | `641x480.59.98` | NO — should be Boot_ name | `crt_mode/video_settings/video_mode.txt` |
| `global.videooutput` | `DP-1` | YES | `crt_mode/video_settings/video_output.txt` |
| `es.resolution` | `641x480.59.98` | UNKNOWN — may work | `crt_mode/video_settings/video_mode.txt` |

## Next Stage

→ `09-crt-mode-post-hd-to-crt-reboot.md` — Power cycle and boot into CRT mode. Verify display output and ES resolution.
