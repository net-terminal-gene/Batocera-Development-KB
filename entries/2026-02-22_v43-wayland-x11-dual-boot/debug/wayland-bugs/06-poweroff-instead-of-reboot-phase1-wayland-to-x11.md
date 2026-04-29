# 06 — Poweroff Instead of Reboot for Phase 1 (Wayland → X11)

**Date:** 2026-02-20
**Status:** FIXED

## Symptom

After Phase 1 completes on Wayland and the script calls `reboot`, the system boots into the X11 kernel but the Steam Deck screen is black. SSH is unreachable. A power cycle (cold boot) resolves the issue and X11 boots normally on eDP-1.

## Root Cause

Same GPU warm-reboot issue documented in step 05, but in the opposite direction (Wayland → X11). The Steam Deck's AMD GPU retains DRM/KMS state from the Wayland compositor through a warm reboot. When the X11 kernel attempts to initialize display output via a different display stack, the stale GPU state causes a black screen.

Phase 1's syslinux CRT entry uses a generic APPEND line with no `drm.edid_firmware` or `video=` parameters — the X11 kernel should auto-detect eDP-1. The failure is not related to kernel parameters but to stale GPU hardware state surviving the warm reboot.

## Fix

Replaced `reboot` with `poweroff` in `show_phase1_success_message()` (Batocera-CRT-Script-v43.sh). Updated the user-facing message to instruct pressing the power button after shutdown.

### Before

```bash
box_center "Press ENTER to reboot into X11..."
# ...
reboot
```

### After

```bash
box_center "1) System SHUTS DOWN."
box_center "2) Press the POWER BUTTON to boot into X11."
box_center "3) Re-run this CRT Script from X11."
# ...
box_center "Press ENTER to shut down..."
# ...
poweroff
```

## Pattern

All cross-kernel transitions on the Steam Deck require a cold boot (poweroff + manual power-on) to ensure a clean GPU reset:

| Transition | Direction | Fix |
|-----------|-----------|-----|
| Phase 1 complete | Wayland → X11 | `poweroff` (this fix) |
| mode_switcher CRT → HD | X11 → Wayland | `poweroff` (step 05) |
| mode_switcher HD → CRT | Wayland → X11 | `poweroff` (also fixed in this step) |
| Phase 2 complete | X11 → X11 | `reboot` (same kernel, no issue) |

All three cross-kernel transitions now use `poweroff`. The `mode_switcher.sh` conditional was simplified: any dual-boot transition uses `poweroff`, single-boot uses `reboot`.
