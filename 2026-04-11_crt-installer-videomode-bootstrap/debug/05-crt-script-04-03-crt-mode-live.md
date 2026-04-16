# Debug 05 — CRT-Script-04-03: Live CRT Mode (Post-Reboot)

## Date: 2026-04-13

## Script Version

**CRT-Script-04-03** — original script WITHOUT videomode-bootstrap changes.

## Hardware Finding (Retroactive)

> **The "no picture" issue from the previous testing session was caused by the VGA-to-Component converter not being powered.** The converter requires external power and was unplugged. All software diagnostics from that session were correct — the signal was being generated properly. The `global.videomode=Boot_576i...` change we blamed may or may not have been a real issue; with the converter unpowered, no software change could have produced an image regardless.

This means our earlier conclusion ("writing global.videomode causes black screen") is **unconfirmed**. Testing continues to properly isolate the actual behavior.

## Boot Environment

```
/proc/cmdline:
BOOT_IMAGE=/crt/linux label=BATOCERA console=tty3 quiet loglevel=0
vt.global_cursor_default=0 mitigations=off usbhid.jspoll=0 xpad.cpoll=0
drm.edid_firmware=DP-1:edid/ms929.bin video=DP-1:e initrd=/crt/initrd-crt.gz
```

## batocera.conf State (Live CRT Mode)

```
global.videomode   = (empty)
global.videooutput = eDP-1   ← Wayland laptop value, never changed by installer
es.resolution      = 641x480.60.00000
```

## xrandr (Live CRT Mode — EDID Firmware Active)

```
Screen 0: minimum 320 x 200, current 641 x 480, maximum 16384 x 16384
DP-1 connected primary 641x480+0+0
   641x480i   59.98 +    ← interlaced preferred mode from EDID
   641x480    60.00*     ← progressive mode currently active (set by setMode)
```

Only DP-1 is active. eDP-1 is not listed — correctly hidden by `10-monitor.conf` Ignore rule.

## display.log — Full Standalone Boot Sequence

```
Splash: Preferred display is eDP-1
Splash: Exactly matched preferred display 'eDP-1' and it is connected.
Splash: Selected DRM connector: eDP-1
Splash: DRM connected card path: /dev/dri/card0
Only one GPU detected in the system
Checker: Timed out waiting for EmulationStation web server. Aborting trigger.
Standalone: --- Top of display configuration loop ---
Standalone: --- Applying Language Settings ---
Language set to en_US.UTF-8
Standalone: --- Determining Video Outputs ---
Checker: Explicit video outputs configured ( eDP-1). Skipping docked detection.
Checker-Init: Storing settled display list: [DP-1 ]
Standalone: Using pre-configured video outputs - eDP-1, , 
Standalone: Validating detected outputs...
Standalone: Invalid output - eDP-1
Standalone: First video output defaulted to - DP-1
Standalone: --- Enabling Outputs ---
set user output: DP-1 as primary
Updated video outputs: DP-1, , 
Standalone: --- Applying Resolutions ---
setMode: 641x480.60.00
setMode: Output: DP-1 Resolution: 641x480 Rate: 60.00
Standalone: --- Applying Rotations ---
Standalone: Using global rotation value: 0
Standalone: Applying system rotation '0' for 'DP-1'.
Standalone: --- Launching EmulationStation ---
```

## Key Observations

### How the original script handles global.videooutput=eDP-1

The display pipeline gracefully handles the stale `eDP-1` value:

1. Splash shows on eDP-1 (Steam Deck screen) — because `global.videooutput=eDP-1` and eDP-1 is a valid DRM connector.
2. Standalone reads `global.videooutput=eDP-1` → "Explicit video outputs configured (eDP-1)".
3. Standalone validates eDP-1 → **"Invalid output - eDP-1"** — eDP-1 is ignored in `10-monitor.conf`, so it is not visible as an X11 output.
4. Standalone **falls back to DP-1** as the first available X11 output.
5. setMode applies `641x480.60.00` on DP-1. CRT displays correctly.

**Conclusion:** `global.videooutput=eDP-1` in batocera.conf does NOT break CRT mode. The standalone script's fallback logic recovers cleanly. Writing `global.videooutput=DP-1` via our bootstrap would skip steps 3-4 and go directly to DP-1 — slightly cleaner but not required for correctness.

### Resolution ID format confirmed

```
es.resolution format:  641x480.60.00000   (WxH.rate.00000 — line number is 00000 not the actual 00059)
videomodes.conf entry: 641x480.60.00059:Boot_480i 1.0:0:0 15KHz 60Hz
batocera-resolution setMode call: 641x480.60.00   (truncated to 2 decimal places)
xrandr mode active: 641x480 @ 60.00 Hz
```

The `.00000` suffix in `es.resolution` does NOT need to match the `.00059` suffix in videomodes.conf. The resolution matching is by `WxH.rate` prefix only.

### global.videomode not needed for CRT operation

The original script works entirely without `global.videomode` being set. The CRT mode is determined by:
- `drm.edid_firmware` → kernel sets the available modes on DP-1
- `10-monitor.conf` → Xorg restricts display to DP-1 only
- `es.resolution` → standalone script calls setMode with the correct WxH.rate
- `global.videomode` is never consulted in this path

### mode_backups still empty

```
(empty)
```

Confirmed: the original script produces no backup files. The mode switcher will hit the first-run re-pick issue.

## Next Stage

→ `06-bootstrap-changes-phase2-pre-reboot.md` — Re-flash, run updated script WITH bootstrap changes, capture state to compare.
