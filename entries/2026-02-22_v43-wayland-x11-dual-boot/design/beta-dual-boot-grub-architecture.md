# Beta Dual-Boot GRUB Architecture: Wayland (HD) + X11 (CRT)

**Date:** 2026-02-19
**Status:** Beta Testing — Pre v43 Public Release
**Branch:** crt-hd-mode-switcher-43-wayland-x11
**Companion to:** `beta-testing-flow-v43-wayland-x11.md`, `official-official-dual-boot-grub-architecture.md` (Production)

> **This document is temporary.** Once v43 is publicly released on batocera.org, use
> `official-official-dual-boot-grub-architecture.md` instead. This beta architecture doc will be retired at that point.

---

## Overview

Batocera v43 is migrating **select** platforms to a Wayland display stack. CRT mode requires X11 (Xorg, switchres, xrandr) which is not available in Wayland builds. This document describes the architecture for running both Wayland and X11 Batocera builds on a **single drive**, selectable at boot via GRUB, with a fully shared userdata (ROMs, saves, BIOS, configs) partition between both.

This is the **beta variant** of the architecture. It differs from production in two ways:

1. The CRT Script is installed manually (zip transfer) — the `curl` one-liner is not available during beta
2. The X11 image URL is pasted by the user at runtime — the URL is not hardcoded because beta builds change frequently

All other architecture (GRUB layout, initrd, file sharing, mode switching, RESTORE) is identical to production.

---

## Which Batocera v43 Builds Are Wayland?

As of v43, **not all platforms use Wayland**. The Wayland migration is happening for the Steam Deck build exclusively.

| Platform | Display Stack | CRT Supported? |
|---|---|---|
| Steam Deck | Wayland (labwc) | ✅ Yes — this dual-boot flow applies |
| Desktop PC / Laptop / NUC (x86_64) | X11 (in transition — check your running build) | ✅ Yes — standard CRT install if already X11 |
| Raspberry Pi / ARM boards | X11 (varies by board) | ❌ No — CRT output requires x86_64 |

**The Batocera-CRT-Script is x86_64 only.** Raspberry Pi and ARM boards are listed here for completeness but are not supported targets. The dual-boot GRUB flow and all CRT functionality covered in this document apply exclusively to x86_64 machines.

> **Note (beta):** The Wayland v43 base build is **not available on batocera.org/download** during the pre-release period. We provide the current mirror URL directly. Example format:
> ```
> https://mirrors.o2switch.fr/batocera/x86_64/butterfly/last/batocera-x86_64-43-YYYYMMDD.img.gz
> ```

---

## Goals

- Single drive — no separate Wayland/X11 drives
- Wayland is always the default; X11 CRT mode is opt-in
- Running `Batocera-CRT-Script-v43.sh` checks the display stack first, then acts accordingly
- `mode_switcher.sh` switches between HD (Wayland) and CRT (X11) and controls which boots by default
- `Batocera-CRT-Script-v43.sh RESTORE` removes the X11 build and returns to Wayland-only
- ROMs, saves, BIOS, and all user data are shared between both boots at all times
- MergerFS (new in v43) is fully supported — external drives with ROMs are detected and merged under both boots
- Network shares (NAS via SMB/NFS) configured in `batocera-boot.conf` are available under both boots

---

## Beta Script Install

The production `curl` one-liner is **not available during beta**. The script must be installed manually before any of the steps below apply.

```bash
# Production (not available yet):
bash <(curl -Ls https://bit.ly/batocera-crt-script | sed 's/\r$//')

# Beta — manual install:
cd /userdata/system/Batocera-CRT-Script/Batocera_ALLINONE && chmod 755 Batocera-CRT-Script-v43.sh && ./Batocera-CRT-Script-v43.sh
```

The script folder must first be transferred to `/userdata/system/` via WinSCP, `scp`, or USB using the zip link we provide. See `beta-testing-flow-v43-wayland-x11.md` Step 2 for full transfer instructions.

---

## Pre-Flight Check: Wayland or X11?

`Batocera-CRT-Script-v43.sh` must detect the active display stack **before** doing anything else. The install path branches based on this result. This logic is identical between beta and production.

### Detection Method

```bash
# Check for active Wayland compositor
if pgrep -x labwc > /dev/null 2>&1 || [ "$XDG_SESSION_TYPE" = "wayland" ]; then
    DISPLAY_STACK="wayland"
else
    DISPLAY_STACK="x11"
fi
```

A more robust check also looks for the compositor socket:

```bash
# Check for Wayland socket (exists when a Wayland compositor is running)
if [ -n "$(ls /run/user/*/wayland-* 2>/dev/null)" ] || pgrep -x labwc > /dev/null 2>&1; then
    DISPLAY_STACK="wayland"
else
    DISPLAY_STACK="x11"
fi
```

### Install Path Decision

