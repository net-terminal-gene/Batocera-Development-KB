# 05 — Cleanup Done, Phase Flag Written, Ready to Reboot

**Date:** 2026-02-20
**Action:** Selected **(1) Yes, delete source image**. Script deleted it, wrote phase flag, showing Phase 1 complete message with reboot prompt.
**Previous state:** `04-md5-passed-extract-initrd-grub-overlay.md`

---

## What Happened

1. Selected **(1) Yes, delete it** — source image deleted.
2. Script wrote phase flag: `.install_phase` = `2`.
3. Phase 1 complete message displayed:
   ```
   Phase 1 Complete!

   The X11 boot environment is installed.
   GRUB is configured to boot into X11 on next restart.

   WHAT HAPPENS NEXT:

   1) System reboots into the X11 Batocera.
   2) Re-run this CRT Script from X11.
      It will detect Phase 2 automatically and continue
      with CRT display configuration.

   Your ROMs, saves, and BIOS files are shared.
   Nothing from your Wayland install is lost.

   Press ENTER to reboot into X11...
   ```
4. **Script is paused at the reboot prompt.** Pressing ENTER will reboot.

## System State Verification

### Phase flag — Written

```
$ cat /userdata/system/Batocera-CRT-Script/.install_phase
2
```

### Source image — Deleted

`/userdata/batocera-x86_64-43-20260217.img.gz` — **gone**. `/userdata` back to 258MB used (was 4.6GB).

### /boot/crt/ — Intact

```
total 4.3G
-rwxr-xr-x 1 root root 3.2G Feb 21 00:12 batocera
-rwxr-xr-x 1 root root 754K Feb 21 00:12 initrd-crt.gz
-rwxr-xr-x 1 root root  22M Feb 21 00:12 linux
-rwxr-xr-x 1 root root 1.1G Feb 21 00:12 rufomaculata
```

### GRUB — Ready for X11 boot

```
set default="1"    ← will boot CRT (X11) entry
set timeout="3"
```

### Disk space

```
/dev/nvme0n1p1   10G  8.7G  1.4G  87% /boot
/dev/nvme0n1p2  1.8T  258M  1.7T   1% /userdata
```

---

## What Changed from Step 04

| Item | Before (04) | After (05) |
|---|---|---|
| Source image | Present (4.3GB) | Deleted |
| `/userdata` used | 4.6GB | 258MB |
| Phase flag | Not yet written | `2` |
| Script state | Cleanup prompt | Reboot prompt |
| Everything else | Unchanged | Unchanged |

## Phase 1 Summary — All Steps Passed

| Phase 1 Step | Status |
|---|---|
| Wayland detection | Passed |
| Image scan | Passed (found after manual transfer) |
| MD5 validation | Passed (sanitize fix worked) |
| Disk space check | Passed |
| Extraction to `/boot/crt/` | Passed — 4 files, squashfs valid |
| Initrd patch | Passed — 10 references patched, 0 remaining |
| GRUB update | Passed — 3 entries, default=1, timeout=3 |
| Overlay script deploy | Passed |
| Source cleanup | Passed — image deleted |
| Phase flag write | Passed — value `2` |

## Current State

Script is **paused at "Press ENTER to reboot into X11..."**. After reboot:
- GRUB will boot entry 1 → "Batocera CRT (X11)"
- System boots X11 with patched initrd loading from `/boot/crt/`
- Re-run the CRT script → Phase 2 detected → CRT display configuration begins
