# Final State — Wayland HD After Full Roundtrips — 2026-02-22 00:48 UTC

**Context:** User performed HD→CRT→HD as a final check. System is now on Wayland HD. Multiple complete roundtrips have been executed.

## System State

| Field | Value |
|---|---|
| Uptime | 1 min |
| Kernel | 6.18.9 |
| BOOT_IMAGE | `/boot/linux` (Wayland HD) |
| Syslinux DEFAULT | `batocera` (Wayland) |

## batocera.conf (HD state)

```
global.videooutput=eDP-1
global.videooutput2=none
```

No `global.videomode` or `es.resolution` — clean HD auto mode. Correct.

## Backups (stable across roundtrips)

**CRT backup:**
```
video_mode.txt:   global.videomode=769x576.50.00  ← correct precision preserved
video_output.txt: global.videooutput=DP-1
```

**HD backup:**
```
video_mode.txt:   (empty)
video_output.txt: global.videooutput=eDP-1
```

## Key Log Entry

```
[00:46:22]: Saved synced CRT mode: 769x576.50.00 (from currentMode, display: Boot_576i 1.0:0:0 15KHz 50Hz)
```

Layer 2 fix active — saved `currentMode` precision instead of `videomodes.conf` precision.

## Infrastructure

| Component | Status |
|---|---|
| `es_systems_crt.cfg` | `crt-launcher.sh` ✓ |
| `crt-launcher.sh` | present, executable ✓ |
| `15-crt-monitor.conf` | removed (correct for HD) ✓ |
| Syslinux DEFAULT | `batocera` ✓ |

## Repeated Known Issues

1. **Bug #09** — Boot resolution re-ask: reproduced every switch (`Boot:` empty in config check)
2. **False positive** — `es_systems_crt.cfg missing emulatorlauncher` log error (cosmetic)
3. **False positive** — `FINAL VERIFICATION FAILED: es_systems_crt.cfg is INCORRECT!` (cosmetic)

## Summary of Full Test

| Step | CRT Tools Visible? | Mode Mismatch? |
|---|---|---|
| Fresh install → CRT (first boot) | Yes (doc #05) | No (default mode) |
| CRT → HD → CRT (first roundtrip) | **Yes** (doc #12) | **No** (769x576.50.00 == 769x576.50.00) |
| CRT → HD → CRT → HD (second roundtrip) | N/A (HD) | N/A |

**Core bug (CRT tools invisible after roundtrip) is confirmed fixed.** The Layer 2 fix in `02_hd_output_selection.sh` and the `crt-launcher.sh` wrapper together prevent the video mode precision mismatch.

## Fixes Still Needed

1. `get_boot_display_name()` prefix-match fallback — stops the boot resolution re-ask
2. Verification grep updates — recognize `crt-launcher` alongside `emulatorlauncher`
3. `crt-launcher.sh` DISPLAY hardening — explicitly set `DISPLAY=:0.0`
