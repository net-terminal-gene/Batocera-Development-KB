# Debug 10 — Baseline Complete: Summary of Stages 00–09

## Date: 2026-04-13

## Script Version

**CRT-Script-04-03** — original script WITHOUT videomode-bootstrap changes.

## Purpose

Summarize all findings from the baseline test run (stages 00–09) to inform the revised bootstrap plan. This test established ground truth for how the original installer and mode switcher behave before any changes are applied.

---

## Stage-by-Stage Summary

| Stage | State | Key Finding |
|-------|-------|-------------|
| 00 | Fresh Wayland boot | `global.videomode` empty, `global.videooutput=eDP-1`, `batocera-resolution` non-functional in Wayland |
| 01 | Set video mode eDP-1 | No change to relevant settings |
| 02 | DP-1 plugged in Wayland | DP-1 shows as 640x480 only (EDID firmware inactive in Wayland boot) |
| 03 | CRT-Script-04-03 Phase 1 reboot | Installer creates CRT boot entry, `videomodes.conf`, Xorg configs |
| 04 | CRT-Script-04-03 Phase 2 pre-reboot | Installer does NOT write `global.videomode` or `global.videooutput` to `batocera.conf` |
| 05 | CRT mode live (first boot) | Display correct. `global.videomode` empty; `es.resolution` drives the mode via X11 standalone script |
| 06 | Mode Switcher CRT→HD (first run) | CRT backup created: `video_output.txt=DP-1` (correct), `video_mode.txt=641x480.59.98` (truncated). `mode_metadata.txt VIDEO_OUTPUT=eDP-1` (bug) |
| 07 | HD mode live (post CRT→HD) | HD restore correct: `global.videooutput=eDP-1`, `global.videomode=empty` |
| 08 | Mode Switcher HD→CRT pre-reboot | CRT values restored: `global.videooutput=DP-1` (correct), `global.videomode=641x480.59.98` (truncated), `es.resolution=641x480.59.98` |
| 09 | CRT mode live (post HD→CRT) | Display correct. `es.resolution=641x480.59.98` resolves correctly. Full round-trip confirmed. |

---

## Confirmed Behaviors

### What the original installer does NOT do
- Does NOT write `global.videomode` to `batocera.conf`
- Does NOT write `global.videooutput` to `batocera.conf`
- Does NOT pre-populate mode switcher backups

### What the X11 CRT boot path reads
- `es.resolution` drives the CRT display mode (set by mode switcher restore)
- `global.videooutput` is consulted by Batocera's display routing (Xorg `10-monitor.conf` also helps route to DP-1 as a fallback)
- `global.videomode` is NOT read by the X11 CRT standalone display script — confirmed in stages 05 and 09

### What the mode switcher's first run does
- Creates `crt_mode/video_settings/video_output.txt` from xrandr active output → correct (`DP-1`)
- Creates `crt_mode/video_settings/video_mode.txt` from xrandr preferred mode → truncated (`641x480.59.98`, not a `Boot_` name)
- Writes `mode_metadata.txt VIDEO_OUTPUT=` from `batocera-settings-get global.videooutput` → wrong (`eDP-1`)
- This is the first run; before the first CRT→HD switch the backup directories do not exist

### What the mode switcher restore does
- Reads `crt_mode/video_settings/video_output.txt` for `global.videooutput` → restores `DP-1` correctly
- Reads `crt_mode/video_settings/video_mode.txt` for both `global.videomode` and `es.resolution` → restores `641x480.59.98` (truncated, but works)
- Display is correct despite the truncated value

---

## Bugs Confirmed in Baseline

### Bug 1: eDP-1 first-run output pre-selection (cosmetic)
**Session:** `2026-04-13_crt-mode-switcher-firstrun-output-bug`
- `mode_metadata.txt VIDEO_OUTPUT=eDP-1` because the metadata reads `global.videooutput` from `batocera.conf`, which is `eDP-1` (never updated by installer)
- `video_output.txt` correctly contains `DP-1` (from xrandr) — so the actual restore works right
- The bug is cosmetic: the user sees `eDP-1` displayed as the current CRT output on first run, which is confusing

### Bug 2: xterm on extended DP-1 desktop (blank eDP-1 screen)
**Session:** `2026-04-13_crt-mode-switcher-wayland-blank-screen`
- When DP-1 is connected in Wayland/HD mode, the mode switcher xterm opens with `--maximized` and lands on the extended desktop (DP-1 at x=1280)
- eDP-1 appears blank because the xterm is off-screen on the CRT DAC
- Without DP-1 connected, mode switcher appears correctly on eDP-1

### Non-bug: Truncated videomode in backup
- `crt_mode/video_settings/video_mode.txt` contains `641x480.59.98` (not a `Boot_` name)
- This value IS restored correctly to `batocera.conf` and `es.resolution` on HD→CRT switch
- Display works fine with this value
- Cosmetically incorrect but functionally harmless in current code

---

## Implications for Bootstrap Plan

The baseline reveals that the original bootstrap plan's Step 2 (write `global.videomode=Boot_...`) is unnecessary and was likely the cause of the "no picture" issue in the initial bootstrap test:

- `global.videomode` is not read in the X11 CRT boot path
- Writing an incorrect Boot_ name (or one that doesn't resolve) would not affect display directly, but adds noise and risk
- The original "no picture" incident (before we realized the VGA converter was unpowered) may have had multiple contributing factors, but the Boot_ name write was unnecessary at minimum

The plan should be narrowed to the one change that actually matters: ensuring `global.videooutput=DP-1` (or the user's chosen output) is in `batocera.conf` and pre-seeded in the mode switcher backup directories so the first CRT→HD switch captures the right output.

See revised `plan.md` for the updated approach.
