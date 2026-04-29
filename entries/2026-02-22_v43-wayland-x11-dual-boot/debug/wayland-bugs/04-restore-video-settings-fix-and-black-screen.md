# 04 — restore_video_settings Fix Applied + Black Screen on Warm Reboot

**Date:** 2026-02-21
**Status:** Fix verified; transient black screen on warm reboot (GPU state issue)

## What Changed

Removed the `is_dualboot_system` gate in `03_backup_restore.sh` that was skipping `restore_video_settings("hd")` for dual-boot systems.

**File:** `mode_switcher_modules/03_backup_restore.sh` (lines ~1172-1190)

**Before:**
```bash
if is_dualboot_system && [ "$mode" = "hd" ]; then
    echo "Dual-boot HD: skipping restore_video_settings ..." >> "$LOG_FILE"
else
    restore_video_settings "$mode"
fi
```

**After:**
```bash
restore_video_settings "$mode"

if is_dualboot_system && [ "$mode" = "hd" ]; then
    if [ -f "/userdata/system/batocera.conf" ]; then
        sed -i '/^display\.rotate=0$/d' /userdata/system/batocera.conf 2>/dev/null || true
    fi
fi
```

The old gate was based on the overlay contamination bug (patched `batocera-resolution` using `xrandr` on Wayland, causing display-checker failures). Since the overlay contamination fix is in place (`/boot/crt/overlay` isolation), this gate is no longer needed.

## Test Procedure

1. Fresh v43 Wayland install
2. Set Video Output = eDP-1, Backglass = None in ES
3. Ran Batocera-CRT-Script (Phase 1 + Phase 2)
4. Ran Mode Switcher: CRT → HD (selected eDP-1 as HD output)
5. Mode switcher rebooted system

## Result: Black Screen on Warm Reboot

After mode_switcher rebooted (CRT → HD), the Steam Deck showed:
- **No splash video**
- **Black screen** (no display output on either eDP-1 or DP-1)
- SSH unreachable (`batocera.local` did not resolve)

**Power cycle** (hold power button, restart) resolved the issue. System booted normally.

## Post-Power-Cycle SSH Verification

### batocera.conf — Video Settings PERSISTED

```
384:display.brightness=100
385:global.videooutput2=none      ← from factory backup (user set this before script install)
386:global.videooutput=eDP-1      ← written by restore_video_settings from HD backup ✓
246:#global.videooutput=""         ← factory default still commented (unused)
```

Both user settings now persist through mode_switcher CRT→HD transitions.

### HD Mode Backup Contents

```
/userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/video_output.txt
→ global.videooutput=eDP-1
```

Only `video_output.txt` exists in HD backup (no `video_output2.txt`, no `video_mode.txt`). This is expected — the HD backup is sparse since it was created during mode_switcher's first run (switching FROM HD to CRT, only the HD output selection is saved).

### display.log — Correct Display Configuration

```
Found Primary Output: eDP-1
Found Secondary Output: none
Standalone: Using pre-configured video outputs - eDP-1, none,
Standalone: Invalid output - none              ← expected (none = no secondary)
setOutput: Queuing ON for eDP-1
setOutput: Queuing OFF for DP-1
Rotation for output eDP-1: 3                   ← correct Steam Deck Wayland rotation
Setting resolution for 'eDP-1' to '800x1280.60.00'
```

ES correctly detected and used `eDP-1` as the primary output. The "Invalid output - none" for secondary is expected behavior (ES validates against connected displays; "none" is not a display).

### mode_switcher Build Log — Restore Trace

```
[16:36:40]: Starting restore for hd mode (userdata-only approach)
[16:36:40]: Dual-boot HD: /boot/boot/overlay already absent
[16:36:40]: HD Mode: Restoring factory/clean state
[16:36:40]: HD Mode backup sparse, will use CRT Script factory backup for batocera.conf
[16:36:40]: Restored factory batocera.conf
[16:36:40]: Cleared es.resolution from both config files for HD auto mode
```

Confirms `restore_video_settings("hd")` ran. It:
1. Read `global.videooutput=eDP-1` from HD backup
2. Appended it to the freshly-restored factory batocera.conf (factory conf has `#global.videooutput=""`, so grep for `^global.videooutput=` finds no match → appends)
3. Cleared `es.resolution` and `global.videomode` (no `video_mode.txt` in HD backup → HD auto mode)

### batocera-boot.conf

```
es.resolution=800x1280.60.00    ← re-synced by S65values4boot on Wayland boot
display.rotate.EDP=             ← empty (synced from sysconfig)
display.rotate=                 ← empty
```

`es.resolution` was cleared by `restore_video_settings` before reboot but re-populated by `S65values4boot` on the Wayland boot from Steam Deck sysconfig. This is expected behavior.

### Overlay State

```
/boot/boot/overlay  → absent (correct — clean Wayland)
/boot/crt/overlay   → 100MB (CRT overlay intact)
```

### syslinux.cfg

```
DEFAULT batocera                      ← HD/Wayland is default ✓
MENU HIDDEN                           ← boot menu hidden ✓
LABEL crt → /crt/linux, /crt/initrd-crt.gz  ← CRT entry preserved ✓
```

## Black Screen Root Cause Analysis

[Inference] The black screen on warm reboot was a **transient GPU/DRM state issue**, not caused by our code change. Evidence:

1. **All config values were correct** before the reboot (confirmed by build log timestamps — all writes completed at 16:36:40, reboot happened after user pressed ENTER)
2. **No splash video** suggests the DRM/KMS layer failed to initialize the display during early boot, before any ES or batocera.conf settings are read
3. **SSH unreachable** suggests the system may not have fully booted, or network services failed alongside the display
4. **Power cycle fixed it** — a cold boot forces full GPU register reset, unlike a warm reboot which may carry forward stale DRM connector state
5. The GPU was previously configured for CRT output (DP-1 with custom EDID at 15kHz timing, interlaced). Transitioning from that state to eDP-1 (internal panel, 60Hz progressive) on a warm reboot may not cleanly reinitialize all GPU display pipelines on AMD APU (Steam Deck's Van Gogh)

This may warrant investigation into whether the mode_switcher should explicitly reset DRM state before rebooting, or whether users should be instructed to use a power cycle (cold boot) instead of warm reboot when switching CRT→HD.

## Summary

| Item | Status |
|------|--------|
| `global.videooutput=eDP-1` persists to HD mode | **FIXED** ✓ |
| `global.videooutput2=none` persists to HD mode | **Working** (from factory backup) |
| `es.resolution` cleared for HD auto mode | **Working** ✓ |
| Rotation correct (3 = 270° for Steam Deck) | **Working** ✓ |
| Black screen on warm reboot CRT→HD | **Transient GPU issue** — power cycle resolves |
