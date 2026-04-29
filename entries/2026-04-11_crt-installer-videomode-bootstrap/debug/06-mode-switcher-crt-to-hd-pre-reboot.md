# Debug 06 — Mode Switcher: CRT→HD Switch, Pre-Reboot

## Date: 2026-04-13

## Script Version

**CRT-Script-04-03** — original script WITHOUT videomode-bootstrap changes. First-ever Mode Switcher run on this install.

## Action

User ran the Mode Switcher from CRT mode and switched to HD mode. System is pre-reboot — capturing state before the HD boot.

## batocera.conf State (Post-Switch, Prepared for HD Boot)

```
global.videomode   = (empty)
global.videooutput = eDP-1
es.resolution      = (empty)
```

The mode switcher restored HD values. `global.videooutput=eDP-1` is correct for HD. `global.videomode` is empty (was never set in CRT mode, HD backup had no mode file).

## mode_backups Created on First CRT→HD Switch

### crt_mode/video_settings/

```
video_output.txt   = global.videooutput=DP-1        ← CORRECT (read from xrandr active output)
video_mode.txt     = global.videomode=641x480.59.98  ← xrandr preferred/interlaced rate (NOT a Boot_ name)
available_outputs.txt = DP-1
```

### hd_mode/video_settings/

```
video_output.txt   = global.videooutput=eDP-1       ← CORRECT (read from batocera.conf)
(no video_mode.txt — global.videomode was empty, nothing to save)
```

### mode_metadata.txt (crt_mode)

```
MODE=crt
TIMESTAMP=2026-04-13T09:03:54-06:00
BATOCERA_VERSION=43v 2026/04/01 18:32
VIDEO_OUTPUT=eDP-1        ← BUG: reads batocera.conf (eDP-1), not xrandr (DP-1)
VIDEO_MODE=               ← empty (global.videomode was never set)
MONITOR_PROFILE=
BACKUP_SIZE_BYTES=59206
BACKUP_FILES_COUNT=20
```

## Key Findings

### 1. video_output.txt is correct; mode_metadata.txt is wrong

The mode switcher saves the CRT output in two places using different sources:

| File | Source | Value | Correct? |
|------|--------|-------|----------|
| `crt_mode/video_settings/video_output.txt` | xrandr active output | `DP-1` | YES |
| `crt_mode/mode_metadata.txt` `VIDEO_OUTPUT=` | `batocera-settings-get global.videooutput` | `eDP-1` | NO |

`video_output.txt` is what the mode switcher actually uses for restore operations. The metadata `VIDEO_OUTPUT` is informational/display only. So the restore itself will use DP-1 correctly — but the metadata display (what the user sees) shows eDP-1, which is the "eDP-1 was already picked for CRT Mode" bug reported.

### 2. video_mode.txt captures the xrandr preferred rate, not Boot_ name

```
global.videomode=641x480.59.98
```

The mode switcher reads xrandr output and captures the **preferred mode** (marked `+`) rather than the **active mode** (marked `*`):

```
xrandr output at time of switch:
  641x480i   59.98 +    ← preferred (interlaced) — this is what was saved
  641x480    60.00*     ← active (progressive, set by setMode)
```

The saved value `641x480.59.98` is NOT a Boot_ name. When the mode switcher restores CRT mode later, it will write `global.videomode=641x480.59.98` to batocera.conf. This is the **truncated videomode** problem: the value is a plain xrandr mode ID, not the Boot_ entry the system was configured to use.

However — from stage 05 we confirmed that `global.videomode` is NOT read by the standalone display script in X11 CRT mode (the mode comes from `es.resolution`). So this may be harmless for display purposes. Further testing needed.

### 3. hd_mode backup is minimal

Only `video_output.txt` was created in `hd_mode/video_settings/`. No `video_mode.txt` because `global.videomode` was empty. This is correct behavior for this install.

### 4. The eDP-1 first-run pre-selection bug confirmed

The `mode_metadata.txt` `VIDEO_OUTPUT=eDP-1` is what the Mode Switcher displayed to the user as the current CRT output on first run. Since `global.videooutput=eDP-1` was in batocera.conf (never changed by installer), the metadata recorded it as the CRT output — which is the bug filed in `2026-04-13_crt-mode-switcher-firstrun-output-bug`.

## Next Stage

→ `07-mode-switcher-hd-mode-live.md` — Reboot into HD mode, verify display, capture state.