```
Batocera-CRT-Script-v43.sh
        │
        ▼
  [ Display Stack Check ]
        │
        ├── X11 detected ──────► Standard CRT install path (existing logic)
        │                         • No squashfs download needed
        │                         • No grub.cfg changes needed
        │                         • Continue directly with CRT config setup
        │                         • Reboot
        │
        └── WAYLAND detected ──► [ Auto-scan for X11 image ]
                                        │
                                        ├── FILE FOUND (/userdata/ or /media/)
                                        │         • Confirm with user: use found file or download fresh
                                        │         • Validate MD5 against official Batocera checksum
                                        │         • MD5 must match — wrong build, wrong version,
                                        │           or corrupted file will be rejected
                                        │         • Extract squashfs, original file untouched
                                        │
                                        ├── FILE NOT FOUND
                                        │         • Show transfer instructions (WinSCP / scp / USB)
                                        │         • Option: (1) Scan again — file transferred, try now
                                        │         •           └─ Loop repeats until file found or exited
                                        │         • Option: (2) Paste download URL  ← BETA DIFFERENCE
                                        │         • Option: (3) Exit script
                                        │         •           └─ Re-run script required to try again
                                        │
                                        └── USER EXITS (option 3 at any prompt)
                                                  • Script exits cleanly
                                                  • No changes made to boot partition or configs
                                                  • Re-run script to try again

        After image source selected (options 1 or 2):
                ┌─ PHASE 1 ──────────────────────────────────────────────┐
                │ • Validate MD5 against official Batocera checksum       │
                │ • Loop-mount VFAT partition from .img.gz               │
                │ • Extract to /boot/crt/:                               │
                │     batocera       (X11 OS squashfs ~3.2GB)            │
                │     rufomaculata   (board squashfs ~1.1GB)             │
                │     linux          (X11 kernel ~23MB)                  │
                │     initrd.gz      → patch → initrd-crt.gz             │
                │   (initrd-crt.gz: all /boot_root/boot/ refs become     │
                │    /boot_root/crt/ — squashfs, overlay, update paths)  │
                │ • Add CRT entry to grub.cfg / syslinux.cfg             │
                │     uses /crt/linux and /crt/initrd-crt.gz             │
                │ • Set grub default to CRT entry                        │
                │ • Cleanup prompt (both download and local file):        │
                │     "Delete source image to free up space?"             │
                │     (1) Yes, delete it — squashfs is already extracted  │
                │     (2) No, keep it — useful for reinstall without DL   │
                │ • Write phase flag: /userdata/system/                   │
                │       Batocera-CRT-Script/.install_phase=2              │
                │ • Reboot into X11                                       │
                └────────────────────────────────────────────────────────┘
                        │
                        ▼ (user re-runs script after reboot)
                ┌─ PHASE 2 ──────────────────────────────────────────────┐
                │ • Script detects X11 running + phase flag present       │
                │ • Skips all Phase 1 steps — nothing repeated           │
                │ • xrandr now works — enumerates real display outputs    │
                │   (eDP-1, DP-1, VGA-1, etc.)                           │
                │ • Detect display connector → write /var/run/drmConn    │
                │ • mkdir -p /lib/firmware/edid  (absent on all v43)     │
                │ • Write EDID binary via switchres                       │
                │ • Update /etc/switchres.ini with user monitor profile   │
                │ • Write Xorg configs:                                   │
                │     10-monitor.conf  (output enable + identifier)       │
                │     20-modesetting.conf  (modesetting DDX,             │
                │       TearFree=false, VariableRefresh=false)            │
                │   Note: 20-amdgpu.conf ships in X11 squashfs with      │
                │   TearFree=true, VariableRefresh=true — same as        │
                │   Wayland (x86 board-level config). Backup + replace   │
                │   is mandatory on every v43 X11 install.               │
                │ • Write /boot/boot-custom.sh (generates                │
                │   15-crt-monitor.conf at each CRT boot)                │
                │ • Install patched batocera-resolution                  │
                │ • Call batocera-save-crt-overlay → creates             │
                │   /boot/crt/overlay (100MB ext4) and syncs all         │
                │   configs — MUST run before reboot or all              │
                │   Phase 2 writes are lost (overlay not auto-saved)     │
                │ • Delete phase flag                                     │
                │ • Final reboot into CRT mode                           │
                └────────────────────────────────────────────────────────┘
```

**If already on X11:** The system already has X11, switchres, and xrandr. The dual-boot GRUB setup is skipped entirely. The script proceeds with the existing CRT configuration logic unchanged — this is the same path used for v42 and earlier.

**If on Wayland:** The user is prompted to choose their image source before anything is downloaded or changed. No irreversible action is taken until the user confirms.

### Two-Phase Install Requirement (Wayland path only)

The Wayland install path requires **two script runs with a reboot between them**. This is a hard technical constraint:

**Why xrandr cannot run during Phase 1:**
- Phase 1 runs on the Wayland session (labwc compositor)
- `xrandr` under Wayland only reports what the compositor has set — not raw DRM connectors
- Real display output names (`eDP-1`, `DP-1`, `VGA-1`, etc.) are not reliably enumerable from a Wayland session
- switchres, output selection, and Xorg config all depend on accurate xrandr output
- CRT output configuration **must** happen inside a live X11 session

