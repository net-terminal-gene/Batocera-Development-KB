# Design — CRT Installer: Bootstrap global.videomode and global.videooutput

## Key Insight: Installer Always Runs from HD Mode

The CRT Script always runs from standard Batocera (HD mode). This is a guarantee — you cannot be in CRT mode to install CRT mode. This means at install time:

- The current `batocera.conf` reflects the user's HD state
- We can read and save HD values before overwriting them
- We know the target CRT output and profile (just selected in the wizard)

This is the only moment in the system lifecycle where both HD and CRT state are simultaneously known.

## Install-Time Flow (New)

```
Installer wizard completes
  ├─ $video_output_xrandr = user's chosen CRT output (e.g. "DP-1")
  ├─ $monitor_profile     = user's chosen profile (e.g. 15kHz PAL 768x576)
  │
  ├─ Step 1: Read current HD state from batocera.conf
  │    existing_hd_videomode  = batocera-settings-get global.videomode  → "CEA 4 HDMI" | "" | "default"
  │    existing_hd_videooutput = batocera-settings-get global.videooutput → "eDP-1" | ""
  │
  ├─ Step 2: Write HD backup (mode switcher reads these on CRT→HD)
  │    MODE_BACKUP_DIR/hd_mode/video_settings/video_mode.txt   ← existing or "default"
  │    MODE_BACKUP_DIR/hd_mode/video_settings/video_output.txt ← existing or ""
  │
  ├─ Step 3: Derive CRT Boot_ mode name
  │    Option A: batocera-resolution listModes | grep "^Boot_" | grep <resolution_tag>
  │    Option B: static mapping from installer choice
  │              768x576 + 15kHz + 50Hz → "Boot_576i 1.0:0:0 15KHz 50Hz"
  │              640x480 + 15kHz + 60Hz → "Boot_480i 1.0:0:0 15KHz 60Hz"
  │              640x480 + 31kHz + 60Hz → "Boot_480i 1.0:0:0 31KHz 60Hz"
  │
  ├─ Step 4: Write CRT values to batocera.conf
  │    global.videooutput=$video_output_xrandr
  │    global.videomode=$crt_boot_mode
  │
  └─ Step 5: Write CRT backup (mode switcher reads these on HD→CRT)
       MODE_BACKUP_DIR/crt_mode/video_settings/video_mode.txt   ← $crt_boot_mode
       MODE_BACKUP_DIR/crt_mode/video_settings/video_output.txt ← $video_output_xrandr
```

## Mode Switcher Flow (After Bootstrap)

```
First CRT→HD switch
  ├─ backup_mode_files("crt")   → saves current CRT batocera.conf (already correct)
  ├─ restore_mode_files("hd")
  │    restore video_mode.txt   → writes "default" (or user's prior HD value)
  │    restore video_output.txt → writes "" or user's prior HD output
  └─ No re-pick needed — all backup files exist from install

First HD→CRT switch
  ├─ backup_mode_files("hd")   → saves current HD batocera.conf
  ├─ restore_mode_files("crt")
  │    restore video_mode.txt   → writes Boot_576i... (correct, full precision)
  │    restore video_output.txt → writes DP-1
  └─ No truncation possible — value came from installer, not from batocera-resolution currentMode
```

## Why listModes Over Static Mapping

`batocera-resolution listModes` is preferred because:
- It reads the actual installed `videomodes.conf` — guaranteed to match what ES shows
- It's self-correcting if the mode name format ever changes
- It uses the same lookup path as ES itself

Static mapping is the fallback if `batocera-resolution` is unavailable (SSH-only install, no DISPLAY).

## Ordering Constraint

Steps 1–2 (read + save HD) MUST run before Steps 4–5 (write CRT to batocera.conf). Otherwise the HD backup would capture the CRT values just written.
