# CRT Script v43 — Installation Flow (Wayland → X11 Dual-Boot)

**Date:** 2026-02-19
**Status:** Design / Planning
**Companion to:** `official-official-dual-boot-grub-architecture.md`, `beta-testing-flow-v43-wayland-x11.md`, `beta-official-dual-boot-grub-architecture.md`

---

## Who This Applies To

This flow applies if you are running **Batocera v43 with Wayland** (currently the Steam Deck build) on an **x86_64 machine**.

> **The Batocera-CRT-Script is x86_64 only.** Raspberry Pi and ARM boards are not supported. CRT output via switchres, xrandr, and custom modelines requires x86_64 hardware.

The script detects your display stack automatically — if you are on an X11 build, this flow is skipped and the standard CRT install proceeds as it did in v42.

---

## What You Need Before Starting

- Batocera machine connected to your local network
- SSH client on your phone, PC, or Mac
  - Windows: PuTTY, Windows Terminal
  - Mac/Linux: built-in Terminal
  - iPhone/Android: Termius, JuiceSSH
- Batocera machine connected to the internet (for download option)

---

## Step 1 — Connect via SSH

```
Host:     batocera.local
Username: root
Password: linux
```

---

## Step 2 — Run the CRT Script

```bash
bash <(curl -Ls https://bit.ly/batocera-crt-script | sed 's/\r$//')
```

---

## Step 3 — Script Detects Wayland Automatically

The script checks your display stack without asking. If Wayland is detected:

```
Wayland display stack detected.
X11 is required for CRT mode.

A second X11 Batocera boot entry will be set up alongside
your existing Wayland install. Your ROMs, saves, and BIOS
files will be shared between both.
```

No action is taken yet. The script proceeds to find the X11 image.

---

## Step 4 — Script Scans for X11 Image

The script automatically searches `/userdata/` and any connected USB drives for a Batocera x86_64 `.img` or `.img.gz` file.

### If a file is found:

```
[ X11 Batocera Image Found ]

  /userdata/batocera-x86_64-43.img.gz   (4.2GB)

  MD5 will be verified against the official Batocera
  checksum before use. File will be rejected if it does
  not match (wrong build, wrong version, or corrupted).

  (1) Use this file
  (2) Download fresh directly instead
  (3) Cancel
```

Select **(1) Use this file** to proceed with the local copy.

### If multiple files are found:

A numbered list is shown. Select the correct one, or choose to download fresh.

### If no file is found:

```
[ X11 Image Not Found ]

No Batocera x86_64 image found on /userdata or USB drives.

─────────────────────────────────────────────────────────
 HOW TO GET THE IMAGE ONTO THIS MACHINE
─────────────────────────────────────────────────────────

 STEP 1 — Download the X11 Batocera image on your PC/Mac:
   https://batocera.org/download
   → "Desktop PC, Laptop, NUC" → download the .img.gz

   Download time depends on your internet speed.
   A 4-5GB file may take 5 min on fast broadband
   or 60+ min on a slow connection.

 STEP 2 — Manually transfer it to this machine (pick one):

   Windows → WinSCP:  wiki.batocera.org/winscp
     Connect: batocera.local | root | linux
     Drop file into:  /userdata/

   Mac/Linux → open a second terminal and run:
     scp batocera-x86_64-43.img.gz root@batocera.local:/userdata/

   USB Drive → copy file to USB, plug into this machine
     (detected automatically)

 STEP 3 — Come back here and press ENTER to scan again.

─────────────────────────────────────────────────────────

  (1) Scan again — I have transferred the file
  (2) Download automatically (direct from Batocera CDN)
  (3) Exit
```

The script **stays open** while you transfer. Open WinSCP or a second
terminal on your PC/Mac, do the transfer, then select **(1) Scan again**.
No need to re-run the script. **(3) Exit** fully exits — a re-run is required to try again.

---

## Step 5 — Download (if no local file was found)

