# X11 Image Extraction & Boot Requirements

**Date:** 2026-02-20
**Systems investigated:** Batocera v43-dev Wayland (live SSH) + vanilla X11 v43 (live SSH)
**Companion docs:** `wayland-v43-live-findings.md`, `vanilla-x11-v43-live-findings.md`, `official-official-dual-boot-grub-architecture.md`

---

## What This Document Covers

The `official-official-dual-boot-grub-architecture.md` describes the high-level plan. This document goes
one layer deeper: what exactly must be extracted from the X11 `.img.gz` disk image, what
the script must generate or patch, and what must be written and persisted for resolution
switching to work after every reboot into CRT mode.

---

## Structure of the X11 Disk Image

`batocera-x86_64-43-YYYYMMDD.img.gz` is a gzip-compressed raw disk image. It contains
a full GPT partition table with two partitions:

```
Partition 1  ~10GB  VFAT  label=BATOCERA   → boot files (squashfs, kernel, initrd)
Partition 2  rest   ext4  label=SHARE      → userdata (empty on a fresh image)
```

Within the VFAT partition, the relevant directory tree is:

```
boot/
├── batocera          ← X11 OS squashfs   (~3.2GB)
├── rufomaculata      ← board/arch squashfs (~1.1GB)
├── linux             ← kernel binary      (~23MB)
├── initrd.gz         ← initramfs          (~751KB)
├── batocera.board    ← text: "x86_64" or "x86-64-v3" depending on build variant
└── syslinux/         ← legacy BIOS files (not needed)
EFI/BOOT/
├── BOOTX64.EFI       ← shim (not needed)
├── grub.cfg          ← NOT extracted (we write our own CRT entry)
└── ...
```

Only the files listed below need to be extracted. Nothing else.

---

## What to Extract and Where It Goes

All CRT boot files are placed in `/boot/crt/` (a new directory on the shared VFAT
partition, separate from `/boot/boot/` which holds the Wayland boot files):

| Source (inside VFAT partition of image) | Destination on live drive |
|---|---|
| `boot/batocera`     | `/boot/crt/batocera`      |
| `boot/rufomaculata` | `/boot/crt/rufomaculata`  |
| `boot/linux`        | `/boot/crt/linux`         |
| `boot/initrd.gz`    | `/boot/crt/initrd-src.gz` (staging only — see below) |

**Why extract the kernel separately?**
Kernel modules live inside the squashfs at `/lib/modules/<kernel-version>/`. If the X11
and Wayland builds use slightly different kernel versions (possible across different beta
build dates), booting the X11 squashfs with the Wayland kernel causes module version
mismatches. Using the kernel from the same image as the squashfs guarantees compatibility.

**What is NOT extracted:**
- The EFI boot files (BOOTX64.EFI, etc.) — the Wayland GRUB is reused
- The X11 grub.cfg — we add a CRT entry to the Wayland grub.cfg instead
- Partition 2 (userdata) — the live `/userdata` is shared between both boots

---

## Extraction Process (Script Logic)

The `.img.gz` image cannot be mounted directly — it must be decompressed first, then
the correct partition offset identified and loop-mounted.

```bash
# 1. Decompress (to a temp location with enough space)
gunzip -k "$IMAGE_PATH"   # keep original, output: batocera-x86_64-43-YYYYMMDD.img

# 2. Find VFAT partition offset
SECTOR_SIZE=512
VFAT_START=$(parted -s "$IMG" unit s print | awk '/fat32/{print $2}' | tr -d 's')
OFFSET=$((VFAT_START * SECTOR_SIZE))

# 3. Mount VFAT partition read-only
mkdir -p /tmp/crt-img-mount
mount -o loop,ro,offset=$OFFSET "$IMG" /tmp/crt-img-mount

# 4. Create destination directory
mkdir -p /boot/crt

# 5. Copy required files
cp /tmp/crt-img-mount/boot/batocera     /boot/crt/batocera
cp /tmp/crt-img-mount/boot/rufomaculata /boot/crt/rufomaculata
cp /tmp/crt-img-mount/boot/linux        /boot/crt/linux
cp /tmp/crt-img-mount/boot/initrd.gz    /boot/crt/initrd-src.gz

# 6. Unmount and clean up temp image
umount /tmp/crt-img-mount
rm "$IMG"   # remove decompressed image; keep original .img.gz or prompt to trash
```

