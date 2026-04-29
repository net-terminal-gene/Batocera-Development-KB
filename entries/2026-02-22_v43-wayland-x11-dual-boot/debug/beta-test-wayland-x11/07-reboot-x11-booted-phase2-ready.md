# Step 07 — Reboot: X11 Booted Successfully — Phase 2 Ready

**Date:** 2026-02-21
**Action:** System rebooted after Phase 1 completion (syslinux fix)
**Result:** SUCCESS — system booted into X11 via the CRT syslinux entry

---

## Boot Verification

| Check | Value |
|---|---|
| `/proc/cmdline` | `BOOT_IMAGE=/crt/linux ... initrd=/crt/initrd-crt.gz` |
| `labwc` (Wayland) | Not running |
| `xrandr` | Present at `/usr/bin/xrandr` (empty output — no DISPLAY set over SSH) |
| `batocera.version` | `43-dev-13c569bd4a 2026/02/16 18:50` |

The kernel booted from `/crt/linux` with `/crt/initrd-crt.gz` — confirming syslinux `DEFAULT crt` worked correctly.

## OverlayFS Mounts

```
/boot/crt/batocera on /overlay/base type squashfs (ro)
/boot/crt/rufomaculata on /overlay/base2 type squashfs (ro)
```

The patched initrd correctly mounted the X11 squashfs files from `/boot/crt/` instead of `/boot/boot/`. This confirms the `sed 's|/boot_root/boot/|/boot_root/crt/|g'` initrd patch is working.

## Build Comparison

| Property | Step 00 (Wayland) | Step 07 (X11) |
|---|---|---|
| Version string | `43-dev-13c569bd4a 2026/02/16 12:08` | `43-dev-13c569bd4a 2026/02/16 18:50` |
| Display stack | labwc (Wayland) | X11 |
| `xrandr` | Missing | Present |
| Squashfs source | `/boot/boot/` | `/boot/crt/` |
| `switchres.ini` | Absent | Present |

Different build timestamp (12:08 vs 18:50) confirms this is the X11 image, not the Wayland one.

## X11 Configuration Files

```
/etc/X11/xorg.conf.d/
├── 20-amdgpu.conf
├── 20-radeon.conf
├── 80-nvidia-egpu.conf
├── 99-avoid-joysticks.conf
└── 99-nvidia.conf
```

These are the stock X11 xorg configs from the vanilla X11 v43 build. Phase 2 will add `10-monitor.conf`, `15-crt-monitor.conf` (via `boot-custom.sh`), and `20-modesetting.conf`.

## Phase Flag

```
/userdata/system/Batocera-CRT-Script/.install_phase = 2
```

Phase 2 is armed. The next run of the CRT Script will detect this flag and enter Phase 2 (CRT display configuration) instead of Phase 1.

## Disk Space

```
/boot    10G  8.7G  1.4G  87%
/userdata 1.8T  4.6G  1.7T   1%
```

---

## Next Step

Re-run the CRT Script from this X11 environment. It will detect the phase flag (`2`), skip Phase 1, and proceed with CRT display configuration (Phase 2).
