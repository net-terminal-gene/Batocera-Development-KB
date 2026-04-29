# VERDICT — CRT Mode Switcher: CRT Boot Resolution Does Not Persist After HD-to-CRT Switch

## Status: FIXED

## Summary

Three interrelated bugs prevented boot resolution changes from persisting through mode switches. (1) `restore_video_settings` derived `es.resolution` from `global.videomode` in `video_mode.txt`, which was truncated (`769x576.50.00` vs full `769x576.50.00060`), causing ES to show "Auto." (2) The UI's "preserve existing" guard on HD->CRT prevented user boot resolution changes from being written. (3) `es.resolution` was never backed up independently, so the full-precision value from the bootstrap fix got clobbered on every restore.

## Plan vs reality

Plan was to investigate the backup/restore cycle. Root cause was found quickly via device inspection -- the truncation chain was clear from comparing `video_mode.txt` vs `batocera.conf` backup. Additional bugs surfaced during testing: the `$WAYLAND_DISPLAY` detection failure in the xterm shim, the stale labwc rule on double-launch, and the "preserve existing" guard blocking boot resolution changes.

## Root Causes

1. `batocera-resolution currentMode` returns empty in CRT/X11 mode; backup falls back to grepping `batocera.conf` which has truncated `global.videomode`
2. `restore_video_settings` derives `es.resolution` from `video_mode.txt` (truncated), overwriting the correct full-precision value from the restored `batocera.conf`
3. `run_mode_switch_ui` HD->CRT path had `if [ -s video_mode.txt ]` guard that preserved stale values instead of writing the user's new selection
4. `es.resolution` was never backed up independently of `global.videomode`

## Changes Applied

| File | Change |
|------|--------|
| `mode_switcher_modules/03_backup_restore.sh` | `backup_video_settings`: save `es.resolution` to `es_resolution.txt`; `restore_video_settings`: prefer `es_resolution.txt` over `video_mode.txt` derivation |
| `mode_switcher_modules/02_hd_output_selection.sh` | Remove "preserve existing" guard on HD->CRT; always write user's selection; write `es_resolution.txt` alongside `video_mode.txt` in all paths |
| `crt/mode_switcher.sh` | Fix Wayland detection (`pgrep -x labwc` vs `$WAYLAND_DISPLAY`); add stale rule cleanup + EXIT trap; pre-launch cleanup for double-launch resilience |

## Unanticipated bugs

- **`$WAYLAND_DISPLAY` not in emulatorlauncher process chain:** The shim's Wayland guard checked an env var that was never set. Switched to `pgrep -x labwc`.
- **Stale labwc rule on double-launch:** First instance leaves rule in `rc.xml`; second instance skips injection. Fixed with pre-launch cleanup and EXIT trap.
- **Mode switch overwrites shim:** `restore_mode_files` copies from source dir to roms dir. Fix must be in source, not just deployed location.

## What worked / what didn't

- **Worked:** SSH device inspection immediately revealed the truncation chain. The `es_resolution.txt` approach cleanly decouples `es.resolution` from the truncated `global.videomode`.
- **Didn't work initially:** Deploying the labwc fix only to the roms location -- the mode switch reinstall overwrote it from the source directory.
