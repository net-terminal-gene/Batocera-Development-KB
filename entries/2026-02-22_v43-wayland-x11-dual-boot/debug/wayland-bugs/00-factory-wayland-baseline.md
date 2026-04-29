# 00 — Factory Wayland Baseline

**Date:** 2026-02-21
**Context:** Fresh v43 Wayland install on Steam Deck, no CRT Script run, no user changes.

## batocera.conf (display-relevant lines)

```
Line  17: #display.rotate=0                   (commented — inactive)
Line 242: #global.videomode=CEA 4 HDMI         (commented — inactive)
Line 246: #global.videooutput=""                (commented — auto-detect)
Line 250: #es.resolution=""                    (commented — auto)
```

**Line count:** 383
**User-generated section:** `system.cpu.governor=performance` only — no display overrides.

## batocera-boot.conf (display-relevant)

```
#es.resolution=max-1920x1080    (commented)
```

No `display.rotate` entries present.

## wlr-randr

```
eDP-1 "Valve Corporation ANX7530 U 0x00000001 (eDP-1)"
  Enabled: yes
  Modes:
    800x1280 px, 59.999001 Hz (preferred, current)
    800x600 px, 59.999001 Hz
    640x480 px, 59.999001 Hz
    256x160 px, 58.793999 Hz
  Position: 0,0
  Transform: 270
  Scale: 1.000000
  Adaptive Sync: disabled
```

Only eDP-1 visible (DP-1/CRT adapter not connected at this point).

## batocera-resolution

```
listOutputs:       eDP-1
currentOutput:     eDP-1
currentResolution: 1280x800
```

## System State

| Item | Value |
|------|-------|
| `/boot/boot/overlay` | Does not exist |
| `/boot/crt/` | Does not exist |
| `/userdata/Batocera-CRT-Script-Backup/` | Does not exist |
| `batocera-resolution` version | Factory Wayland (`#!/bin/sh`, uses `wlr-randr`) |
| `batocera-save-overlay` version | Factory (`OVERLAYFILE="/boot/boot/overlay"`) |

## display.log Summary

- Clean first boot, auto-detected eDP-1
- Rotation 3 applied for eDP-1 (correct Steam Deck Wayland rotation)
- Hotplug event triggered one ES restart cycle, re-settled on eDP-1
- No errors

## Notes

This is the pristine reference state. All display settings are at factory auto-detect defaults.
The only user-generated config is `system.cpu.governor=performance`.