Space check before extraction is required — see Boot Partition Space section below.

---

## Creating initrd-crt.gz (The Critical Patch)

The standard Batocera `initrd.gz` contains a single `init` script (BusyBox ash) that
**hardcodes `/boot_root/boot/` as the path to squashfs and overlay files**. It cannot
boot from `/boot/crt/` without modification.

The init script logic confirmed from live system and `batocera.linux` source:

```ash
# Squashfs mounts — hardcoded path
mount /boot_root/boot/batocera /overlay_root/base
if test -e /boot_root/boot/rufomaculata; then
    mount /boot_root/boot/rufomaculata /overlay_root/base2
fi

# Overlay persistence — hardcoded path
if test -f /boot_root/boot/overlay; then
    if mount -o ro /boot_root/boot/overlay /overlay_root/saved; then
        cp -pr /overlay_root/saved/* /overlay_root/overlay
        umount /overlay_root/saved
    fi
fi

# Squashfs update mechanism — hardcoded path
for SIMG in batocera rufomaculata; do
    if test -e /boot_root/boot/${SIMG}.update; then
        mv /boot_root/boot/${SIMG}.update /boot_root/boot/${SIMG}
        if test -e /boot_root/boot/overlay; then
            mv /boot_root/boot/overlay /boot_root/boot/overlay.old
        fi
    fi
done
```

**Every occurrence of `/boot_root/boot/` must become `/boot_root/crt/`.**

### Patch Script

```bash
# Extract initrd
cd /tmp/initrd-crt-work
mkdir initrd-extracted
cd initrd-extracted
cp /boot/crt/initrd-src.gz /tmp/initrd-crt-work/initrd.gz
gunzip /tmp/initrd-crt-work/initrd.gz
cpio -id < /tmp/initrd-crt-work/initrd

# Patch init script — replace all boot path references
sed -i 's|/boot_root/boot/|/boot_root/crt/|g' init

# Repack
find . | cpio -H newc -o | gzip > /boot/crt/initrd-crt.gz

# Clean up staging files
rm /boot/crt/initrd-src.gz
```

Result: `/boot/crt/initrd-crt.gz` — a modified initrd that mounts squashfs from
`/boot_root/crt/batocera` and looks for its persistent overlay at `/boot_root/crt/overlay`.

---

## Updating Boot Configs — GRUB and Syslinux

The CRT Script must detect whether the machine boots via EFI or Legacy BIOS and update
the correct config file. Both configs use paths relative to the VFAT partition root (not
the mounted filesystem path), so `/boot/crt/linux` on the running system = `/crt/linux`
in the boot config.

### EFI Detection

```bash
if [ -d /sys/firmware/efi ]; then
    BOOT_MODE="efi"
else
    BOOT_MODE="bios"
fi
```

### GRUB Entry (EFI machines — appended to `/boot/EFI/BOOT/grub.cfg`)

```
menuentry "Batocera.linux CRT Mode (X11)" {
    echo Booting Batocera.linux... CRT Mode (X11)
    linux /crt/linux label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
    initrd /crt/initrd-crt.gz
}
```

Note: CRT kernel parameters (`drm.edid_firmware=`, `video=`) are NOT in grub.cfg.
They are written at CRT boot time by `boot-custom.sh` to the kernel command line at next
reboot, OR handled entirely in userspace via `xrandr` after the session starts. The
exact mechanism depends on whether EDID firmware injection is required for the specific
monitor/connector — to be confirmed in Phase 2.

