# Step 06 — Syslinux Fix: Phase 1 Re-run (Pre-Reboot)

**Date:** 2026-02-21
**Action:** Re-ran Phase 1 with fixed `update_boot_config()` that modifies syslinux.cfg instead of grub.cfg
**Context:** After 06-FAIL-01 (GRUB was never in the boot path), the script was rewritten to target syslinux as the primary bootloader. Phase flag was manually cleared, updated script was transferred, and Phase 1 was re-run.

---

## Script Flow (from terminal output)

1. **Wayland detected** — entered Phase 1
2. **Image found** — `/userdata/batocera-x86_64-43-20260217.img.gz` (4.3G)
3. **MD5 validated** — `3df140b6ca617e1614397e9d8e204b92` matched
4. **Disk space check** — `/userdata` 1725GB free OK; `/boot/crt/` already populated — skipped (new idempotency logic)
5. **Extraction** — re-extracted (idempotency fix for extraction was added after this run)
6. **initrd patched** — 10 path references patched, 0 remaining
7. **Boot config updated (syslinux)** — all 3 syslinux.cfg files + grub.cfg fallback
8. **Overlay script deployed** — `batocera-save-crt-overlay`
9. **Waiting at cleanup prompt** — delete source image or keep

---

## Syslinux.cfg State (EFI — `/boot/EFI/batocera/syslinux.cfg`)

```
DEFAULT crt
UI menu.c32

TIMEOUT 30
TOTALTIMEOUT 300

SAY Booting Batocera.linux...

MENU CLEAR
MENU TITLE Batocera.linux

LABEL batocera
	MENU LABEL Batocera HD - Wayland (^normal)
	LINUX /boot/linux
	APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
	INITRD /boot/initrd.gz

LABEL verbose
	MENU lABEL Batocera HD - Wayland (^verbose)
	LINUX /boot/linux
	APPEND label=BATOCERA vt.global_cursor_default=0
	INITRD /boot/initrd.gz

LABEL crt
	MENU DEFAULT
	MENU LABEL Batocera CRT (X11)
	LINUX /crt/linux
	APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
	INITRD /crt/initrd-crt.gz
```

**Key changes from stock:**
- `DEFAULT crt` added at top
- `MENU HIDDEN` removed (menu now visible)
- `TIMEOUT 30` (was 10 = 1s, now 3s)
- Labels renamed to "Batocera HD - Wayland"
- `MENU DEFAULT` moved from `batocera` to `crt`
- CRT entry appended with `/crt/linux` and `/crt/initrd-crt.gz`

BIOS syslinux.cfg (`/boot/boot/syslinux.cfg`) and legacy path (`/boot/boot/syslinux/syslinux.cfg`) are identical.

## grub.cfg Fallback (`/boot/EFI/BOOT/grub.cfg`)

```
set default="1"
set timeout="3"

menuentry "Batocera HD (Wayland)" { ... }
menuentry "Batocera CRT (X11)" { ... }
menuentry "Batocera HD (verbose)" { ... }
```

Unchanged from previous run — already had CRT entry from step 04.

## /boot/crt/ Contents

| File | Size |
|---|---|
| `batocera` | 3.4 GB |
| `initrd-crt.gz` | 771 KB |
| `linux` | 23 MB |
| `rufomaculata` | 1.2 GB |

## Other State

| Check | Value |
|---|---|
| Phase flag | **NOT SET** (script hasn't written it yet — still at cleanup prompt) |
| `/boot` | 10G, 8.7G used, 1.4G free (87%) |
| `/userdata` | 1.8T, 4.6G used, 1.7T free |

---

## What's Different from Step 04

| Area | Step 04 (failed approach) | Step 06 (fixed) |
|---|---|---|
| Primary boot config | grub.cfg only | syslinux.cfg (all 3 copies) |
| `DEFAULT` mechanism | `set default="1"` in grub.cfg | `DEFAULT crt` + `MENU DEFAULT` in syslinux.cfg |
| Menu visibility | N/A (GRUB had `timeout="3"`) | `MENU HIDDEN` removed, `TIMEOUT 30` |
| grub.cfg | Primary | Fallback only |

## Next Step

User will choose cleanup option (delete or keep source image), then the script writes the phase flag and prompts for reboot. This time, syslinux should boot into X11.
