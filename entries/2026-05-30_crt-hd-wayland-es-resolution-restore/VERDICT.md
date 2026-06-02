# VERDICT — HD Mode Wayland es.resolution Restore Fix

## Status: TBD

## Summary

(To be written when development concludes.)

## Plan vs reality

TBD

## Root Causes

1. HD restore sets `es.resolution=default` while Wayland boot reads boot conf, causing 165Hz on ultrawide and hotplug death spiral.
2. HD backup sidecars (`video_mode.txt`, `es_resolution.txt`) out of sync with `userdata_configs/batocera.conf`.
3. ES menu resolution changes update `batocera.conf` only, not `batocera-boot.conf`.

## Changes Applied

| File | Change |
|------|--------|
| TBD | TBD |
