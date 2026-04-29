# VERDICT — CRT Installer Missing global.videooutput

## Status: TBD

## Summary

The CRT Script installer never writes `global.videooutput` to `batocera.conf`. On Wayland dual-boot systems, the factory `eDP-1` default remains, causing `emulationstation-standalone` to target the wrong display while X11/CRT runs on `DP-1`. Manual fix confirmed working — awaiting code change in the installer.

## Root Causes

1. `Batocera-CRT-Script-v43.sh` writes the selected CRT output to syslinux, X11 configs, and helper scripts, but not to `batocera.conf` as `global.videooutput`.
2. On Wayland dual-boot, `batocera.conf` ships with `global.videooutput=eDP-1` (factory default for the laptop screen).
3. `emulationstation-standalone` MultiScreen wrapper reads `global.videooutput` to select the display. With `eDP-1`, ES targets the laptop screen, which is ignored by X11 in CRT mode.
4. `batocera-resolution listOutputs` returns empty in X11 mode, so the wrapper's validation logic can't auto-correct the wrong value.

## Changes Applied

| File | Change |
|------|--------|
| (pending) | `Batocera-CRT-Script-v43.sh` — add `global.videooutput=$video_output_xrandr` |
| (pending) | `02_hd_output_selection.sh` — add `es.resolution` fallback in `get_crt_boot_resolution()` |
