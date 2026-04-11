# VERDICT — Mode Switcher Truncated global.videomode

## Status: TBD

## Summary

The mode switcher saves a truncated mode ID (`769x576.50.00`) to `video_mode.txt`, which gets restored to `batocera.conf` as `global.videomode`. ES compares this against `batocera-resolution listModes` which uses full-precision IDs (`769x576.50.00060`) — no match found, so ES shows "Auto" in the Video Mode setting.

The "preserve existing backup" guard in `02_hd_output_selection.sh` (line 821) is the direct cause — it protects a stale truncated value instead of using the correctly resolved full-precision mode ID from `get_boot_mode_id()`.

## Root Causes

1. `batocera-resolution currentMode` returns empty in X11/CRT mode (DRM/Wayland tool), so the primary sync path never fires.
2. The "preserve existing" guard (line 821) blindly keeps the existing `video_mode.txt` value, even when a correct `$boot_mode_id` is available.
3. The initial `video_mode.txt` was written by `03_backup_restore.sh` from a `batocera.conf` value that had truncated precision.

## Changes Applied

| File | Change |
|------|--------|
| (pending) | `02_hd_output_selection.sh` — remove "preserve existing" guard, always write resolved `$boot_mode_id` |
