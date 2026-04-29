# Step 06 — FAIL 01: Reboot Booted Wayland (Syslinux, Not GRUB)

**Date:** 2026-02-21
**Action:** User rebooted the system after Phase 1 completion
**Expected:** System boots into X11 (CRT) via GRUB `default="1"`
**Actual:** System booted back into Wayland — GRUB config was never in the boot path

---

## Root Cause

Batocera v43 does **not** use `grub.cfg` in the active EFI boot chain. The actual boot path is:

```
EFI firmware
  → Boot0001: \EFI\batocera\shimx64.efi
    → grubx64.efi (173KB, same dir)
      → syslinux (ldlinux.e64 / menu.c32)
        → reads syslinux.cfg
```

There are **two** syslinux.cfg files — both identical, both stock:

| Path | Purpose |
|---|---|
| `/boot/EFI/batocera/syslinux.cfg` | EFI boot |
| `/boot/boot/syslinux.cfg` | Legacy BIOS boot |

The `grub.cfg` at `/boot/EFI/BOOT/grub.cfg` (which our script modified) is **not** in the active boot path. It sits alongside `BOOTX64.EFI` which is only used as a removable-media fallback.

### Evidence: EFI Boot Manager

```
BootCurrent: 0001
BootOrder: 0001,0000,2001,2002,2003
Boot0001* Batocera → \EFI\batocera\shimx64.efi
```

### Evidence: syslinux.cfg (active boot config, unchanged)

```
UI menu.c32

TIMEOUT 10
TOTALTIMEOUT 300

SAY Booting Batocera.linux...

MENU CLEAR
MENU TITLE Batocera.linux
MENU HIDDEN

LABEL batocera
	MENU LABEL Batocera.linux (^normal)
	MENU DEFAULT
	LINUX /boot/linux
	APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
	INITRD /boot/initrd.gz

LABEL verbose
	MENU lABEL Batocera.linux (^verbose)
	LINUX /boot/linux
	APPEND label=BATOCERA vt.global_cursor_default=0
	INITRD /boot/initrd.gz
```

No CRT entry exists in syslinux.cfg — it was only added to grub.cfg.

---

## System State After Reboot

### Display Stack

| Check | Result |
|---|---|
| `/proc/cmdline` | `BOOT_IMAGE=/boot/linux ... initrd=/boot/initrd.gz` (Wayland paths) |
| `pgrep -x labwc` | PIDs 2226, 2250 — **Wayland running** |
| `xrandr` | Not found (no X11) |
| `batocera.version` | `43-dev-13c569bd4a 2026/02/16 12:08` |

### Phase 1 Artifacts (all survived reboot)

| Artifact | Status |
|---|---|
| `/boot/crt/linux` | 23 MB — present |
| `/boot/crt/initrd-crt.gz` | 771 KB — present |
| `/boot/crt/batocera` | 3.4 GB — present |
| `/boot/crt/rufomaculata` | 1.2 GB — present |
| `.install_phase` | Contains `2` — present |

### grub.cfg (exists but not in boot path)

```
set default="1"
set timeout="3"

menuentry "Batocera HD (Wayland)" { ... }
menuentry "Batocera CRT (X11)" { ... }
menuentry "Batocera HD (verbose)" { ... }
```

### Boot Partition

```
/dev/nvme0n1p1   10G  8.7G  1.4G  87% /boot
```

Boot partition mounted read-only (`ro`).

---

## Required Fix

The `update_boot_config()` function in `Batocera-CRT-Script-v43.sh` must be rewritten to modify **syslinux.cfg** instead of (or in addition to) `grub.cfg`.

### Changes Needed

1. **`update_boot_config()`** — Modify both syslinux.cfg files:
   - `/boot/EFI/batocera/syslinux.cfg` (EFI)
   - `/boot/boot/syslinux.cfg` (Legacy BIOS)
   - Add a `LABEL crt` entry with `/crt/linux` and `/crt/initrd-crt.gz`
   - Set `DEFAULT crt` to boot CRT on next reboot

2. **`restore_all()`** — Remove CRT entries from syslinux.cfg and restore `DEFAULT batocera`

3. **`mode_switcher.sh`** — If it switches GRUB default, it must switch syslinux `DEFAULT` instead

4. **Optionally keep grub.cfg changes** as a fallback for removable-media boot scenarios

### Syslinux CRT Entry Format

```
LABEL crt
	MENU LABEL Batocera CRT (X11)
	LINUX /crt/linux
	APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
	INITRD /crt/initrd-crt.gz
```

### Setting Default

To boot CRT by default, add `DEFAULT crt` at top of syslinux.cfg (before `UI menu.c32`).
