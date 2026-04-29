# Vanilla X11 v43 Live System — Findings

**Date:** 2026-02-20
**Image:** `batocera-x86_64-43-20260217.img.gz` — standard x86_64 build, no CRT Script installed
**System:** Batocera 43-dev-13c569bd4a — kernel 6.18.9
**SSH source:** `batocera.local`
**Purpose:** Answer the three open questions from `x11-image-extraction-and-boot-requirements.md`
and establish a clean baseline of what exists before the CRT Script runs on a vanilla X11 v43 build.

---

## System Identity

```
Batocera.linux 43-dev-13c569bd4a  2026/02/16 18:50
Kernel: 6.18.9 #1 SMP PREEMPT_DYNAMIC Mon Feb 16 19:09:26 2026 x86_64
Board: x86_64 (standard build — NOT the x86-64-v3 variant)
Display server: Xorg :0 running on tty2
```

---

## Open Questions — Answered

### ✅ Open Question 1: Does `/lib/firmware/edid/` exist on vanilla X11 v43?

**Answer: NO.**

```
ls /lib/firmware/edid
→ (no such directory)
```

`/lib/firmware/` is present and contains hundreds of firmware files (amd, amdgpu, radeon,
nvidia, iwlwifi, etc.) but there is no `edid/` subdirectory anywhere inside it.

**Phase 2 requirement confirmed:** `mkdir -p /lib/firmware/edid` must run before writing
any EDID binary. This write goes into the tmpfs overlay and must be persisted via
`batocera-save-crt-overlay`.

---

### ✅ Open Question 2: Are `drm.edid_firmware=` kernel params required in the GRUB CRT entry?

**Answer: No — not for Phase 1. Connector-specific, handled in Phase 2.**

`/proc/cmdline` on this vanilla X11 v43 boot:
```
BOOT_IMAGE=/boot/linux label=BATOCERA console=tty3 quiet loglevel=0
vt.global_cursor_default=0 initrd=/boot/initrd.gz
```

No `drm.edid_firmware=` or `video=` parameters. Xorg starts successfully without them
and xrandr queries display outputs correctly:

```
DISPLAY=:0 xrandr --query:
  eDP-1 connected primary 1280x800+0+0   (internal display — active)
  DP-1 disconnected                       (external CRT port — no monitor connected)
```

**Context on v42:** The `drm.edid_firmware=DP-1:edid/ms929.bin` param seen on the v42
live system was there because Phase 2 of the CRT Script had already run and written it
into `syslinux.cfg`. That was a post-install state, not a vanilla state.

**When EDID kernel params are needed:** They are required only when a CRT monitor's
native EDID is missing or reports incorrect capabilities and the custom EDID must be
force-loaded by the kernel before DRM initializes — before userspace starts. This is
monitor-specific and connector-specific.

**Correct approach:** The Phase 1 GRUB CRT entry is written without `drm.edid_firmware=`
because the connector name is not yet known. During Phase 2, after xrandr identifies the
CRT connector (e.g., `DP-1`), the CRT Script determines whether the kernel param is
needed for that monitor and — if so — updates the GRUB CRT entry at that time.

---

### ✅ Open Question 3: How did the boot partition get to 10GB?

**Answer: Batocera v43 creates a 10GB boot partition by default on fresh flash.**

```
parted /dev/nvme0n1 print:
  1  1049kB  10.7GB  10.7GB  fat32  vfat  legacy_boot, msftdata
  2  10.7GB  2000GB  1990GB  ext4   userdata

df -h /boot:
  /dev/nvme0n1p1  10G  4.4G  5.7G  44%  /boot
```

This is a fresh vanilla flash on a 1.8TB NVMe drive. The 10GB boot partition is the v43
default layout — confirmed on both the Wayland v43 and this X11 v43 build. The ~1GB
boot partition from older Batocera versions is no longer the norm in v43.

**Space math confirmed — no resize needed:**

