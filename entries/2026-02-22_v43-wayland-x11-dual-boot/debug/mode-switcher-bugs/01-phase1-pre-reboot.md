# Phase 1 Pre-Reboot — 2026-02-22 00:16 UTC

**Purpose:** State snapshot after Phase 1 completes on Wayland, before shutdown/power-on into X11 CRT.

## System State

| Item | Value |
|------|-------|
| Uptime | 6 minutes |
| Kernel | 6.18.9 (Wayland) |
| Boot image | `/boot/linux` (Wayland — still running from Phase 1) |
| Dual-boot | YES (`/boot/crt/linux` and `initrd-crt.gz` both present) |

## Syslinux Configuration

- `DEFAULT crt` — next boot will go to CRT/X11
- Three entries: `batocera` (HD Wayland normal), `verbose` (HD Wayland verbose), `crt` (CRT X11 — marked DEFAULT)
- CRT entry uses `/crt/linux` and `/crt/initrd-crt.gz`

## Boot Partition `/boot/crt/`

```
-rwxr-xr-x  batocera        (3.4 GB — X11 squashfs image)
-rwxr-xr-x  initrd-crt.gz   (771 KB)
-rwxr-xr-x  linux           (23 MB — X11 kernel)
-rwxr-xr-x  rufomaculata    (1.2 GB)
```

All files dated 2026-02-22 00:14 (created during Phase 1).

## batocera.conf

No `global.videomode`, `CRT.videomode`, or `es.resolution` entries yet — expected, Phase 2 sets these.

## File State

| File | Status |
|------|--------|
| `crt-launcher.sh` | Present, 644 perms (Phase 2 will chmod 755) |
| `es_systems_crt.cfg` (installed) | NOT INSTALLED YET (Phase 2 copies it) |
| `boot-custom.sh` | NOT FOUND (Phase 2 / mode_switcher creates it) |
| Wayland overlay | Does not exist |
| CRT overlay | Does not exist |

## Assessment

Phase 1 completed successfully. Dual-boot structure is in place. System ready for shutdown, then power-on into X11 CRT for Phase 2.
