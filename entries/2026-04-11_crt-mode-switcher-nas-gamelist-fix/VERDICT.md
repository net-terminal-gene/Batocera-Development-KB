# VERDICT — CRT Mode Switcher: NAS Gamelist Visibility Fix

## Status: FIXED

v42 branch (PR #390) and v43 branch (PR #395) both tested. v43 validated on hardware 2026-04-16 (PC X11, Steam Deck Wayland/X11) alongside commit `64b9a16` mode-switcher fixes.

## Summary

The `mode_switcher.sh` entry was disappearing from the CRT system in EmulationStation after switching to HD mode, specifically on NAS-backed ROM directories. The root cause was `rm -rf $CRT_ROMS/crt/*` in `install_crt_tools()` — on CIFS mounts, this deletion persists across reboot but the subsequent `cp` writes may not flush in time, leaving the directory empty.

The fix removes all `rm -rf` calls. All CRT tools are now always present on disk in both modes. A new `set_crt_gamelist_visibility()` function toggles `<hidden>true</hidden>` tags in `gamelist.xml` to control what EmulationStation shows: only mode_switcher in HD mode, everything in CRT mode.

This issue originated in `2026-04-06_crt-mode-switcher-empty-backups` but was not identified as a code bug at the time.

## Plan vs Reality

Plan matched implementation exactly. No surprises in the gamelist `<hidden>` approach — ES respects the tag reliably.

One unrelated issue encountered during the session: `emulatorlauncher.py` crashed with a `ValueError` when the Batocera display was not set as the OS primary display (xrandr returned empty from `listPrimary`). Not a code bug — resolved by ensuring Batocera is on the foreground display during testing.

## Root Causes

1. `rm -rf $CRT_ROMS/crt/*` in HD mode branch of `install_crt_tools()` — NAS write-back race on reboot
2. `rm -rf $CRT_ROMS/crt/*` in CRT mode branch also present — same risk applies

## Changes Applied

| File | Change |
|------|--------|
| `03_backup_restore.sh` (crt-hd-mode-switcher) | Remove `rm -rf`, unified `cp -a`, add `set_crt_gamelist_visibility()` — pushed, tested |
| `03_backup_restore.sh` (crt-hd-mode-switcher-v43) | Same fix; hardware-tested 2026-04-16 |

## Models Used

Sonnet 4.6 (Composer) — diagnosis, code changes, SSH verification
