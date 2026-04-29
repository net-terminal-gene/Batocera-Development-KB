# VERDICT — CRT Mode Switcher: Wayland Blank Screen / Wrong Display

## Status: FIXED

## Summary

When the mode switcher xterm was launched from EmulationStation in Wayland/HD mode with DP-1 (CRT DAC) connected, the xterm window opened on DP-1 instead of eDP-1. The user saw a black screen on the Steam Deck display. The mode switcher was running and interactive, just invisible on the wrong output.

Fix: the shim (`crt/mode_switcher.sh`) now injects a temporary labwc window rule that pins xterm to the primary video output (read from `global.videooutput` in batocera.conf), maximizes it there, then cleans up the rule on exit. Generic approach, not hardware-specific.

## Root Cause

Batocera's standalone display script extends the Wayland desktop to DP-1 when it detects a second output. labwc's XWayland layer places new X11 windows on the default/leftmost output. xterm with `-maximized` landed on DP-1 (the CRT DAC at 640x480) every time, leaving eDP-1 blank.

## Fix: Temporary labwc Window Rule

The shim:
1. Checks `WAYLAND_DISPLAY` (Wayland mode detection)
2. Reads `global.videooutput` from `batocera.conf` (generic primary output name)
3. Injects a `<windowRule>` for `identifier="crt-mode-switcher"` into labwc's `rc.xml` with `MoveToOutput` + `ToggleMaximize`
4. Sends SIGHUP to labwc to reload the config
5. Launches xterm with `-name crt-mode-switcher` so labwc matches the rule
6. After xterm exits: removes the rule and reloads labwc

In CRT/X11 mode, `WAYLAND_DISPLAY` is not set, so the rule injection is skipped entirely. Zero behavior change for CRT mode.

## Changes Applied

| File | Change |
|------|--------|
| `Geometry_modeline/crt/mode_switcher.sh` | Replaced one-liner with labwc rule injection shim |

## Approaches Tried and Rejected

| Approach | Result |
|----------|--------|
| `-geometry +X+Y` position hint + `-maximized` | Window on correct output but not centered/filling |
| `-fullscreen` + position hint | labwc ignored position hint, window went to DP-1 |
| Explicit character geometry (`COLSxROWS+X+Y`) | Window too small, corner of display |
| Center-point geometry hint + `-maximized` | On correct output but not maximized properly |
| Disable DP-1 via wlr-randr before launch | XWayland crashes when outputs change |

## Validation Checklist

- [x] Launch mode switcher from HD/Wayland mode with DP-1 plugged in: UI fullscreen on eDP-1
- [x] Launch mode switcher from HD/Wayland mode without DP-1: UI fullscreen on eDP-1
- [x] Mode switcher menu is interactive: dialog renders, options selectable
- [x] Cancel out: xterm closes, rule cleaned from rc.xml, ES resumes
- [x] CRT/X11 mode: no behavior change (WAYLAND_DISPLAY not set, rule injection skipped)

## Previous "xterm death" Bug

The earlier debug session reported xterm exiting in < 1 second. Extensive testing confirmed this was an artifact of SSH-based diagnostic launches (outside the normal ES launch chain), NOT the real user-facing behavior. In all tests through the proper ES -> emulatorlauncher -> shim -> xterm chain, xterm stayed alive and stable. See `debug/05-hd-wayland-second-launch-test.md`.

## Notes

The fix is self-contained in the shim layer. No changes to mode_switcher.sh, no changes to modules, no changes to batocera.linux. The labwc rule is ephemeral (injected before launch, removed after exit). Generic: works for any hardware by reading `global.videooutput` rather than hardcoding display names.