| Item | Size |
|---|---|
| Wayland boot files (already on drive) | 4.4GB |
| Boot partition free space | 5.7GB |
| CRT files needed (batocera + rufomaculata + linux + initrd-crt.gz) | ~4.4GB |
| Remaining after CRT install | ~1.3GB |

The 10GB default boot partition accommodates both builds with margin to spare.

---

## Binary Audit: Vanilla X11 v43

| Binary | Present? | Notes |
|---|---|---|
| `switchres` | ✅ `/usr/bin/switchres` | version 2.2.1 |
| `xrandr` | ✅ `/usr/bin/xrandr` | functional on running Xorg |
| `libswitchres.so` | ✅ | `.so`, `.so.2`, `.so.2.2.1` — all three symlinks present |
| `geometry` | ✅ `/usr/bin/geometry` | present |
| `grid` | ✅ `/usr/bin/grid` | present |
| `batocera-resolution` | ✅ | xrandr variant — confirmed correct |
| `edid-decode` | ✅ `/usr/bin/edid-decode` | present |

All CRT binaries are present in the vanilla X11 v43 squashfs. No binary installation
is required by the CRT Script — everything the CRT stack needs is already there.

### batocera-resolution — xrandr variant confirmed

```bash
#!/bin/sh
...
PSCREEN=$(xrandr --listPrimary)   ← xrandr call on line 19
```

This is the X11/xorg variant, not the Wayland `wlr-randr` variant. Correct for CRT.

---

## /etc/switchres.ini — Present with Defaults

Unlike the Wayland build (where the file was completely absent), the vanilla X11 v43
squashfs ships a full `switchres.ini` with sensible defaults:

```
monitor    arcade_15     ← 15kHz CRT preset — appropriate default
api        auto          ← auto-selects xrandr on X11
display    auto
modeline_generation    1
interlace              1
```

**Phase 2 implication:** The CRT Script does not create `switchres.ini` from scratch.
It overwrites/modifies the existing file with the user's specific monitor profile
(connector, HorizSync/VertRefresh ranges, crt_range values, etc.).

---

## IMPORTANT: 20-amdgpu.conf Is an x86 Board Config — Not Wayland-Specific

The vanilla X11 v43 squashfs ships this `20-amdgpu.conf`:

```
Section "OutputClass"
     Identifier "Fix AMD Tearing and add VRR"
     Driver "amdgpu"
     MatchDriver "amdgpu"
     Option "TearFree" "true"
     Option "VariableRefresh" "true"
EndSection
```

### Source and History (confirmed from `batocera.linux` git log)

This file lives in **`board/batocera/x86/fsoverlay/etc/X11/xorg.conf.d/`** — the x86
board overlay that is applied to **all x86 builds**, both X11 and Wayland. There is one
copy of the file, shared across all x86 architecture variants.

Complete commit history:

| Date | Commit | Change |
|---|---|---|
| 2021-03-01 | `38aaf5d0e3` | Original — `TearFree=true` for AMD Ryzen APU tearing fix |
| 2021-03-05 | `2b1479a489` | Renamed `amdgpu.conf` → `20-amdgpu.conf` |
| 2021-03-06 | `6e757dc6b3` | Made GPU-specific with `MatchDriver "amdgpu"` |
| 2025-01-08 | `7e40350475` | Added `VariableRefresh=true` for modern VRR gaming monitors |

**`TearFree=true`** has been in x86 builds since March 2021 — v30/v31 era — long before
Wayland was part of Batocera. It was introduced to fix a well-known AMD Ryzen APU screen
tearing issue on X11.

**`VariableRefresh=true`** was added January 8, 2025 during the v42 development cycle, for
AMD FreeSync/VRR gaming monitors. Commit note: *"requires a vrr monitor."*

**This config is not a Wayland artifact.** It ships in every x86 Batocera build (X11 and
Wayland alike) because it targets AMD GPU hardware behavior at the driver level. Seeing
the same config on both the Wayland v43 and X11 v43 systems is expected and correct.

### Why It Conflicts with CRT Mode

