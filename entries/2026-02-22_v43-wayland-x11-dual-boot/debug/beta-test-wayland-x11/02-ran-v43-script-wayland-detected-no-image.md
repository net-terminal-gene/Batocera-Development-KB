# 02 — Ran v43 Script — Wayland Detected, No X11 Image Found

**Date:** 2026-02-20
**Action:** `chmod 755` and ran `Batocera-CRT-Script-v43.sh` via SSH on the Wayland system.
**Previous state:** `01-added-batocera-crt-script-via-filezilla.md`

---

## What Happened

1. Script started, detected **Wayland display stack** (labwc running).
2. Displayed dual-boot banner:
   ```
   Wayland display stack detected.
   X11 is required for CRT mode.

   A second X11 Batocera boot entry will be set up
   alongside your existing Wayland install.
   Your ROMs, saves, and BIOS files will be shared.
   ```
3. Entered **Phase 1 of 2** — "Setting up X11 boot environment alongside Wayland".
4. Scanned `/userdata` and `/media` for X11 images — **none found**.
5. Displayed transfer instructions with three options:
   ```
   (1) Scan again — I have transferred the file
   (2) Paste download URL — script will download directly
   (3) Exit
   ```
6. **Script is currently waiting at this prompt.** No changes have been made to the system.

## System State Verification

### No changes made — everything matches Step 01

| Check | Result |
|---|---|
| Display stack | Wayland (labwc PIDs 2185, 2249) |
| `/boot/crt/` | Does not exist |
| `grub.cfg` | Unchanged — stock 2 entries, default=0, timeout=1 |
| Phase flag | Not present |
| `/boot` disk | 5.7G free (unchanged) |
| `/userdata` disk | 1.7T free (unchanged) |
| `.img` / `.img.gz` files on `/userdata` | None |

### grub.cfg (unchanged)

```
set default="0"
set timeout="1"

menuentry "Batocera.linux (normal)" { ... }
menuentry "Batocera.linux (verbose)" { ... }
```

---

## Observations

- Wayland detection worked correctly via `pgrep -x labwc`.
- Routing entered Phase 1 as expected (not standard X11 install, not Phase 2).
- Image scan correctly found no `.img` / `.img.gz` files.
- Transfer instructions are clear — Windows (WinSCP), Mac/Linux (scp), USB.
- No system modifications at this point — safe to exit or continue.

## Current State

Script is **paused at the image source prompt**. User needs to either:
- **(1)** Transfer the X11 image file and scan again
- **(2)** Paste the X11 beta mirror URL to download directly
- **(3)** Exit
