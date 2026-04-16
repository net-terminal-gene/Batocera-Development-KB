# Debug 09 — CRT Mode Post HD→CRT Reboot

## Date: 2026-04-13

## Script Version

**CRT-Script-04-03** — original script WITHOUT videomode-bootstrap changes.

## Action

Rebooted from HD/Wayland mode into CRT mode after Mode Switcher HD→CRT switch (stage 08). User confirmed display output is correct.

## Boot Environment

```
BOOT_IMAGE=/crt/linux label=BATOCERA console=tty3 quiet loglevel=0
vt.global_cursor_default=0 mitigations=off usbhid.jspoll=0 xpad.cpoll=0
drm.edid_firmware=DP-1:edid/ms929.bin video=DP-1:e initrd=/crt/initrd-crt.gz
```

CRT boot entry active. EDID firmware (`ms929.bin`) loaded for DP-1. `video=DP-1:e` enables DP-1.

## batocera.conf State

```
global.videomode   = 641x480.59.98       ← truncated xrandr ID (restored from crt_mode backup)
global.videooutput = DP-1                ← correct
es.resolution      = 641x480.59.98       ← truncated xrandr ID (restored from crt_mode backup)
```

## Display State (X11 CRT)

```
batocera-resolution currentMode = 641x480.59.98
xrandr: DP-1 connected primary 641x480+0+0 (485mm x 364mm)
```

DP-1 is active primary display at 641x480. Display output confirmed correct by user.

## Key Findings

### 1. es.resolution=641x480.59.98 resolves correctly

The truncated xrandr mode ID written by the mode switcher (`641x480.59.98`) was accepted by `batocera-resolution` and resolved to a working CRT mode. ES rendered at 641x480 and display was correct on the CRT.

This means the **truncated videomode is not causing a display failure** in the current restore path. It works -- it's just not a Boot_ name and is less precise than ideal.

### 2. global.videomode has no effect in X11 CRT boot path

`global.videomode=641x480.59.98` is in batocera.conf but `batocera-resolution currentMode` reports `641x480.59.98` -- consistent with `es.resolution` being the operative setting. The X11 CRT boot path derives its mode from `es.resolution`, not `global.videomode`. This is consistent with stages 05 and the original bootstrap plan research.

### 3. global.videooutput=DP-1 is correct and active

DP-1 is the connected primary at 641x480+0+0. The mode switcher restore correctly set `global.videooutput=DP-1` from the xrandr-sourced `crt_mode/video_settings/video_output.txt`.

### 4. Round-trip from CRT→HD→CRT is successful

Full mode switcher round-trip complete: CRT → HD (stage 06) → HD mode live (stage 07) → HD→CRT switch (stage 08) → CRT live (this stage). Display is correct at each stage. The core restore mechanism works.

## Summary: What Works vs What Doesn't

| Behavior | Status |
|----------|--------|
| CRT display output after HD→CRT switch | WORKS |
| `global.videooutput=DP-1` restored correctly | WORKS |
| `es.resolution` resolves to correct CRT mode | WORKS |
| `global.videomode` is a Boot_ name | DOES NOT — plain xrandr ID, but harmless |
| `mode_metadata.txt VIDEO_OUTPUT` shows correct output | DOES NOT — shows eDP-1 (cosmetic bug) |

## Implication for Bootstrap Plan

The original bootstrap plan aimed to write `global.videomode=Boot_...` to batocera.conf at install time. This stage confirms that the X11 CRT path does NOT read `global.videomode` -- it reads `es.resolution`. Therefore:

- Writing `global.videomode=Boot_...` to batocera.conf is NOT needed for display correctness in X11 CRT mode.
- Writing `global.videooutput=DP-1` IS needed for the mode switcher's first HD→CRT restore to work correctly (otherwise it restores eDP-1).
- The bootstrap plan's value is primarily in seeding `crt_mode/video_settings/` with a correct `video_output.txt` so the first CRT→HD switch and subsequent HD→CRT restores use DP-1.

## Next Stage

→ `10-baseline-complete.md` — Summarize all baseline findings from stages 00–09 and determine what the bootstrap changes need to fix vs what works already.
