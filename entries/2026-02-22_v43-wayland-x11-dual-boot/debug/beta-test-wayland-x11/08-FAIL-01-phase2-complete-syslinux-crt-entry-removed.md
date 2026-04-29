# Step 08 — Phase 2 Complete, But CRT Boot Entry Removed from Syslinux

**Date:** 2026-02-21
**Action:** CRT Script ran Phase 2 on X11 — completed CRT display configuration
**Result:** MIXED — All CRT configs written and overlay saved, but the standard CRT flow's `purge_syslinux_variants` destroyed the CRT boot entry in syslinux.cfg

---

## Phase 2 Results — What Worked

### CRT Display Configuration (all successful)

| Config | State |
|---|---|
| `10-monitor.conf` | Created — eDP-1 ignored, DP-1 enabled |
| `20-modesetting.conf` | Created — modesetting DDX, TearFree=false, VRR=false |
| `20-amdgpu.conf` | Renamed to `.bak` (conflict removed) |
| `20-radeon.conf` | Renamed to `.bak` (conflict removed) |
| `switchres.ini` | Configured — monitor=ms929 |
| `/lib/firmware/edid/ms929.bin` | Created (128 bytes) |
| `/boot/boot-custom.sh` | Deployed — generates `15-crt-monitor.conf` at boot |

### Phase 2 Finalization

| Check | State |
|---|---|
| Phase flag | **Deleted** — `NOT SET` |
| CRT overlay | **Created** — `/boot/crt/overlay` (100MB) |
| `batocera-save-crt-overlay` | Present and executable |
| Mode backups | Created — `hd_mode/` and `crt_mode/` directories exist |

---

## BUG: CRT Boot Entry Removed

The standard CRT script flow includes `purge_syslinux_variants` which **completely rewrites** all syslinux.cfg files. This function is designed for single-boot X11 systems — it:

1. **Removed `LABEL crt`** — the CRT boot entry is gone
2. **Removed `DEFAULT crt`** — no longer needed since entry is gone
3. **Restored label names** — back to "Batocera.linux" from "Batocera HD - Wayland"
4. **Changed `MENU HIDDEN` → `MENU SHIFTKEY`**
5. **Changed `TIMEOUT` → 50 (5s)**
6. **Injected CRT kernel params** into the `batocera` APPEND line:
   `mitigations=off usbhid.jspoll=0 xpad.cpoll=0 drm.edid_firmware=DP-1:edid/ms929.bin video=DP-1:e`

### Current syslinux.cfg (both EFI and BIOS — identical)

```
UI menu.c32

TIMEOUT 50
TOTALTIMEOUT 300

SAY Booting Batocera.linux...

MENU CLEAR
MENU TITLE Batocera.linux
MENU SHIFTKEY

LABEL batocera
	MENU DEFAULT
	MENU LABEL Batocera.linux (^normal)
	LINUX /boot/linux
	APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0 mitigations=off  usbhid.jspoll=0 xpad.cpoll=0 drm.edid_firmware=DP-1:edid/ms929.bin video=DP-1:e
	INITRD /boot/initrd.gz

LABEL verbose
	MENU lABEL Batocera.linux (^verbose)
	LINUX /boot/linux
	APPEND label=BATOCERA vt.global_cursor_default=0
	INITRD /boot/initrd.gz
```

No `LABEL crt` entry. After reboot, the system will boot Wayland from `/boot/linux` — not X11 from `/crt/linux`.

### grub.cfg (fallback — not affected)

```
set default="0"
set timeout="3"

menuentry "Batocera HD (Wayland)" { ... }
menuentry "Batocera CRT (X11)" { ... }
menuentry "Batocera HD (verbose)" { ... }
```

grub.cfg still has the CRT entry because `purge_syslinux_variants` doesn't touch grub.cfg.

---

## Root Cause

The standard CRT script flow (designed for single-boot X11) calls `purge_syslinux_variants` which rewrites syslinux.cfg with CRT-specific kernel parameters baked into the stock boot entry. This conflicts with the dual-boot architecture where:
- The `batocera` entry should stay clean (Wayland kernel)
- A separate `crt` entry should exist with CRT kernel params

**Execution order:** `purge_syslinux_variants` runs during the standard install flow → AFTER `update_boot_config()` set up the CRT entry → the CRT entry gets overwritten.

## Required Fix

When `IS_DUALBOOT_INSTALL=true`, the script must either:
1. **Skip `purge_syslinux_variants`** entirely (dual-boot handles syslinux differently), OR
2. **Re-add the CRT entry** after `purge_syslinux_variants` runs, OR
3. **Gate `purge_syslinux_variants`** to not remove `LABEL crt` or overwrite the dual-boot structure

Additionally, the CRT-specific kernel params (`drm.edid_firmware`, `video=`, etc.) should be added to the `LABEL crt` APPEND line, not the `LABEL batocera` line, in a dual-boot scenario.

---

## Disk / Boot State

| Check | Value |
|---|---|
| `/boot` | 10G, 8.7G used, 1.4G free (87%) |
| `/userdata` | 1.8T, 4.6G used, 1.7T free |
| `/boot/crt/overlay` | 100 MB |
| `/boot/crt/` files | All 4 present (batocera, linux, initrd-crt.gz, rufomaculata) |
