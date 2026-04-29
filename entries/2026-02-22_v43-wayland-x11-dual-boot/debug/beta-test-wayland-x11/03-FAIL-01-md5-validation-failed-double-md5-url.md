# 04 — MD5 Validation Failed — Double .md5 URL Bug

**Date:** 2026-02-20
**Action:** Selected **(1) Use this file**, pasted the `.md5` URL instead of the image URL.
**Previous state:** `03-transferred-x11-image-scan-found.md`

---

## What Happened

1. User selected **(1) Use this file**.
2. Script prompted: "Paste the mirror URL for this image (needed for MD5 verification)"
3. User pasted the `.md5` URL:
   ```
   https://mirrors.o2switch.fr/batocera/x86_64/butterfly/last/batocera-x86_64-43-20260217.img.gz.md5
   ```
4. Script derived `MD5_URL="${IMAGE_URL}.md5"` → doubled the extension:
   ```
   https://mirrors.o2switch.fr/batocera/x86_64/butterfly/last/batocera-x86_64-43-20260217.img.gz.md5.md5
   ```
5. `wget` fetched the double-`.md5` URL → 404 / empty response.
6. Script reported: "Could not fetch MD5 checksum from mirror"
7. Script exited with: "MD5 validation failed. Aborting."

## Root Cause

**Bug in `prompt_image_source()`:** The prompt asks for "the mirror URL for this image" but does not specify it should be the **image URL** (not the `.md5` URL). The script always appends `.md5` to derive the checksum URL, so if the user pastes a URL already ending in `.md5`, it becomes `.md5.md5`.

## Fix Required

1. Strip trailing `.md5` from user input before setting `IMAGE_URL`.
2. Make the prompt text explicitly say "image URL (not the .md5 URL)".

## System State — No Damage

| Check | Result |
|---|---|
| `/boot/crt/` | Does not exist |
| `grub.cfg` | Unchanged — default=0, timeout=1 |
| Phase flag | Not present |
| Image file | Still present (`/userdata/batocera-x86_64-43-20260217.img.gz`, 4.3GB) |
| Script state | Exited — needs to be re-run after fix |

---

## What Changed from Step 03

| Item | Before (03) | After (04) |
|---|---|---|
| Script state | Waiting at prompt | Exited (MD5 failure) |
| System state | No changes | No changes |

The script correctly aborted without modifying the system.