If you chose option **(2) Download automatically**, the script runs a space check before starting:

```
[ Space Check ]

  /userdata  needs 5.0GB free  →  currently 8.3GB free  ✓
  /boot      needs 4.0GB free  →  currently 5.7GB free  ✓

  Space OK. Starting download...
```

If either check fails the script stops immediately — before downloading a single byte:

```
[ Insufficient Disk Space ]

  Cannot proceed — not enough free space.

  /userdata  needs 5.0GB free  →  currently 2.1GB free  ✗
  /boot      needs 4.0GB free  →  currently 5.7GB free  ✓

  Free up space on /userdata (remove unused ROMs or files)
  then re-run the script.

  Press ENTER to exit.
```

Once space is confirmed, the download begins with a live progress bar:

```
Downloading X11 Batocera image...
(Download time depends on your internet speed — may take 5 to 60+ minutes)

batocera-x86_64-43.img.gz
  2.1G / 4.4G [================>         ] 48%  8.2MB/s  eta 4m32s
```

If the download fails for any reason (network dropped, server timeout, disk full mid-download):

```
[ Download Failed ]

  An error occurred while downloading the X11 image.
  No changes have been made to your system.

  Error: Connection lost at 2.3GB / 4.4GB
  Partial file deleted.

  (1) Try again — retry download
  (2) I will transfer the file manually instead
  (3) Exit
```

- The partial file is **always deleted on failure** — a corrupt or incomplete file is never left behind
- Nothing on your boot partition is touched until a fully validated image is in hand
- Selecting **(2)** drops back into the manual transfer instructions without exiting the script

---

## Step 6 — MD5 Validation

Once the image is in hand — whether just downloaded or transferred manually — the script validates it before touching anything else:

1. Fetches the official MD5 from the Batocera mirror (URL derived automatically from the image URL by appending `.md5`)
2. Computes the MD5 of your file
3. Compares them

This confirms the image is:
- The correct **X11 build** (not Wayland)
- The correct **version** (matches your running Batocera)
- **Not corrupted** (complete and intact)

```
[ MD5 Validation ]

  Checking file against official Batocera checksum...

  Expected:  a3f1c8d2e4b7091f3c6a2d5e8b4f7c1a
  Got:       a3f1c8d2e4b7091f3c6a2d5e8b4f7c1a

  ✓ Checksum verified. File is the correct X11 build.
```

If validation fails, the script tells you exactly why and stops. Nothing on your boot partition has been changed:

```
[ MD5 Validation Failed ]

  This file does not match the official X11 checksum.
  It may be a Wayland build, wrong version, or corrupted.

  File rejected. No changes made.

  (1) Try downloading again
  (2) I will transfer the correct file manually
  (3) Exit
```

---

## Step 7 — X11 Files Extracted to /boot/crt/

Once the image passes MD5 validation, the script loop-mounts the VFAT partition from the `.img.gz` and copies the following files to `/boot/crt/` on your drive:

```
Extracting X11 boot files to /boot/crt/...
  Source: /userdata/batocera-x86_64-43.img.gz

  batocera       ~3.2GB  [=============>    ] 74%
  rufomaculata   ~1.1GB  waiting...
  linux          ~23MB   waiting...
  initrd.gz      ~751KB  waiting... (will be patched → initrd-crt.gz)
```

| File | What it is |
|---|---|
| `batocera` | X11 OS squashfs — the CRT-capable Batocera image |
| `rufomaculata` | Board/arch squashfs for this x86_64 build |
| `linux` | X11 kernel — extracted separately to guarantee kernel/module compatibility |
| `initrd-crt.gz` | Patched initramfs — all `/boot_root/boot/` paths changed to `/boot_root/crt/` |

After copying, the script patches the initrd: unpacks it, runs `sed -i 's|/boot_root/boot/|/boot_root/crt/|g' init`, and repacks it as `initrd-crt.gz`. This single change makes the initrd load the X11 squashfs and its overlay from `/crt/` instead of `/boot/`.

