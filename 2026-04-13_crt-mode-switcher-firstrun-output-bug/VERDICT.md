# VERDICT — CRT Mode Switcher: First-Run Pre-Selects eDP-1 as CRT Output

## Status: FIXED (superseded by installer bootstrap)

## Summary

Observed 2026-04-13: first mode-switcher run could pre-select `eDP-1` as CRT output when the CRT output had not been written into `batocera.conf` / backup seeds.

**Resolution:** Session `2026-04-11_crt-installer-videomode-bootstrap` — Insert B writes `global.videooutput` (xrandr name) at CRT Script install time and pre-seeds `crt_mode/video_settings/video_output.txt`. First-run mode switcher then sees the correct CRT output.

No separate code change was required in the mode switcher UI beyond correct seed data from install.

## Plan vs reality

Investigation was deferred; installer bootstrap addressed the user-visible failure mode.

## Root Causes

1. Missing or generic `global.videooutput` before CRT Script install completed output selection persistence.
2. Empty or default-backed `video_output.txt` in mode backups on first run.

## Changes Applied

| Session / file | Change |
|----------------|--------|
| `2026-04-11_crt-installer-videomode-bootstrap` | Insert A/B/C in `Batocera-CRT-Script-v42.sh` / `v43.sh` |

## Validation

- [x] Fresh install + CRT Script: mode switcher first open shows intended CRT output (tracked with bootstrap session)
