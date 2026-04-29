# Design — CRT Installer Missing global.videooutput

## Installer's batocera.conf Write Block

The installer appends CRT settings to `batocera.conf` starting at ~line 5357:

```bash
echo "global.videomode=$Resolution_es" >> "$file_BatoceraConf"     # line ~5358 (currently unused/broken)
echo "es.resolution=$Resolution_es" >> "$file_BatoceraConf"        # line ~5360
echo "es.customsargs=..." >> "$file_BatoceraConf"                  # line ~5371
```

### Proposed Change

Insert between the videomode and es.resolution lines:

```bash
echo "global.videooutput=$video_output_xrandr" >> "$file_BatoceraConf"
```

This ensures `batocera.conf` has the correct CRT output from installation, before any mode switcher cycle.

## Impact on Wayland Dual-Boot

```
Before fix:
  Factory batocera.conf (Wayland):
    global.videooutput=eDP-1     ← laptop internal screen
  After CRT Script install:
    global.videooutput=eDP-1     ← UNCHANGED
  → BLACK SCREEN on CRT

After fix:
  After CRT Script install:
    global.videooutput=DP-1      ← correct CRT output
  → ES displays on CRT immediately
```

## Mode Switcher es.resolution Fallback

`get_crt_boot_resolution()` in `02_hd_output_selection.sh` currently checks:
1. `global.videomode` in `batocera.conf`
2. `video_mode.txt` backup file

Both are empty on first run. Adding a fallback to check `es.resolution` from `batocera.conf` (which IS set by the installer) would allow the mode switcher to detect the pre-configured boot resolution and skip the boot resolution prompt.
