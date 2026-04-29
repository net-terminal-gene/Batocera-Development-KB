# Design — CRT Mode Switcher: First-Run Pre-Selects eDP-1

## Architecture

The Mode Switcher reads the CRT output from one of these sources (priority TBD):

1. `mode_backups/crt_mode/video_settings/video_output.txt` — pre-populated backup file
2. `batocera-settings-get global.videooutput` — current batocera.conf value
3. xrandr active output detection — live system query

On first run, backup files are empty. The switcher falls back to source 2 (`global.videooutput`), which after install is still `eDP-1` (the Wayland/HD value the installer never clears).

## Fix Flow (Proposed)

```
Mode Switcher first run
  └── Read crt_mode backup → empty
      └── Fallback: read global.videooutput from batocera.conf → eDP-1 (WRONG)
          └── Should instead: query xrandr for active primary output → DP-1 (CORRECT)
```

Or, via bootstrap:

```
Phase 2 installer (before reboot)
  └── Write DP-1 to mode_backups/crt_mode/video_settings/video_output.txt
      └── Mode Switcher first run reads backup → DP-1 (CORRECT, no fallback needed)
```
