# Step 09 — Phase 2 Complete (Syslinux Fix Applied), Pre-Reboot

**Date:** 2026-02-21
**Action:** Phase 2 ran on fresh reflash with syslinux overwrite fix applied
**Result:** SUCCESS — All CRT configs written, overlay saved, and **CRT boot entry preserved** in all syslinux.cfg files

---

## Fix Verified

The syslinux template overwrite (lines 4444-4498) is now gated behind `IS_DUALBOOT_INSTALL`. When `true`, the script injects CRT kernel params into the existing `LABEL crt` APPEND line via `awk` instead of overwriting the entire syslinux.cfg with the single-boot template.

**Before fix (step 08):** Template overwrite destroyed `LABEL crt`, injected CRT params into `LABEL batocera`.
**After fix (step 09):** `LABEL crt` preserved, CRT params in CRT entry only, Wayland entry clean.

---

## System State

| Check | Value |
|---|---|
| Version | `43-dev-13c569bd4a 2026/02/16 18:50` |
| Display stack | X11 (booted via CRT syslinux entry) |
| Kernel cmdline | `BOOT_IMAGE=/crt/linux label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0 initrd=/crt/initrd-crt.gz` |
| Phase flag | **NOT SET** (Phase 2 finalization deleted it) |

---

## Syslinux — All 3 Copies Correct (Identical)

Files: `/boot/EFI/batocera/syslinux.cfg`, `/boot/boot/syslinux.cfg`, `/boot/boot/syslinux/syslinux.cfg`

```
DEFAULT batocera
UI menu.c32

TIMEOUT 30
TOTALTIMEOUT 300

SAY Booting Batocera.linux...

MENU CLEAR
MENU TITLE Batocera.linux

LABEL batocera
	MENU DEFAULT
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
	MENU LABEL Batocera CRT (X11)
	LINUX /crt/linux
	APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0 mitigations=off  usbhid.jspoll=0 xpad.cpoll=0 drm.edid_firmware=DP-1:edid/ms929.bin video=DP-1:e
	INITRD /crt/initrd-crt.gz
```

Key points:
- `DEFAULT batocera` — Wayland boots by default (Phase 2 reset this)
- `MENU DEFAULT` on `LABEL batocera` — menu cursor defaults to Wayland
- `TIMEOUT 30` (3 seconds) — boot menu visible
- `LABEL crt` **preserved** with CRT kernel params in APPEND
- Wayland APPEND **clean** — no CRT params injected

## grub.cfg (Fallback)

```
set default="0"
set timeout="3"

menuentry "Batocera HD (Wayland)" { ... }
menuentry "Batocera CRT (X11)" { ... }
menuentry "Batocera HD (verbose)" { ... }
```

Default index 0 (Wayland). CRT entry present at index 1.

---

## CRT Display Configuration

| Config | State |
|---|---|
| `10-monitor.conf` | Created — eDP-1 ignored, DP-1 enabled |
| `20-modesetting.conf` | Created — modesetting DDX, TearFree=false, VRR=false |
| `20-amdgpu.conf` | Renamed to `.bak` (conflict removed) |
| `20-radeon.conf` | Renamed to `.bak` (conflict removed) |
| `switchres.ini` | Configured — monitor=ms929 |
| `/lib/firmware/edid/ms929.bin` | Created (128 bytes) |
| `/boot/boot-custom.sh` | Deployed — generates `15-crt-monitor.conf` at boot |

---

## Boot / Disk State

| Check | Value |
|---|---|
| `/boot` | 10G, 8.9G used, 1.2G free (89%) |
| `/userdata` | 1.8T, 4.7G used, 1.7T free (1%) |
| `/boot/crt/batocera` | 3.4 GB (squashfs) |
| `/boot/crt/linux` | 23 MB (kernel) |
| `/boot/crt/initrd-crt.gz` | 771 KB (patched initrd) |
| `/boot/crt/rufomaculata` | 1.2 GB |
| `/boot/crt/overlay` | 100 MB (CRT config overlay) |
| `batocera-save-crt-overlay` | Present and executable |

---

## Mode Switcher

| Check | State |
|---|---|
| `crt_mode/` directory | **MISSING** |
| `hd_mode/` directory | **MISSING** |

Mode backup directories not created. This may need investigation — the mode_switcher install logic should create these during the CRT install flow.

---

## Next Step

Reboot. System should boot into Wayland by default (syslinux `DEFAULT batocera`). User can select "Batocera CRT (X11)" from the 3-second boot menu to boot into CRT mode with EDID firmware loaded.