CRT monitors are fixed-frequency analog displays. They do not support:
- **`TearFree=true`**: Requires double-buffering in the GPU, which alters sync timing and
  prevents the precise modeline control that CRT mode needs.
- **`VariableRefresh=true`**: FreeSync/VRR dynamically adjusts refresh rate. CRT mode sets
  exact, fixed refresh rates (e.g., 50Hz, 60Hz, 15kHz) via modelines. VRR mode and fixed
  CRT modelines are mutually incompatible.

Additionally, `Driver "amdgpu"` (the AMD DDX driver) conflicts with CRT mode. CRT mode
requires `Driver "modesetting"` (the generic KMS/DRM driver) which gives switchres direct
control over mode timings.

### Phase 2 Must Handle This

The CRT Script must replace `20-amdgpu.conf` on the X11 CRT boot regardless of Batocera
version, because this config ships in all v42+ x86 builds:

1. Rename `/etc/X11/xorg.conf.d/20-amdgpu.conf` → `20-amdgpu.conf.bak`
2. Write `/etc/X11/xorg.conf.d/20-modesetting.conf`:
   ```
   Section "OutputClass"
       Identifier "AMD via modesetting (amdgpu)"
       MatchDriver "amdgpu"
       Driver "modesetting"
       Option "TearFree" "false"
       Option "VariableRefresh" "false"
   EndSection
   ```
3. Both changes go into the tmpfs overlay and must be saved via `batocera-save-crt-overlay`.

---

## Boot Partition — Vanilla State

```
/boot/
├── boot/
│   ├── batocera           (3.2GB — X11 OS squashfs)
│   ├── batocera.board     ("x86_64")
│   ├── initrd.gz          (standard initramfs — paths hardcoded to /boot_root/boot/)
│   ├── linux              (22MB — kernel 6.18.9)
│   ├── rufomaculata       (1.1GB — board/arch squashfs)
│   └── syslinux/
│       └── syslinux.cfg   (legacy BIOS — not active on EFI machines)
└── EFI/BOOT/
    ├── BOOTX64.EFI
    └── grub.cfg           (active boot config on EFI)

NOT present (expected on clean install):
  /boot/boot-custom.sh
  /boot/boot/overlay
  /boot/crt/
```

---

## Kernel Version: X11 vs Wayland — Matched

Both the X11 and Wayland v43 builds run **kernel 6.18.9** built `Mon Feb 16 19:09:26 2026`.
The kernel versions are identical. Module compatibility between the Wayland kernel and X11
squashfs is not a concern for same-date builds, but the X11 kernel is still used in the
CRT GRUB entry for correctness and safety.

---

## Architecture Variant Note

| Build | `batocera.board` | Target |
|---|---|---|
| Wayland v43 (previous investigation) | `x86-64-v3` | Zen 3+ / Intel 11th gen+ CPUs |
| X11 v43 standard (this investigation) | `x86_64` | Any x86_64 CPU |

These are different architecture variants with different CPU optimizations in `rufomaculata`.
A user running the x86-64-v3 Wayland build should use the x86-64-v3 X11 build for CRT mode
to maintain consistent CPU optimization levels. The CRT Script should read `/boot/boot/batocera.board`
to determine which X11 image variant to download or validate.

---

## Summary: What This Changes in the Architecture

| Prior assumption | Corrected finding |
|---|---|
| "`/lib/firmware/edid/` absent only on Wayland" | Absent on vanilla X11 v43 too — Phase 2 must create it |
| "`drm.edid_firmware=` needed in Phase 1 GRUB entry" | Not for Phase 1 — connector-specific, added in Phase 2 if needed |
| "Boot partition resize may be required" | Non-issue — v43 default is 10GB; 5.7GB free is sufficient |
| "`20-amdgpu.conf` conflict is a Wayland-specific problem" | No — it's an x86 board config shipping in ALL x86 builds since v42. Phase 2 must handle it regardless of source build. |
| "`/etc/switchres.ini` must be created from scratch" | File already exists with defaults — Phase 2 modifies it |