### Syslinux Entry (Legacy BIOS machines — appended to `/boot/boot/syslinux/syslinux.cfg`)

```
LABEL crt
    MENU LABEL Batocera.linux (CRT Mode X11)
    LINUX /crt/linux
    APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
    INITRD /crt/initrd-crt.gz
```

### Default Boot Entry

Wayland remains the default. The CRT entry is added but NOT set as default during Phase 1.
`mode_switcher.sh` changes the default (sets `default="0"` vs `default="2"` in grub.cfg
or changes `MENU DEFAULT` in syslinux.cfg).

---

## The Overlay Persistence Problem (CRITICAL GAP)

This is the most significant undocumented constraint discovered during live investigation.

### How Batocera Persists Overlay Changes

Batocera runs its root filesystem as an **overlayFS on tmpfs**. The writable upper layer
lives in RAM and is lost on reboot by default. To persist changes (Xorg configs,
`switchres.ini`, patched `batocera-resolution`, etc.), Batocera uses:

**`batocera-save-overlay`** — a script that:
1. Creates a 100MB ext4 filesystem image at `/boot/boot/overlay` (if it doesn't exist)
2. `rsync -av --delete` the current tmpfs upper layer → into that image
3. On next boot, the initrd mounts this image and `cp -pr` its contents to the tmpfs layer

This is confirmed from live inspection of `/usr/bin/batocera-save-overlay`:

```bash
OVERLAYFILE="/boot/boot/overlay"   # ← HARDCODED
OVERLAYRAM="/overlay/overlay"
OVERLAYSIZE=100  # MB

# Creates ext4 image if missing
dd if=/dev/zero of="${OVERLAYFILE}" bs=${OVERLAYSIZE}M count=1
mkfs.ext4 "${OVERLAYFILE}"

# Syncs current RAM state to disk
rsync -av --delete --exclude="/.cache" "${OVERLAYRAM}/" "${OVERLAYMOUNT}"
```

### The Problem for CRT Mode

**`/boot/boot/overlay` is the Wayland boot's overlay.** If Phase 2 (running in X11 CRT
mode) calls the stock `batocera-save-overlay`, it saves the X11 state to
`/boot/boot/overlay` — the Wayland boot's overlay file. On next Wayland boot, the CRT
configs (Xorg, switchres.ini, etc.) would overwrite the Wayland environment.

**Each boot path must have its own overlay file:**

| Boot | Overlay file |
|---|---|
| Wayland (HD mode) | `/boot/boot/overlay` — stock location, unchanged |
| X11 (CRT mode)    | `/boot/crt/overlay` — new, separate overlay file |

### Required: `batocera-save-crt-overlay`

The CRT Script must deploy a modified overlay save script that targets `/boot/crt/overlay`.
This script must be callable from the X11 session after Phase 2 completes:

```bash
#!/bin/sh
# batocera-save-crt-overlay — saves X11 CRT overlay to /boot/crt/overlay
OVERLAYFILE="/boot/crt/overlay"   # ← CRT-specific path
OVERLAYMOUNT="/overlay/saved"
OVERLAYRAM="/overlay/overlay"
OVERLAYSIZE=100  # M

# rest is identical to batocera-save-overlay
```

**Placement:** `/userdata/system/Batocera-CRT-Script/batocera-save-crt-overlay`

This is on the shared userdata partition and is available from both boots. Phase 2 calls
it at the end of the install, and the mode_switcher can call it when switching back from
CRT to HD mode (to snapshot current CRT state before booting Wayland).

### initrd-crt.gz already handles this

Because the `init` patch replaces ALL occurrences of `/boot_root/boot/` with
`/boot_root/crt/`, the CRT initrd will automatically look for its overlay at
`/boot_root/crt/overlay` — which is exactly where `batocera-save-crt-overlay` writes it.
The two pieces are consistent without any additional coordination.

---

## Phase 2: What Must Be Written and Persisted