**Phase 1** (runs on Wayland): squashfs extraction, GRUB config, initrd-crt.gz, cleanup → write phase flag → reboot into X11

**Phase 2** (runs on X11, after reboot): script detects phase flag, skips Phase 1 entirely, runs full CRT config with working xrandr → final reboot

**Phase flag:** `/userdata/system/Batocera-CRT-Script/.install_phase=2`
Written at end of Phase 1, deleted at end of Phase 2. Survives the OS reboot because it lives in `/userdata/` (the shared SHARE partition).

### Local File Option Details

#### How the Script Is Run — SSH Context

The CRT script is run **via SSH** from whatever device the user has available — Mac, Windows PC, Linux machine, iPhone, Android phone.

This means:
- The script always **executes on Batocera** (Linux), not on the SSH client device
- `dialog` UI runs on Batocera and renders through the SSH terminal — works identically regardless of SSH client OS or device
- "Local file" means a file **physically accessible to the Batocera machine** — not a file sitting on the Mac or phone the user is SSH-ing from

#### Getting the Image onto the Batocera Machine

> **Beta difference:** The X11 image is not on batocera.org/download. We provide a direct mirror URL for the current beta build. Download the `.img.gz` from that URL on your PC/Mac, then transfer it to Batocera using one of the methods below — or use option (2) to paste the URL and let the script download it directly.