Free space on `/boot` is verified before extraction begins (~4GB required — the full `/boot/crt/` directory will use ~4.4GB).

Once extraction and patching are complete, regardless of whether you downloaded or used a local file, the script asks:

```
[ Cleanup ]

  Source image: /userdata/batocera-x86_64-43.img.gz  (4.2GB)

  The squashfs has been extracted successfully.
  The source image is no longer needed.

  Delete it to free up space on /userdata/?

  (1) Yes, delete it — reclaim 4.2GB on /userdata
  (2) No, keep it — useful if you may need to reinstall later
```

Choosing **(1)** reclaims ~4GB on `/userdata/`. Choosing **(2)** keeps the file — handy if you plan to run RESTORE and reinstall later without downloading again. Either way, the extracted squashfs at `/boot/crt/batocera` is already in place and the choice here has no effect on the CRT install.

---

## Step 8 — Boot Configuration Updated

The script adds a CRT boot entry to GRUB and sets it as the default for the Phase 2 reboot:

**Before:**
```
  Batocera.linux (normal)     ← boots automatically
  Batocera.linux (verbose)
```

**After:**
```
  Batocera HD (Wayland)       ← still present
  Batocera CRT (X11)          ← new, boots automatically  ← set as default
  Batocera HD (verbose)
```

The CRT entry uses the X11 kernel at `/crt/linux` and the patched initrd at `/crt/initrd-crt.gz` — both relative paths on the VFAT partition. It does not use the Wayland kernel.

On BIOS (non-EFI) machines, `syslinux.cfg` is updated instead. The script detects EFI vs BIOS automatically via `/sys/firmware/efi`.

---

## Step 9 — Phase 1 Complete — Reboot into X11

```
[ Phase 1 Complete — Reboot Required ]

  The X11 boot environment has been set up.
  Your system will now reboot into X11 mode.

  IMPORTANT: After reboot, re-run the CRT Script
  to complete CRT output and display configuration.
  The script will automatically continue from where
  it left off — no steps will be repeated.

  Press ENTER to reboot.
```

On next boot, GRUB loads the X11 build. The system is now running X11 — xrandr can properly detect your display outputs (eDP-1, DP-1, VGA-1, etc.).

---

## Step 10 — Re-run Script (Phase 2 — CRT Configuration)

Re-run the CRT script via SSH. It detects the phase 2 flag and resumes automatically:

```
[ Resuming CRT Script — Phase 2 of 2 ]

  X11 detected. GRUB dual-boot is already configured.
  Continuing with CRT display setup...
```

Phase 2 runs the following steps in order. All writes go into the tmpfs overlay layer and are persisted to `/boot/crt/overlay` at the end — they survive every subsequent reboot.

1. **Verify X11 environment** — confirms `xrandr` is available (fails fast if booted into Wayland by mistake)
2. **Detect display connector** — `xrandr --query` enumerates live outputs (DP-1, HDMI-1, eDP-1, VGA-1, etc.)
3. **Create `/lib/firmware/edid/`** — this directory is absent on all fresh v43 builds (confirmed on both Wayland and vanilla X11)
4. **Write EDID binary** — generated by switchres for the detected connector
5. **Update `/etc/switchres.ini`** — overwrites the default config with your monitor profile (connector, HorizSync/VertRefresh, crt_range values)
6. **Write Xorg configs:**
   - `10-monitor.conf` — output enable + identifier
   - `20-modesetting.conf` — forces modesetting DDX, disables TearFree and VariableRefresh
   - Note: The X11 squashfs ships `20-amdgpu.conf` with `TearFree=true` and `VariableRefresh=true` — this is an x86 board-level config present in all x86 builds, not Wayland-specific. It is backed up and replaced on every v43 install.
