# 03 — Transferred X11 Image via FileZilla, Scan Found It

**Date:** 2026-02-20
**Action:** Transferred `batocera-x86_64-43-20260217.img.gz` to `/userdata/` via FileZilla, then pressed **(1) Scan again** in the running script.
**Previous state:** `02-ran-v43-script-wayland-detected-no-image.md`

---

## What Happened

1. User transferred the X11 v43 beta image to `/userdata/` using FileZilla.
2. Pressed **(1) Scan again** in the script prompt.
3. Script re-scanned and found the image:
   ```
   X11 Batocera Image Found

   /userdata/batocera-x86_64-43-20260217.img.gz  (4.3G)

   MD5 will be verified against the official Batocera
   checksum before use.
   ```
4. Script is now waiting at the image selection prompt:
   ```
   (1) Use this file
   (2) Enter download URL instead
   (3) Cancel
   ```
5. **No changes made to the system** — the script has not touched `/boot` or any configs.

## Image File Verification

| Field | Value |
|---|---|
| Path | `/userdata/batocera-x86_64-43-20260217.img.gz` |
| Size | 4.3GB |
| MD5 | `3df140b6ca617e1614397e9d8e204b92` |
| Date | Feb 20 23:59 |

## System State — No Changes

| Check | Result |
|---|---|
| `/boot/crt/` | Does not exist |
| `grub.cfg` | Unchanged — stock 2 entries, default=0, timeout=1 |
| Phase flag | Not present |
| `/boot` disk | 5.7G free (unchanged) |
| `/userdata` disk | 1.7T free (258MB → 4.6GB used, +4.3GB for image) |

---

## What Changed from Step 02

| Item | Before (02) | After (03) |
|---|---|---|
| `/userdata/batocera-x86_64-43-20260217.img.gz` | Does not exist | Present (4.3GB) |
| `/userdata` used | 258MB | 4.6GB |
| Script state | Waiting at "no image found" prompt | Waiting at "use this file" prompt |
| Everything else | Unchanged | Unchanged |

## Current State

Script is **paused at the image selection prompt**. User needs to:
- **(1)** Use this file — proceeds to MD5 validation (will need the mirror URL for MD5 check)
- **(2)** Enter download URL instead
- **(3)** Cancel