After the first reboot into X11 CRT mode, Phase 2 of the CRT Script runs. Everything
Phase 2 writes goes into the tmpfs upper overlay layer. It is lost on reboot unless
`batocera-save-crt-overlay` is called before shutdown.

Phase 2 must:

### Step 1 — Verify X11 environment
```bash
if ! which xrandr > /dev/null 2>&1; then
    echo "ERROR: xrandr not found. Are you booted into CRT mode?"
    exit 1
fi
```

### Step 2 — Detect display connector
```bash
xrandr --query   # shows connected outputs: DP-1, HDMI-1, eDP-1, etc.
```
Output connector name is written to `/var/run/drmConn` and used in all subsequent steps.

### Step 3 — Create /lib/firmware/edid/ (CONFIRMED ABSENT on vanilla X11 v43)
```bash
mkdir -p /lib/firmware/edid
```
Confirmed absent on both the Wayland v43 build and the vanilla X11 v43 build (live SSH,
`batocera-x86_64-43-20260217.img.gz`). This directory does not exist in any fresh v43
squashfs. Phase 2 must always create it before writing the EDID binary.

### Step 4 — Write EDID binary
```bash
# EDID binary generated by switchres for the detected connector
switchres ... > /lib/firmware/edid/custom.bin
```

### Step 5 — Update /etc/switchres.ini (user monitor profile)
`/etc/switchres.ini` already exists on the vanilla X11 v43 squashfs with working defaults
(`monitor arcade_15`, `api auto`, `modeline_generation 1`, `interlace 1`). Phase 2 does
not create this file from scratch — it overwrites it with the user's specific monitor
profile (connector, HorizSync/VertRefresh ranges, crt_range values) based on the monitor
selection made during Phase 1.

### Step 6 — Write Xorg configs
```bash
# 10-monitor.conf — sets output and enables it
cat > /etc/X11/xorg.conf.d/10-monitor.conf << EOF
Section "Monitor"
    Identifier "<connector>"
    Option "Enable" "true"
EndSection
EOF

# 20-modesetting.conf — forces modesetting DDX, disables TearFree and VRR
cat > /etc/X11/xorg.conf.d/20-modesetting.conf << EOF
Section "OutputClass"
    Identifier "AMD via modesetting (amdgpu)"
    MatchDriver "amdgpu"
    Driver "modesetting"
    Option "TearFree" "false"
    Option "VariableRefresh" "false"
EndSection
EOF
```

**Important:** The vanilla X11 v43 squashfs ships the same `20-amdgpu.conf` as Wayland:
`TearFree=true`, `VariableRefresh=true`, `Driver=amdgpu`. This is an x86 board-level
config (`board/batocera/x86/fsoverlay/`) applied to all x86 builds regardless of display
stack. `TearFree` has been there since 2021; `VariableRefresh` was added January 2025
during v42 development — neither is Wayland-specific. Both conflict with CRT mode.

The backup and replacement of `20-amdgpu.conf` is **not optional** — it is a required
Phase 2 step on every fresh X11 v43 install regardless of whether the user came from a
Wayland build or not.

### Step 7 — Write /boot/boot-custom.sh (generates 15-crt-monitor.conf at boot)
This file lives on the shared VFAT `/boot` partition. It is called by `S00bootcustom`
(present in BOTH squashfs files) on every boot of either OS. The script must:
- Check if `10-monitor.conf` has an enabled output
- If not found (Wayland boot) → exit 0 cleanly
- If found (CRT X11 boot) → generate `15-crt-monitor.conf` with modeline range entries

### Step 8 — Install patched batocera-resolution
The stock X11 `batocera-resolution` (xorg base variant, from the squashfs) works for
standard modes but does not handle the CRT switchres pipeline. The patched version from
the CRT Script must replace it in the overlay:

```bash
cp /userdata/system/Batocera-CRT-Script/.../batocera-resolution /usr/bin/batocera-resolution
chmod +x /usr/bin/batocera-resolution
```

This write goes to the overlay upper layer (tmpfs), not into the squashfs.