7. **CRT output port selection** — VGA, DVI-I, DisplayPort via DAC
8. **Monitor profile selection** — 15kHz, 24kHz, 31kHz
9. **Write `/boot/boot-custom.sh`** — called at every CRT boot to generate `15-crt-monitor.conf` with your monitor's HorizSync/VertRefresh ranges
10. **Install patched `batocera-resolution`** — replaces the stock version in the overlay
11. **Save CRT overlay** — calls `batocera-save-crt-overlay` which creates `/boot/crt/overlay` (100MB ext4) and syncs all configs into it. **This must complete before reboot** — the overlay is not saved automatically on shutdown.
12. **EmulationStation configuration**

---

## Step 11 — Final Reboot

```
CRT setup complete. Press ENTER to reboot.
```

On next boot, GRUB loads the X11 build in full CRT mode. Your CRT receives
the correct signal. Everything in `/userdata/` — ROMs, saves, BIOS,
CRT Script configs — is exactly where it was.

---

## What Is Shared Between Both Boots

| Content | Shared? |
|---|---|
| ROMs (internal) | ✅ Yes |
| ROMs (external via MergerFS) | ✅ Yes |
| ROMs / data (NAS via SMB/NFS) | ✅ Yes — same `batocera-boot.conf` used by both boots |
| BIOS files | ✅ Yes |
| Saves / States | ✅ Yes |
| Screenshots | ✅ Yes |
| CRT Script configs | ✅ Yes |
| EmulationStation configs | ✅ Yes (managed by mode switcher) |
| Wayland OS files | ❌ Wayland boot only |
| X11 OS files | ❌ CRT boot only |

---

## Switching Between HD and CRT Mode

Use the **HD/CRT Mode Switcher** — a tool installed by the Batocera-CRT-Script, accessible from the EmulationStation > CRT Tools menu after CRT Script installation.

### Switching CRT → HD (Wayland)

1. Open Mode Switcher from the CRT Tools menu
2. Select **Switch to HD Mode**
3. The tool:
   - Calls `batocera-save-crt-overlay` — snapshots current CRT state to `/boot/crt/overlay` before leaving X11
   - Backs up current CRT configs to `/userdata/Batocera-CRT-Script-Backup/`
   - Restores Wayland HD configs (EmulationStation, video output settings)
   - Remounts `/boot` read-write
   - Changes `set default="0"` in `grub.cfg` → Wayland entry
   - Remounts `/boot` read-only
4. Displays the CRT safety warning — **turn off your CRT before rebooting**
5. Reboots → GRUB boots entry 0 → Wayland squashfs → HD mode

### Switching HD → CRT (X11)

1. Open Mode Switcher from the CRT Tools menu
2. Select **Switch to CRT Mode**
3. The tool:
   - Backs up current Wayland HD configs
   - Restores CRT configs (Xorg, switchres, EmulationStation, video output settings)
   - Remounts `/boot` read-write
   - Changes `set default="1"` in `grub.cfg` → CRT entry
   - Remounts `/boot` read-only
4. Reboots → GRUB boots entry 1 → X11 squashfs → CRT mode

### Safety

- The `/boot` partition is remounted read-write only for the instant the `grub.cfg` line is changed, then immediately locked read-only again
- Your CRT is never exposed to HD-mode signals — configs are fully swapped before the reboot that loads the new display stack
- No `grub-set-default` tool required — `grub.cfg` is a plain text file edited directly

---

## Removing CRT Mode Entirely (RESTORE)

Runs the full RESTORE to return to a clean Wayland-only system:

```bash
/userdata/system/Batocera-CRT-Script/Batocera_ALLINONE/Batocera-CRT-Script-v43.sh RESTORE
```

This will:
1. Remove all CRT configs and restore Wayland defaults
2. Remove the CRT boot entry from GRUB
3. Delete `/boot/crt/` entirely — reclaims ~4.4GB on the boot partition (squashfs ~3.2GB + rufomaculata ~1.1GB + kernel + initrd + overlay)
4. Delete `/boot/boot-custom.sh`
5. Return GRUB to single Wayland-only boot
6. Reboot — system is back to factory Wayland state