| Your device | Transfer method | Where file lands on Batocera |
|---|---|---|
| **Windows** | [WinSCP](https://wiki.batocera.org/winscp) — drag the `.img.gz` into `/userdata/` | `/userdata/` |
| **Mac / Linux** | FileZilla (SFTP to `batocera.local`) or `scp batocera-x86_64-43.img.gz root@batocera.local:/userdata/` from terminal | `/userdata/` |
| **Any OS** | Copy to a USB drive, plug into the Batocera machine | `/media/usb0/` |
| **iPhone / Android** | USB drive is the practical option | `/media/usb0/` |

WinSCP and FileZilla connect over the same network as SSH — no cables, no physical access to the Batocera machine needed.

#### Auto-Scan — No File Picker Required

The script scans known locations automatically using `find`/`ls`. No file manager, no manual path entry, no CLI browsing required. The user never needs to know where the file is — the script finds it.

```bash
# Scan for Batocera x86_64 image files in known locations
IMAGE_CANDIDATES=$(find /userdata /media -maxdepth 3 \
    -name "batocera-x86_64*.img" -o \
    -name "batocera-x86_64*.img.gz" 2>/dev/null)
```

Scan locations (in order):
- `/userdata/` — internal share partition (WinSCP / FileZilla / SCP destination)
- `/media/` — USB drives and external storage (auto-mounted by Batocera)

**If one file is found:**
```
[ X11 Batocera Image Found ]

  /userdata/batocera-x86_64-43.img.gz  (4.2GB)

  MD5 will be verified against the official Batocera
  checksum before use. File will be rejected if it does
  not match (wrong build, wrong version, or corrupted).

  (1) Use this file
  (2) Enter download URL instead
  (3) Cancel
```

**If multiple files are found**, present a numbered list to choose one, or enter a download URL.

**If nothing is found — live instruction + retry loop:**
```
[ X11 Image Not Found ]

No Batocera x86_64 image found on /userdata or USB drives.

─────────────────────────────────────────────────────────
 HOW TO GET THE IMAGE ONTO THIS MACHINE
─────────────────────────────────────────────────────────

 STEP 1 — Download the X11 beta image on your PC/Mac:
   Use the mirror link provided to you.
   Example format:
   https://mirrors.o2switch.fr/batocera/x86-64-v3/butterfly/last/
     batocera-zen3-x86-64-v3-43-YYYYMMDD.img.gz

   Note: download time depends entirely on your internet speed.
   A 4-5GB file may take anywhere from 5 minutes on fast
   broadband to 60+ minutes on a slow or congested connection.

 STEP 2 — Transfer it to this machine (pick one):

   Windows → WinSCP:  wiki.batocera.org/winscp
     Connect: batocera.local | root | linux
     Drop file into:  /userdata/

   Mac/Linux → open a second terminal and run:
     scp batocera-x86_64-43.img.gz root@batocera.local:/userdata/

   USB Drive → copy file to USB, plug into this machine
     (detected automatically)

 STEP 3 — Come back here and press ENTER to scan again.
 OR select (2) to paste the URL and download directly.

─────────────────────────────────────────────────────────

  (1) Scan again — I have transferred the file
  (2) Paste download URL — script will download directly
  (3) Exit
```

The user transfers the file in another window (WinSCP, a second terminal, or plugs in USB) without exiting the script. Selecting **(1) Scan again** re-runs the same `find` scan from the beginning. Selecting **(2)** opens the URL paste prompt. The loop repeats as many times as needed. **(3) Exit** is the only way out without installing.

**Retry loop flow:**
```
scan → not found → show instructions → user transfers file
     → (1) Scan again → found → validate MD5 → continue install

     OR

scan → not found → (2) Paste URL → confirm → download
     → validate MD5 → continue install
```

#### URL Paste Prompt (beta-only)

When option **(2)** is selected (either from the "not found" screen or from a "found file" screen), the script prompts for the download URL:

```
[ X11 Beta Image — Enter Download URL ]

  Paste the direct download link for the X11 beta image.
  (Right-click the file on the mirror → Copy Link Address)

  URL: _
```

After the URL is entered, the script **derives the MD5 URL automatically** by appending `.md5`:

```bash
IMAGE_URL="<pasted by user at runtime>"
MD5_URL="${IMAGE_URL}.md5"
# Example:
# IMAGE_URL = https://mirrors.o2switch.fr/.../batocera-zen3-x86-64-v3-43-20260217.img.gz
# MD5_URL   = https://mirrors.o2switch.fr/.../batocera-zen3-x86-64-v3-43-20260217.img.gz.md5
```

The script confirms both before downloading:

```
[ Confirm Download ]

  Image: https://mirrors.o2switch.fr/.../batocera-zen3-x86-64-v3-43-20260217.img.gz
  MD5:   https://mirrors.o2switch.fr/.../batocera-zen3-x86-64-v3-43-20260217.img.gz.md5
         (derived automatically from image URL)

  (1) Yes, download
  (2) Enter a different URL
  (3) Exit
```

#### Validation Steps After File Is Located

Validation runs in this order before any extraction begins. The script aborts with a clear error message if any step fails.

**Step 1 — MD5 checksum (primary trust gate)**

In beta, the `IMAGE_URL` is provided by the user at runtime. The `MD5_URL` is derived from it by appending `.md5` — the same pattern used in production, but without a hardcoded URL:

```bash
# Beta: IMAGE_URL is pasted by the user at runtime — not hardcoded
IMAGE_URL="<user-pasted>"
MD5_URL="${IMAGE_URL}.md5"

# Fetch official MD5 directly from the mirror
OFFICIAL_MD5=$(wget -q -O - "$MD5_URL" | tr -d ' \n')

# Compute MD5 of the local file
LOCAL_MD5=$(md5sum "$IMAGE_PATH" | cut -d' ' -f1)

if [ "$LOCAL_MD5" != "$OFFICIAL_MD5" ]; then
    # ABORT — file is wrong build, wrong version, or corrupted
fi
```

This single check catches:
- Wrong image (e.g. user accidentally provided a Wayland build instead of X11)
- Wrong build date (URL pointed to a different day's build than the file on disk)
- Corrupted download (partial transfer, bad USB, etc.)
- Tampered or unofficial image

If the MD5 does not match, **the script refuses to proceed** and tells the user exactly why. The most common cause in beta is a URL/file date mismatch — paste the correct link and try again.

**Step 2 — Sufficient free space on `/boot`**

The full CRT directory requires ~4.4GB (batocera ~3.2GB + rufomaculata ~1.1GB + linux ~23MB + initrd-crt.gz ~1MB + overlay ≤100MB). A fresh v43 Wayland install leaves ~5.7GB free — confirmed on live hardware.

```bash
BOOT_FREE=$(df -BG /boot | awk 'NR==2{print $4}' | tr -d 'G')
REQUIRED_GB=4   # need ~4GB free for CRT squashfs + kernel + initrd + overlay
if [ "$BOOT_FREE" -lt "$REQUIRED_GB" ]; then
    # ABORT — not enough space (unexpected on v43, means user has filled the boot partition)
fi
```

**Step 3 — Extract and spot-check squashfs**

After extraction, verify the squashfs magic bytes are valid before committing:

```bash
# squashfs magic: 'hsqs' (little-endian)
MAGIC=$(xxd -l 4 /boot/crt/batocera | awk '{print $2$3}' | cut -c1-8)
if [ "$MAGIC" != "68737173" ]; then
    # ABORT — extracted file is not a valid squashfs
fi
```

**The MD5 is the definitive check.** Steps 2 and 3 are safety nets, but matching the MD5 from the Batocera mirror is the only way to confirm the image is genuinely the correct X11 build — nothing else can confirm that.

After successful extraction, the script prompts — regardless of whether the image was downloaded or transferred manually:

```
[ Cleanup ]

  Source image: /userdata/batocera-x86_64-43.img.gz  (4.2GB)

  The squashfs has been extracted successfully.
  The source image is no longer needed.

  Delete it to free up space on /userdata/?

  (1) Yes, delete it — reclaim 4.2GB on /userdata
  (2) No, keep it — useful if you may need to reinstall later
```

- **(1) Delete** — reclaims ~4GB on `/userdata/`. Recommended for most users.
- **(2) Keep** — file is left untouched. Note: in beta, builds update frequently — a kept file may be outdated by the next test run.

The extracted squashfs at `/boot/crt/batocera` is already in place regardless of this choice.

---

## Batocera v43 Boot Architecture (Baseline)

### Disk Layout

```
nvme0n1 (single drive — e.g. 1.8TB NVMe)
├── nvme0n1p1  10GB  vfat  label="BATOCERA"  → /boot
└── nvme0n1p2  1.8TB ext4  label="SHARE"     → /userdata
```

### Boot Partition Contents (current, Wayland)

```
/boot/                               (10GB vfat, ~4.4GB used, ~5.7GB free)
├── boot/
│   ├── linux                        (23MB — kernel)
│   ├── initrd.gz                    (751KB — initramfs)
│   ├── batocera                     (3.2GB — Wayland OS squashfs)
│   ├── rufomaculata                 (1.1GB — board squashfs)
│   ├── batocera.board               (text: "x86_64" or "x86-64-v3" by build variant)
│   └── syslinux/                    (legacy BIOS bootloader files)
├── EFI/
│   ├── batocera/
│   │   ├── shimx64.efi              (Secure Boot shim)
│   │   └── grubx64.efi              (GRUB bootloader)
│   └── BOOT/
│       └── grub.cfg                 ← primary boot config (EFI)
└── batocera-boot.conf               (sharedevice, GPU options, etc.)
```

### Boot Sequence (EFI)

```
UEFI firmware
  └── shimx64.efi  (Secure Boot shim)
      └── grubx64.efi  (GRUB)
          └── grub.cfg  (menu / default selection)
              └── loads: linux kernel + initrd.gz
                  └── initrd init script:
                      1. Find partition labeled "BATOCERA" → mount at /boot_root
                      2. Mount /boot_root/boot/batocera   → /overlay_root/base
                      3. If rufomaculata exists:
                         Mount /boot_root/boot/rufomaculata → /overlay_root/base2
                      4. Stack as overlayFS → live root filesystem
                      5. switch_root → /sbin/init → Batocera starts
```

### Current grub.cfg (EFI/BOOT/grub.cfg)

```
set default="0"
set timeout="1"

menuentry "Batocera.linux (normal)" {
    linux /boot/linux label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
    initrd /boot/initrd.gz
}

menuentry "Batocera.linux (verbose)" {
    linux /boot/linux label=BATOCERA vt.global_cursor_default=0
    initrd /boot/initrd.gz
}
```

### Key initrd Constraint

The initrd `init` script hardcodes two squashfs filenames:

```ash
mount /boot_root/boot/batocera /overlay_root/base
if test -e /boot_root/boot/rufomaculata; then
    mount /boot_root/boot/rufomaculata /overlay_root/base2
fi
```

These filenames and the `/boot/` path prefix are fixed in the compiled initrd. A custom `initrd-crt.gz` is required for the CRT boot path to load squashfs from a different directory.

---

## Proposed Dual-Boot Layout

### Boot Partition After CRT Script Install

```
/boot/                               (10GB vfat)
├── boot/                            ← WAYLAND (unchanged)
│   ├── linux                        (23MB — Wayland kernel)
│   ├── initrd.gz                    (Wayland initrd — unchanged)
│   ├── batocera                     (3.2GB — Wayland squashfs)
│   └── rufomaculata                 (1.1GB — board squashfs)
│
├── crt/                             ← NEW: all X11/CRT boot files
│   ├── batocera                     (~3.2GB — X11 OS squashfs)
│   ├── rufomaculata                 (~1.1GB — X11 board squashfs)
│   ├── linux                        (~23MB — X11 kernel, extracted from image)
│   ├── initrd-crt.gz                (~751KB — patched initrd, loads from /crt/)
│   └── overlay                      (≤100MB ext4 — CRT persistent overlay,
│                                      created at end of Phase 2)
│
├── boot-custom.sh                   ← NEW: generates 15-crt-monitor.conf at boot
└── EFI/BOOT/grub.cfg                ← MODIFIED: adds CRT entry, timeout bumped
```

**Space estimate:** ~4.4GB Wayland + ~4.4GB CRT = ~8.8GB of 10GB used. Confirmed feasible on a fresh v43 install which leaves ~5.7GB free. X11 kernel and rufomaculata are always extracted separately — sharing them is not safe since beta build dates may differ between Wayland and X11 images.

**Why a separate X11 kernel?** Kernel modules live inside the squashfs at `/lib/modules/<kernel-version>/`. If the X11 and Wayland builds use different kernel versions (common across different beta build dates), booting the X11 squashfs with the Wayland kernel causes module version mismatches. Using the kernel from the same image as the X11 squashfs guarantees compatibility.

### Modified grub.cfg

```
set default="0"
set timeout="3"

menuentry "Batocera HD (Wayland)" {
    linux /boot/linux label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
    initrd /boot/initrd.gz
}

menuentry "Batocera CRT (X11)" {
    echo Booting Batocera.linux... CRT Mode (X11)
    linux /crt/linux label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
    initrd /crt/initrd-crt.gz
}

menuentry "Batocera HD (verbose)" {
    linux /boot/linux label=BATOCERA vt.global_cursor_default=0
    initrd /boot/initrd.gz
}
```

`set default="0"` = boots Wayland. `set default="1"` = boots CRT. Mode switching is a single number change in a text file.

Note: All GRUB paths are relative to the VFAT partition root. `/boot/crt/linux` on the running OS = `/crt/linux` in grub.cfg. The CRT entry uses the X11 kernel extracted to `/boot/crt/linux` — not the Wayland kernel — to guarantee kernel/module version compatibility with the X11 squashfs. This is especially important in beta where Wayland and X11 build dates may differ.

### Custom initrd-crt.gz

The stock `initrd.gz` from the X11 image is extracted to `/boot/crt/initrd-src.gz`, unpacked, and patched. **Every occurrence of `/boot_root/boot/` is replaced with `/boot_root/crt/`** — covering squashfs mounts, overlay persistence, and squashfs update paths:

```ash
# Before patch (stock — hardcoded to /boot/ directory):
mount /boot_root/boot/batocera /overlay_root/base
if test -e /boot_root/boot/rufomaculata; then
    mount /boot_root/boot/rufomaculata /overlay_root/base2
fi
if test -f /boot_root/boot/overlay; then      # ← persistent overlay
    mount -o ro /boot_root/boot/overlay /overlay_root/saved
fi

# After patch (CRT — all references become /crt/ directory):
mount /boot_root/crt/batocera /overlay_root/base
if test -e /boot_root/crt/rufomaculata; then
    mount /boot_root/crt/rufomaculata /overlay_root/base2
fi
if test -f /boot_root/crt/overlay; then       # ← looks for CRT overlay
    mount -o ro /boot_root/crt/overlay /overlay_root/saved
fi
```

Patch command: `sed -i 's|/boot_root/boot/|/boot_root/crt/|g' init`

Result: `/boot/crt/initrd-crt.gz` — loads X11 squashfs from `/crt/` and restores its persistent overlay from `/boot/crt/overlay`. The staging file `/boot/crt/initrd-src.gz` is deleted after patching. Everything else in the initrd (busybox, switch_root, overlayFS setup) is unchanged.

---

## File Sharing Between Both Boots

Both GRUB entries use `label=BATOCERA` — the same boot partition. Both boots inherit `batocera-boot.conf` (`sharedevice=INTERNAL`), which mounts the SHARE partition (`nvme0n1p2`) as `/userdata`.

| Content | Path | Shared? |
|---|---|---|
| ROMs (internal) | `/userdata/roms/` | ✅ Both boots |
| ROMs (external via MergerFS) | merged into `/userdata/roms/` at runtime | ✅ Both boots |
| BIOS files | `/userdata/bios/` | ✅ Both boots |
| Saves / States | `/userdata/saves/` | ✅ Both boots |
| Screenshots | `/userdata/screenshots/` | ✅ Both boots |
| CRT Script configs | `/userdata/system/Batocera-CRT-Script/` | ✅ Both boots |
| EmulationStation configs | `/userdata/system/configs/` | ✅ Managed by mode_switcher |
| MergerFS config | `/userdata/` | ✅ Both boots |
| Wayland OS | `/boot/boot/batocera` (squashfs) | ❌ Wayland boot only |
| X11 OS | `/boot/crt/batocera` (squashfs) | ❌ CRT boot only |

**MergerFS (new in v43):** Both boots share the same `/userdata/` partition and the same `batocera-boot.conf`. MergerFS config lives in `/userdata/`, so external drives with ROMs are detected and merged into `/userdata/roms/` identically under both the Wayland and X11 boots — no extra configuration needed. A ROM on an external drive is visible in both HD mode and CRT mode.

---

## X11 Squashfs Source

The CRT script downloads the official Batocera X11 `.img.gz` directly from the URL provided by the user, extracts only the `batocera` squashfs from the boot partition of that image, places it at `/boot/crt/batocera`, then deletes the downloaded image.

> **Beta difference from production:** In production, `IMAGE_URL` is hardcoded in the script — it never changes for a given major release. In beta, `IMAGE_URL` is pasted by the user at runtime because beta builds update frequently and the URL changes with each new build date. The MD5 derivation and everything else is identical.

- Source: official Batocera beta mirror — the image is unmodified upstream content
- Download size: ~4–5GB compressed image (similar to a normal Batocera install)
- Estimated time: varies entirely by internet speed — 5 min on fast broadband, 60+ min on slow connections
- The full image is deleted after squashfs extraction; only the squashfs (~3.2GB) is retained
- Script informs the user of size, source, and speed caveat before starting

**Pre-download space check:** Before starting the download, the script checks that both `/userdata/` and `/boot` have sufficient free space for the entire operation:

```bash
# Space required on /userdata for the downloaded image (~5GB)
USERDATA_AVAILABLE=$(df -m /userdata | awk 'NR==2 {print $4}')
USERDATA_REQUIRED=5120  # 5GB

# Space required on /boot for all CRT files (~4.4GB total)
BOOT_AVAILABLE=$(df -BG /boot | awk 'NR==2{print $4}' | tr -d 'G')
BOOT_REQUIRED=4  # 4GB minimum for batocera + rufomaculata + linux + initrd + overlay

if [ "$USERDATA_AVAILABLE" -lt "$USERDATA_REQUIRED" ]; then
    # ABORT — not enough space on /userdata to hold the download
fi
if [ "$BOOT_AVAILABLE" -lt "$BOOT_REQUIRED" ]; then
    # ABORT — not enough space on /boot for CRT files
fi
```

If either check fails, the script stops before any download begins and tells the user exactly what is needed:

```
[ Insufficient Disk Space ]

  Cannot proceed — not enough free space.

  /userdata  needs 5.0GB free  →  currently 2.1GB free  ✗
  /boot      needs 4.0GB free  →  currently 5.7GB free  ✓

  Free up space on /userdata (remove unused ROMs, files, or
  the previously downloaded .img.gz if present) then try again.

  Press ENTER to exit.
```

**Progress display:** `wget` is used for the download with `--progress=bar:force` which renders a live progress bar in the SSH terminal showing bytes downloaded, transfer speed, and estimated time remaining:

```
Downloading X11 Batocera image...
(Download time depends on your internet speed — may take 5 to 60+ minutes)

batocera-zen3-x86-64-v3-43-20260217.img.gz
  2.1G / 4.4G [================>         ] 48%  8.2MB/s  eta 4m32s
```

### Download Error Handling

Failures mid-download are caught and handled before any changes are made to the boot partition. The partial file is always cleaned up on failure.

**Failure scenarios and responses:**

| Failure | Detection | Response |
|---|---|---|
| Network dropped mid-download | `wget` non-zero exit code | Partial file deleted, error shown, retry offered |
| Server unreachable / timeout | `wget` non-zero exit code | Partial file deleted, error shown, retry offered |
| Disk full on `/userdata/` during download | `wget` write error / exit code | Partial file deleted, user informed of space needed |
| MD5 mismatch after download completes | checksum comparison fails | Downloaded file deleted, error shown, retry offered |
| SSH session dropped mid-download | `wget` continues in background if `nohup` used, else aborted | Partial file cleaned up on next run |

**Error screen shown to user:**

```
[ Download Failed ]

  An error occurred while downloading the X11 image.
  No changes have been made to your system.

  Error: Connection lost at 2.3GB / 4.4GB
  Partial file deleted: /userdata/batocera-x86_64-43.img.gz.part

  (1) Try again with same URL
  (2) Enter a different URL
  (3) Exit
```

**Implementation notes:**
- `wget` writes to a `.part` temporary file (`--output-document=file.part`) and only renames to the final filename on completion — a partial file is never left with the correct filename, preventing a corrupt file from passing the scan
- On retry, the script restarts the download from zero (no resume, since the `.part` file is deleted on failure)
- `(2)` opens the URL paste prompt again — the script stays open
- `(3)` drops the user into the "not found" retry loop so they can transfer manually instead

---

## Overlay Persistence

Batocera's root filesystem runs as overlayFS on tmpfs. The writable upper layer lives in RAM and is lost on reboot unless explicitly saved. The stock `batocera-save-overlay` saves to `/boot/boot/overlay` (the Wayland boot's overlay) — **hardcoded, not automatic on shutdown**.

CRT mode needs its own overlay file at `/boot/crt/overlay`. The CRT Script deploys `batocera-save-crt-overlay` (placed at `/userdata/system/Batocera-CRT-Script/batocera-save-crt-overlay`) — identical to the stock script except targeting `/boot/crt/overlay`.

**Why this matters:**
- Phase 2 writes CRT configs (Xorg files, switchres.ini, patched batocera-resolution, EDID binary) into the tmpfs overlay
- If `batocera-save-crt-overlay` is not called before reboot, all those writes are lost and Phase 2 must run again
- `initrd-crt.gz` already looks for its overlay at `/boot_root/crt/overlay` (patched path) — the two pieces are automatically consistent
- In beta: this is especially important to call explicitly as beta systems get reflashed frequently — the overlay is the only thing that persists CRT state across reflashes

**`batocera-save-crt-overlay` is called:**
1. At the end of Phase 2 — before the final reboot (creates `/boot/crt/overlay` for the first time)
2. By the mode_switcher when switching CRT → HD — to snapshot the current CRT state before booting Wayland

---

## Mode Switcher Changes

The HD/CRT Mode Switcher is a tool installed by the Batocera-CRT-Script, accessible from the EmulationStation > CRT Tools menu. It is not built into EmulationStation or Batocera.

The existing switcher handles config backup/restore and reboot. For dual-boot GRUB there are two new steps in each switch direction: `grub.cfg` default entry change, and overlay save for CRT. Identical between beta and production.

### Switching CRT → HD (Wayland)

1. User opens Mode Switcher from CRT Tools menu → selects **Switch to HD Mode**
2. **NEW:** Calls `batocera-save-crt-overlay` — snapshots current CRT state to `/boot/crt/overlay` before leaving X11
3. Backs up current CRT configs to `/userdata/Batocera-CRT-Script-Backup/`
4. Restores Wayland HD configs (EmulationStation, video output settings)
5. **NEW:** Remounts `/boot` read-write → changes `set default="0"` in `grub.cfg` → remounts read-only
6. Displays CRT safety warning — **turn off your CRT before rebooting**
7. Reboots → GRUB boots entry 0 → Wayland squashfs → HD mode

### Switching HD → CRT (X11)

1. User opens Mode Switcher from CRT Tools menu → selects **Switch to CRT Mode**
2. Backs up current Wayland HD configs
3. Restores CRT configs (Xorg, switchres, EmulationStation, video output settings)
4. **NEW:** Remounts `/boot` read-write → changes `set default="1"` in `grub.cfg` → remounts read-only
5. Reboots → GRUB boots entry 1 → X11 squashfs → CRT mode

### Safety

- `/boot` is remounted read-write only for the instant the `grub.cfg` line is changed, then immediately locked read-only again
- CRT is never exposed to HD-mode signals — configs are fully swapped before the reboot that loads the new display stack
- No `grub-set-default` tool required — `grub.cfg` is a plain text file edited directly

---

## RESTORE Flow

`Batocera-CRT-Script-v43.sh RESTORE` performs a full rollback to Wayland-only. Identical to production:

1. Restore all CRT configs to Wayland defaults (existing restore logic)
2. Remount `/boot` read-write
3. Remove the CRT `menuentry` block from `grub.cfg`
4. Set `set default="0"` and reduce timeout back to `"1"`
5. Delete `/boot/crt/` directory entirely — removes all CRT boot files (~4.4GB reclaimed):
   - `batocera` (X11 squashfs ~3.2GB)
   - `rufomaculata` (board squashfs ~1.1GB)
   - `linux` (X11 kernel ~23MB)
   - `initrd-crt.gz` (~751KB)
   - `overlay` (≤100MB)
6. Delete `/boot/boot-custom.sh`
7. Remount `/boot` read-only
8. Reboot → clean Wayland-only system

---

## Legacy BIOS Support

Batocera also ships `syslinux.cfg` for non-EFI machines. The CRT script modifies both configs when installing. Identical to production:

**syslinux.cfg additions** (appended to `/boot/boot/syslinux/syslinux.cfg`):
```
LABEL crt
    MENU LABEL Batocera.linux (CRT Mode X11)
    LINUX /crt/linux
    APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
    INITRD /crt/initrd-crt.gz
```

Syslinux paths are also relative to the VFAT partition root — same convention as GRUB. Mode switching on BIOS machines modifies `syslinux.cfg` instead of (or in addition to) `grub.cfg`. The script detects EFI vs BIOS at runtime via `[ -d /sys/firmware/efi ]`.

---

## What Is Not Changed

- The Wayland `batocera` squashfs and `initrd.gz` in `/boot/boot/` — never touched
- The Wayland `linux` kernel in `/boot/boot/linux` — never touched
- The SHARE partition (`/userdata`) — untouched by any boot config change
- The `batocera-boot.conf` — same for both boots
- All existing mode_switcher profile/CRT geometry logic
- All existing backup/restore logic

Note: The X11 kernel is placed at `/boot/crt/linux` — it is a separate copy extracted from the X11 image, not the shared Wayland kernel. Both kernels coexist on the same VFAT partition. In beta, where Wayland and X11 image build dates often differ, using separate kernels is especially important.

---

## Beta vs Production — Architecture Differences Summary

| | Beta | Production |
|---|---|---|
| Script install | Manual zip → WinSCP/USB → SSH | `curl` one-liner |
| `IMAGE_URL` | User-pasted at runtime | Hardcoded for v43 release |
| `MD5_URL` | Derived from pasted URL + `.md5` | Derived from hardcoded URL + `.md5` |
| MD5 fetch method | `wget -q -O - "$MD5_URL"` | `wget -q -O - "$MD5_URL"` — identical |
| Download error retry | (1) Same URL / (2) Different URL | (1) Retry / (2) Manual transfer |
| X11 kernel extracted | ✅ `/boot/crt/linux` — identical | ✅ `/boot/crt/linux` — identical |
| GRUB CRT entry | `/crt/linux` + `/crt/initrd-crt.gz` | ✅ Identical |
| initrd-crt.gz | Patch: `/boot_root/boot/` → `/boot_root/crt/` | ✅ Identical |
| Overlay persistence | `batocera-save-crt-overlay` → `/boot/crt/overlay` | ✅ Identical |
| File sharing | ✅ Identical | ✅ Identical |
| Mode Switcher | ✅ Identical (+ `batocera-save-crt-overlay` on CRT→HD) | ✅ Identical |
| RESTORE | ✅ Identical (~4.4GB reclaimed from `/boot/crt/`) | ✅ Identical |