### Step 9 — Save the CRT overlay
```bash
/userdata/system/Batocera-CRT-Script/batocera-save-crt-overlay
```

This creates `/boot/crt/overlay` (100MB ext4 image) and syncs all the configs written
in Steps 3–8 into it. On every subsequent X11 CRT boot, the initrd loads this overlay
and all configs are restored from disk.

---

## Boot Partition Space Requirements

Confirmed from live system: the Wayland boot files occupy **4.4GB** of the 10GB
`/boot` (VFAT) partition.

| File | Size |
|---|---|
| `/boot/boot/batocera` (Wayland squashfs) | 3.2GB |
| `/boot/boot/rufomaculata` (board squashfs) | 1.1GB |
| `/boot/boot/linux` + `initrd.gz` + EFI files | ~120MB |
| **Wayland total** | **~4.4GB** |
| `/boot/crt/batocera` (X11 squashfs) | ~3.2GB |
| `/boot/crt/rufomaculata` (board squashfs) | ~1.1GB |
| `/boot/crt/linux` + `initrd-crt.gz` | ~24MB |
| `/boot/crt/overlay` (created at Phase 2) | ≤100MB |
| **CRT addition** | **~4.4GB** |
| **Total required** | **~8.8GB** |

**Batocera v43 creates a 10GB boot partition by default.** Confirmed on two separate fresh
v43 flashes — the Wayland build and the vanilla X11 build — both on a 1.8TB NVMe drive.
This is the v43 standard layout. The ~1GB boot partition from older Batocera versions is
not a concern for v43 users.

With 5.7GB free after a fresh v43 Wayland install and ~4.4GB needed for CRT files, there
is ~1.3GB margin. The CRT Script should still check available space as a safety guard:

```bash
BOOT_FREE=$(df -BG /boot | awk 'NR==2{print $4}' | tr -d 'G')
REQUIRED_GB=4   # need ~4GB free for CRT squashfs + kernel + initrd + overlay
if [ "$BOOT_FREE" -lt "$REQUIRED_GB" ]; then
    echo "ERROR: /boot has only ${BOOT_FREE}GB free. At least ${REQUIRED_GB}GB required."
    echo "This is unexpected for a Batocera v43 install. Check your boot partition."
    exit 1
fi
```

---

## Full File Map: What Lands Where

### On VFAT `/boot` partition (written by Phase 1):

```
/boot/
├── crt/
│   ├── batocera          ← X11 OS squashfs (extracted from image)
│   ├── rufomaculata      ← X11 board squashfs (extracted from image)
│   ├── linux             ← X11 kernel (extracted from image)
│   ├── initrd-crt.gz     ← patched initrd (generated by script)
│   └── overlay           ← persistent overlay (created at end of Phase 2)
├── boot-custom.sh        ← written by Phase 1 or Phase 2 (generates 15-crt-monitor.conf)
└── EFI/BOOT/grub.cfg     ← CRT entry appended by Phase 1
```

### In tmpfs overlay (written by Phase 2, persisted via `/boot/crt/overlay`):

```
/etc/switchres.ini                         ← user monitor profile
/etc/X11/xorg.conf.d/10-monitor.conf      ← output enable + identifier
/etc/X11/xorg.conf.d/15-crt-monitor.conf ← generated at each boot by boot-custom.sh
/etc/X11/xorg.conf.d/20-modesetting.conf  ← modesetting DDX, TearFree=false
/etc/X11/xorg.conf.d/20-amdgpu.conf.bak  ← backed up original
/lib/firmware/edid/custom.bin             ← EDID binary for the CRT monitor
/usr/bin/batocera-resolution              ← patched version (replaces squashfs version)
```

### On `/userdata` partition (shared between boots, written by Phase 1 or before):

```
/userdata/system/Batocera-CRT-Script/
├── batocera-save-crt-overlay             ← modified overlay save script (new)
├── .install_phase                        ← "2" after Phase 1, removed after Phase 2
└── videomodes.conf                       ← per-system resolution mappings
/userdata/system/videomodes.conf          ← symlink or copy
```

