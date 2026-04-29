# VERDICT — BUA Steam Big Picture Fix

## Status: Implemented — Pending QA

## Summary

Launcher2 (latest build, used by `steam2.sh` via BUA installer) updated with XAUTHORITY export and broader wmctrl regex for localized Big Picture window titles. Launcher (old build) left unchanged per plan; optional fixes deferred.

## Root Causes

1. Missing `XAUTHORITY` — wmctrl cannot connect to X11 when Launcher runs from EmulationStation
2. Window title mismatch — Launcher searched for "Steam" only; Big Picture in German is "Big-Picture-Modus"
3. (Optional) Wrong GPU on dual-GPU — Steam defaults to iGPU, rendering fails — deferred

## Changes Applied

| File | Change |
|------|--------|
| `steam/extra/Launcher2` | Add `export XAUTHORITY=/var/run/xauth` |
| `steam/extra/Launcher2` | Broaden wmctrl regex: `grep -qi "Steam"` → `grep -qiE "Steam|Big.Picture|Big-Picture"` (wait loop + monitor loop) |
