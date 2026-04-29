# Step 11 — FAIL 01 — Reboot HD Wayland Wrong Rotation

**Date:** 2026-02-21
**Action:** Rebooted into Wayland/HD mode after mode_switcher CRT → HD switch
**Result:** FAIL — Screen displayed in portrait orientation (800x1280 native, no rotation applied). Steam Deck eDP-1 panel was not rotated to landscape.

---

## Root Cause

The ES standalone display checker returns an empty settled display list during early startup:

```
Checker-Init: Storing settled display list: [ ]
Standalone: Using pre-configured video outputs - eDP-1, none,
Standalone: Validating detected outputs...
Standalone: Invalid output - eDP-1
Standalone: First video output defaulted to -
Standalone: Default output '' not connected. Finding first available.
Standalone: --- Applying Rotations ---
Standalone: Using global rotation value: 0
```

**Cascade:**
1. Mode_switcher's `restore_video_settings("hd")` wrote `global.videooutput=eDP-1` to `batocera.conf`
2. ES standalone tried to validate `eDP-1` against the (empty) settled display list → "Invalid output"
3. Output defaulted to empty → `display.rotate.eDP-1` was never queried
4. Fell through to global `display.rotate=0` → no rotation → portrait mode

**Factory Wayland state:** `#global.videooutput=""` (commented out / auto-detect). With no explicit output, ES bypasses validation and auto-detects correctly, then applies `display.rotate.eDP-1=3` (270° from sysconfig).

---

## Sysconfig Values (Correct)

From `/usr/share/batocera/sysconfigs/batocera.conf.Jupiter` (Wayland/x86-64-v3):

| Key | Value | Purpose |
|---|---|---|
| `display.rotate.eDP-1` | `3` (270°) | Wayland compositor rotation |
| `display.rotate.EDP` | `1` (90°) | DRM splash screen rotation |
| `es.resolution` | `800x1280.60.00` | Native panel resolution |

`batocera-settings-get-master display.rotate.eDP-1` correctly returns `3`. The sysconfig was never the problem — the issue was that ES never queried it because the output was invalid.

---

## Current batocera.conf (Broken State)

```
#global.videooutput=""       ← factory (line ~17, commented)
display.rotate=0             ← CRT Script remnant (overrides sysconfig)
global.videooutput=eDP-1     ← mode_switcher appended (breaks Wayland)
```

The factory backup (385 lines) was restored, but `restore_video_settings` then appended `global.videooutput=eDP-1` (line 574).

---

## BootRes.log (CRT Settings Leaked)

```
Monitor Type: ms929
Boot Resolution: 768x576@25
```

CRT monitor profile still active — indicates `boot-custom.sh` or CRT conf remnants are affecting Wayland boot.

---

## Fix

Modified `03_backup_restore.sh`:

1. **Skip `restore_video_settings("hd")` in dual-boot** — factory `batocera.conf` already has correct Wayland auto-detect defaults. The `global.videooutput=eDP-1` override that `restore_video_settings` adds breaks Wayland's display checker.

2. **Skip multiscreen disable in dual-boot HD** — factory backup already has `global.videooutput2=none`.

3. **Clean up `display.rotate=0`** — remove the uncommented CRT Script remnant so the sysconfig's `display.rotate.eDP-1=3` takes effect.
