# 04 — MD5 Passed, Extract, Initrd Patch, GRUB Update, Overlay Deploy

**Date:** 2026-02-20
**Action:** Re-ran script after fix, selected (1) Use this file, pasted `.md5` URL (sanitize fix worked), MD5 passed, extraction + patching + GRUB update + overlay deploy all completed.
**Previous state:** `03-FAIL-01-md5-validation-failed-double-md5-url.md`

---

## What Happened

1. Script re-run, Wayland detected, Phase 1 entered, image found on re-scan.
2. Selected **(1) Use this file**, pasted `.md5` URL again — **`sanitize_image_url()` fix worked**, stripped trailing `.md5`.
3. **MD5 validation passed:**
   ```
   Expected:  3df140b6ca617e1614397e9d8e204b92
   Got:       3df140b6ca617e1614397e9d8e204b92
   ✔ Checksum verified. File is the correct X11 build.
   ```
4. **Disk space check passed:**
   ```
   /userdata  needs 5.0GB free  ->  currently 1725GB free  OK
   /boot      needs 4.0GB free  ->  currently 6GB free  OK
   ```
5. **Extraction completed** — decompressed `.img.gz`, loop-mounted VFAT, copied 4 files to `/boot/crt/`.
6. **Initrd patched** — 10 path references changed, 0 remaining.
7. **GRUB updated** — CRT entry added, default set to 1 (CRT) for Phase 2 reboot.
8. **Overlay script deployed** — `batocera-save-crt-overlay` written and executable.
9. **Cleanup prompt showing** — waiting for user to delete or keep source image.

## System State Verification

### /boot/crt/ — All 4 files present

```
total 4.3G
-rwxr-xr-x 1 root root 3.2G Feb 21 00:12 batocera
-rwxr-xr-x 1 root root 754K Feb 21 00:12 initrd-crt.gz
-rwxr-xr-x 1 root root  22M Feb 21 00:12 linux
-rwxr-xr-x 1 root root 1.1G Feb 21 00:12 rufomaculata
```

### Squashfs magic bytes — Verified

```
00000000: 6873 7173    hsqs
```

`batocera` is a valid squashfs file.

### grub.cfg — Updated

```
set default="1"
set timeout="3"

menuentry "Batocera HD (Wayland)" {
    echo Booting Batocera.linux... (grub2)
    linux /boot/linux label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
    initrd /boot/initrd.gz
}

menuentry "Batocera CRT (X11)" {
    echo Booting Batocera.linux... CRT Mode (X11)
    linux /crt/linux label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
    initrd /crt/initrd-crt.gz
}

menuentry "Batocera HD (verbose)" {
    echo Booting Batocera.linux... (grub2)
    linux /boot/linux label=BATOCERA vt.global_cursor_default=0
    initrd /boot/initrd.gz
}
```

| GRUB field | Value | Expected |
|---|---|---|
| default | `"1"` (CRT entry) | Correct — Phase 2 reboot will boot X11 |
| timeout | `"3"` | Correct — bumped from 1 to show menu |
| Entry 0 | Batocera HD (Wayland) | Correct — renamed from "Batocera.linux (normal)" |
| Entry 1 | Batocera CRT (X11) | Correct — new, uses `/crt/linux` + `/crt/initrd-crt.gz` |
| Entry 2 | Batocera HD (verbose) | Correct — renamed from "Batocera.linux (verbose)" |

### Overlay script — Deployed

```
-rwxr-xr-x 1 root root 1454 Feb 21 00:12 /userdata/system/Batocera-CRT-Script/batocera-save-crt-overlay
```

Shebang: `#!/bin/sh`

### Phase flag — Not yet written

Phase flag is written **after** the cleanup prompt (step 9 of `run_phase1()`). Script is currently paused at the cleanup prompt (step 8).

### Disk space

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n1p1   10G  8.7G  1.4G  87% /boot
/dev/nvme0n1p2  1.8T  4.6G  1.7T   1% /userdata
```

`/boot` went from 4.4G used → 8.7G used (+4.3G for `/boot/crt/` contents).

---

## What Changed from Step 03

| Item | Before (03) | After (04) |
|---|---|---|
| `/boot/crt/` | Does not exist | Present — 4 files (4.3GB) |
| `grub.cfg` | 2 entries, default=0, timeout=1 | 3 entries, default=1, timeout=3 |
| GRUB entry names | "Batocera.linux (normal/verbose)" | "Batocera HD (Wayland/verbose)" |
| CRT GRUB entry | Does not exist | "Batocera CRT (X11)" — `/crt/linux` + `/crt/initrd-crt.gz` |
| `batocera-save-crt-overlay` | Does not exist | Deployed, executable |
| `/boot` used | 4.4G | 8.7G |
| Phase flag | Not present | Not yet written (script paused before that step) |
| Source image | Present (4.3GB) | Present — cleanup prompt waiting |

## Current State

Script is **paused at the cleanup prompt**:
```
(1) Yes, delete it — reclaim 4.3G on /userdata
(2) No, keep it — useful if you may need to reinstall later
```

After this choice, the script will write the phase flag and prompt to reboot into X11.