---

## Resolution Switching After Reboot — How It Works

Once Phase 2 is complete and `/boot/crt/overlay` exists, every subsequent CRT boot
follows this sequence:

1. GRUB loads `/crt/linux` and `/crt/initrd-crt.gz`
2. `initrd-crt.gz` init script mounts VFAT at `/boot_root`, loads `/boot_root/crt/overlay`
   into tmpfs, then mounts `/boot_root/crt/batocera` + `/boot_root/crt/rufomaculata`
   as the overlayFS lower layers — restoring all Phase 2 configs from the overlay file
3. `S00bootcustom` runs early in the init sequence, calls `/boot/boot-custom.sh`, which
   reads `10-monitor.conf` → generates `/etc/X11/xorg.conf.d/15-crt-monitor.conf` with
   the correct monitor HorizSync/VertRefresh ranges for the CRT
4. Xorg starts with `modesetting` DDX — reads `10-monitor.conf`, `15-crt-monitor.conf`,
   `20-modesetting.conf` from overlay — CRT output is active
5. EmulationStation launches; `batocera-resolution` (patched) is used for per-system
   resolution changes — calls `switchres` → generates modelines → calls `xrandr` to apply
6. RetroArch and MAME use their internal switchres libraries with `/etc/switchres.ini`
   (restored from overlay) for automatic resolution switching per game

**What must survive a reboot to maintain resolution switching:**

| Required for resolution switching | Persisted in |
|---|---|
| `/etc/switchres.ini` | `/boot/crt/overlay` |
| `/etc/X11/xorg.conf.d/10-monitor.conf` | `/boot/crt/overlay` |
| `/etc/X11/xorg.conf.d/20-modesetting.conf` | `/boot/crt/overlay` |
| `/usr/bin/batocera-resolution` (patched) | `/boot/crt/overlay` |
| `/lib/firmware/edid/custom.bin` | `/boot/crt/overlay` |
| `/etc/X11/xorg.conf.d/15-crt-monitor.conf` | Regenerated at every boot by `boot-custom.sh` |
| `switchres`, `xrandr`, `libswitchres.so` | X11 squashfs (always present after Phase 1) |

---

## Resolved Items

All open questions from the initial draft have been answered via live SSH investigation
of a vanilla X11 v43 build (`batocera-x86_64-43-20260217.img.gz`). See
`vanilla-x11-v43-live-findings.md` for the full audit.

1. **`/lib/firmware/edid/` confirmed absent on vanilla X11 v43.** Phase 2 must always
   `mkdir -p /lib/firmware/edid` before writing the EDID binary. This applies to all
   fresh v43 installs regardless of build variant.

2. **`drm.edid_firmware=` kernel params are NOT required in the Phase 1 GRUB CRT entry.**
   Xorg starts and xrandr functions correctly on a vanilla X11 v43 boot without any CRT
   kernel params. The param seen on the v42 system was written by Phase 2 of the CRT
   Script — not a vanilla system state. Phase 1 writes the GRUB CRT entry without it.
   Phase 2 adds it to the GRUB entry if needed for the specific monitor/connector, after
   the connector is identified.

3. **10GB boot partition is the Batocera v43 default.** Confirmed on two separate fresh
   v43 flashes (Wayland and X11). No resize logic required. 5.7GB free on a fresh Wayland
   install is sufficient for the ~4.4GB CRT addition.

4. **`batocera-save-overlay` is NOT called automatically on shutdown.** Confirmed via
   live inspection of `/etc/init.d/rcK` and all `S??*` scripts — none call it. The
   overlay is only persisted when explicitly called. Phase 2 MUST call
   `batocera-save-crt-overlay` before triggering reboot. If the system shuts down before
   this call, all Phase 2 writes are lost and Phase 2 must run again from scratch. The
   mode_switcher should also call it when switching out of CRT mode.
