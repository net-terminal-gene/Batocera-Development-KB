# VERDICT — Mode Switcher Truncated global.videomode

## Status: FIXED

## Summary

Truncated mode IDs in `video_mode.txt` and derivation of `es.resolution` from that file caused EmulationStation to show "Auto" for Video Mode. The "preserve existing" guard in `02_hd_output_selection.sh` blocked user boot-resolution updates on HD→CRT.

Fixes: always write resolved `$boot_mode_id` and companion `es_resolution.txt`; `03_backup_restore.sh` prefers `es_resolution.txt` on restore; `crt-launcher.sh` syncs `batocera.conf` videomode strings to `batocera-resolution currentMode` before `emulatorlauncher` to avoid string mismatch at launch time.

## Root Causes

1. `batocera-resolution currentMode` returns empty in X11/CRT mode in some paths; backup could fall back to truncated values.
2. The "preserve existing" guard kept stale `video_mode.txt` instead of the resolved boot mode ID.
3. `es.resolution` was not backed up independently of `global.videomode`.

## Changes Applied

| File | Change |
|------|--------|
| `mode_switcher_modules/02_hd_output_selection.sh` | Remove preserve guard; write `es_resolution.txt` with boot selection (paths consolidated in branch) |
| `mode_switcher_modules/03_backup_restore.sh` | Prefer `es_resolution.txt`; HideWindow + HD restore without ES killall (see wayland session debug/x11/04) |
| `Geometry_modeline/crt-launcher.sh` | Unconditional videomode sync before `emulatorlauncher` |

**Shipped:** `crt-hd-mode-switcher-v43`, commit `64b9a16` (2026-04-16), with related session `2026-04-14_crt-mode-switcher-boot-resolution-not-persisted`.

## Plan vs reality

Original plan was to remove the preserve guard only. Implementation also added `es_resolution.txt` decoupling and launcher-side sync for runtime precision alignment.
