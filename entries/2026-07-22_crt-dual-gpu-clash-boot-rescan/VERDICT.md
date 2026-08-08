# VERDICT — CRT Dual-GPU Clash: Boot Blacklist + Connector Rescan

## Status: TBD

## Summary

Manual dual-GPU recovery validated on lab hardware (2026-07-22): CRT boot `module_blacklist` for NVIDIA + AMD-only Xorg + retarget `DP-5`→`DP-2` restored EmulationStation on CRT. Installer automation (detect → blacklist CRT APPEND → rescan connectors → write configs) not yet implemented.

## Plan vs reality

[To be filled when session closes]

## Root Causes

1. X auto-adds NVIDIA GPU → `modeset(G0)` pixmap fatal.
2. `modprobe.blacklist` insufficient against Batocera `batocera-nvidia`.
3. Hard-blacklisting NVIDIA renumbers AMD DRM connectors; installer names become stale.

## Changes Applied

| File | Change |
|------|--------|
| (lab only) CRT syslinux APPEND | `module_blacklist=nvidia,...`; EDID/video → `DP-2` |
| (lab only) `/etc/X11/xorg.conf.d/05-amd-only.conf` | `AutoAddGPU false` + AMD BusID |
| (lab only) `batocera.conf` | `global.videooutput=DP-2` |
