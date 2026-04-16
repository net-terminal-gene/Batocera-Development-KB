# VERDICT — v43 Docked Detection Display Override

## Status: FIXED

**Both primary and secondary issues resolved:**
- Primary (docked detection regression): merged to `batocera.linux` via dmanlfc
- Secondary (DRM vs xrandr output name mismatch): **fixed, tested on hardware, committed** (`1c01262` on `crt-hd-mode-switcher-v43`, April 2, 2026)

## Summary

A docked display detection feature added to `batocera-switch-screen-checker` on March 13-14, 2026 introduced a regression on all v43 builds: any second display physically connected triggers a takeover of the primary output, overriding the user's saved `global.videooutput` setting. The behavior was designed for RP5-style handhelds docking to external displays but ran unconditionally on all hardware with no platform check. On PCs and Steam Decks this causes the primary screen to go blank the moment a second display is plugged in.

A secondary bug was found during investigation: the CRT script's HD/CRT Mode Switcher wrote DRM sysfs connector names (e.g., `HDMI-A-2`) to `batocera.conf`. EmulationStation validates against `batocera-resolution listOutputs` which uses xrandr names (`HDMI-2`). On AMD GPUs these differ for HDMI connectors, causing ES to reject the saved output.

## Plan vs Reality

Initial session (March 28) was diagnosis-only. Root cause identified via SSH diagnostics and cross-referencing the `batocera.linux` commit history. Docked detection fix from dmanlfc confirmed working on a patched Google Drive image.

Follow-up session (April 2) addressed the secondary DRM vs xrandr output name mismatch. The fix was simpler than initially scoped -- a single normalization function (`drm_name_to_xrandr()`) applied at the source of output names in `scan_xrandr_outputs()`. Verified via SSH that `video_output.txt` contained `HDMI-2` after running the mode switcher. The Linux kernel defines both `HDMI-A` and `HDMI-B` as DRM connector types; the function was broadened to `HDMI-[A-Z]-*` to handle any HDMI subtype defensively.

## Root Causes

1. `_detect_docked_output()` in `batocera-switch-screen-checker` applied handheld dock logic universally -- any connected output not in configured settings was treated as a dock
2. `emulationstation-standalone` fully overrides `global.videooutput` when docked flag is present, ignoring user's saved config
3. No platform guard in the build system -- `batocera-switch-screen-checker` installed unconditionally on all builds
4. CRT Script ported the same broken logic from upstream via PR #405 (March 18) and again via `cbdcc04` (March 28)
5. Secondary: `scan_xrandr_outputs()` in `02_hd_output_selection.sh` read connector names from DRM sysfs (`/sys/class/drm/card*-*`) which uses `HDMI-A-N` naming, but ES validates against xrandr names (`HDMI-N`). The DRM name flowed through selection UI into backup files and `batocera.conf` unchecked.

## Changes Applied

| File | Change |
|------|--------|
| `/userdata/system/batocera.conf` on test PC | Manually fixed `HDMI-A-2` to `HDMI-2` via `batocera-settings-set` to restore display (workaround) |
| `Geometry_modeline/mode_switcher_modules/02_hd_output_selection.sh` | Added `drm_name_to_xrandr()`: normalizes `HDMI-[A-Z]-N` to `HDMI-N` (handles kernel types HDMI-A and HDMI-B). Applied in `scan_xrandr_outputs()` before array insertion. Commit `1c01262`. |

## What Worked

- SSH diagnostics via base64-encoded commands reliably reproduced and confirmed the issue live
- Cross-referencing `/var/run/batocera-docked`, `display.log`, `dmesg`, and `batocera.conf` gave a complete picture quickly
- Comparing MD5 of running binary against repo source confirmed which version was active
- DRM name fix was verified on hardware via SSH before committing: `video_output.txt` showed `global.videooutput=HDMI-2`
- Consulting the kernel source (`drm_connector.c`) confirmed the full set of DRM connector types -- only HDMI has a naming mismatch with xrandr
- Primary docked detection fix merged upstream by dmanlfc, confirming the diagnosis and solution

## What Didn't

- Initial session (March 28) was blocked by dmanlfc not having pushed to GitHub yet; resolved with batocera.linux merge

## Models Used

- claude-4.6-sonnet-medium-thinking -- investigation session (March 28)
- claude-4.6-opus-max -- fix implementation and KB update (April 2)
