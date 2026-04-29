# CRT Script v43 — Beta Testing Flow (Pre-Release)

**Date:** 2026-02-19
**Status:** Beta Testing — Pre v43 Public Release
**Companion to:** `official-flow-v43-wayland-x11.md` (Production), `beta-official-dual-boot-grub-architecture.md`

> **This document is temporary.** Once v43 is publicly released on batocera.org, use
> `official-flow-v43-wayland-x11.md` instead. This beta flow will be retired at that point.

---

## Who This Applies To

Beta testers running **Batocera v43 pre-release builds** on **x86_64 machines** who want to
test the CRT Script dual-boot flow before v43 is publicly released.

> **The Batocera-CRT-Script is x86_64 only.** Raspberry Pi and ARM boards are not supported.

> **Beta builds change frequently.** Always use the URLs we provide — do not reuse links
> from a previous session as the build date in the filename changes with every update.

---

## What You Need Before Starting

- x86_64 PC, Laptop, or NUC with a drive to flash
- SSH client:
  - Windows: PuTTY, Windows Terminal
  - Mac/Linux: built-in Terminal
  - iPhone/Android: Termius, JuiceSSH
- File transfer tool:
  - Windows: [WinSCP](https://wiki.batocera.org/winscp)
  - Mac/Linux: FileZilla or Terminal (`scp`)
- Flashing tool: Balena Etcher (any OS) or Rufus (Windows)
- Internet connection

---

## Pre-Requisite — Flash v43 Beta Wayland onto Your Drive

v43 beta is **not on batocera.org/download**. We provide the current build URL directly.

**We will supply the current link. Example format:**
```
https://mirrors.o2switch.fr/batocera/x86_64/butterfly/last/batocera-x86_64-43-YYYYMMDD.img.gz
```

1. Download the `.img.gz` to your PC/Mac using the link we provide
2. Flash it to your drive using **Balena Etcher** or **Rufus** — same as any Batocera install
3. Boot from the drive — you will be running v43 Wayland (labwc compositor)
4. Connect to your local network (wired or Wi-Fi)

---

## Step 1 — Connect via SSH

```
Host:     batocera.local
Username: root
Password: linux
```

---

## Step 2 — Manual CRT Script Install

The production `curl` one-liner is **not available for beta**. Install manually:

**On your PC/Mac:**

1. Download the beta CRT Script zip from the Google Drive link we provide
2. Extract the zip — you get a `Batocera-CRT-Script` folder
3. Transfer the entire `Batocera-CRT-Script` folder to `/userdata/system/` on your
   Batocera machine:

| Your device | Method |
|---|---|
| **Windows** | WinSCP → connect to `batocera.local` → drag `Batocera-CRT-Script` folder into `/userdata/system/` |
| **Mac/Linux** | `scp -r Batocera-CRT-Script root@batocera.local:/userdata/system/` |
| **USB drive** | Copy folder to USB → plug into Batocera → SSH and copy to `/userdata/system/` |

**Back in your SSH session, run:**

```bash
cd /userdata/system/Batocera-CRT-Script/Batocera_ALLINONE && chmod 755 Batocera-CRT-Script-v43.sh && ./Batocera-CRT-Script-v43.sh
```

---

## Step 3 — Script Detects Wayland Automatically

Identical to production. No action required:

```
Wayland display stack detected.
X11 is required for CRT mode.

A second X11 Batocera boot entry will be set up alongside
your existing Wayland install. Your ROMs, saves, and BIOS
files will be shared between both.
```

---

## Step 4 — Script Scans for X11 Image

Identical to production. The script automatically searches `/userdata/` and any connected
USB drives for a Batocera x86_64 `.img` or `.img.gz` file.

If a previously transferred file is found it will be offered first. If nothing is found,
the script moves to Step 5.

---

## Step 5 — X11 Image — Paste Download URL

This is the key difference from production. Instead of a fixed batocera.org URL, the
script prompts you to paste the direct download link for the current X11 beta build.

```
[ X11 Beta Image — Enter Download URL ]

  Paste the direct download link for the X11 beta image.
  (Right-click the file on the mirror → Copy Link Address)

  URL: _
```

**How to get the URL:**
1. Open the beta mirror link we provide in your browser
2. Right-click the `.img.gz` file for the latest build date
3. Select **Copy Link Address**
4. Paste it into the SSH terminal prompt

**Example of what a pasted URL looks like:**
```
https://mirrors.o2switch.fr/batocera/x86-64-v3/butterfly/last/batocera-zen3-x86-64-v3-43-20260217.img.gz
```

The script then **derives the MD5 URL automatically** by appending `.md5` — no second
URL needed:

```bash
MD5_URL="${IMAGE_URL}.md5"
# → https://mirrors.o2switch.fr/.../batocera-zen3-x86-64-v3-43-20260217.img.gz.md5
```

The script confirms both URLs before downloading:

```
[ Confirm Download ]

  Image: https://mirrors.o2switch.fr/.../batocera-zen3-x86-64-v3-43-20260217.img.gz
  MD5:   https://mirrors.o2switch.fr/.../batocera-zen3-x86-64-v3-43-20260217.img.gz.md5
         (derived automatically from image URL)

  (1) Yes, download
  (2) Enter a different URL
  (3) Exit
```

The same space check, progress bar, and error handling as production then apply:

```
[ Space Check ]

  /userdata  needs 5.0GB free  →  currently 8.3GB free  ✓
  /boot      needs 4.0GB free  →  currently 5.7GB free  ✓

  Space OK. Starting download...

batocera-zen3-x86-64-v3-43-20260217.img.gz
  2.1G / 4.4G [================>         ] 48%  8.2MB/s  eta 4m32s
```

If the download fails for any reason (network dropped, bad URL, disk full):

```
[ Download Failed ]

  An error occurred while downloading the X11 image.
  No changes have been made to your system.

  Error: Connection lost at 2.3GB / 4.4GB
  Partial file deleted.

  (1) Try again with same URL
  (2) Enter a different URL
  (3) Exit
```

---

## Step 6 — MD5 Validation

Identical to production. The script fetches the MD5 from the derived `.md5` URL at
validation time and compares it against the downloaded file:

```
[ MD5 Validation ]

  Checking file against mirror checksum...

  Expected:  9e534d3691cc6ba494240eb389971b42
  Got:       9e534d3691cc6ba494240eb389971b42

  ✓ Checksum verified. File is the correct X11 beta build.
```

If validation fails the file is rejected, nothing on the boot partition is changed, and
retry options are offered. A mismatch at this stage most commonly means the URL pointed
to the wrong build date — paste the correct link and try again.

---

## Steps 7–11 — Identical to Production

From this point the beta flow is **exactly the same** as the production flow:

| Step | What happens |
|---|---|
| **Step 7** | X11 files extracted to `/boot/crt/`: `batocera` (~3.2GB), `rufomaculata` (~1.1GB), `linux` (~23MB), `initrd-crt.gz` (patched initrd with `/boot_root/boot/` → `/boot_root/crt/`) — cleanup prompt for source image |
| **Step 8** | GRUB updated — CRT entry added using `/crt/linux` + `/crt/initrd-crt.gz`, set as default |
| **Step 9** | Phase 1 reboot into X11 |
| **Step 10** | Re-run script via SSH — Phase 2 auto-detected: connector detection, `edid/` dir creation, EDID binary, `switchres.ini` update, Xorg configs (including mandatory `20-amdgpu.conf` backup + replace), `boot-custom.sh`, patched `batocera-resolution`, `batocera-save-crt-overlay` call → creates `/boot/crt/overlay` |
| **Step 11** | Final reboot into CRT mode |

See `official-flow-v43-wayland-x11.md` Steps 7–11 for full detail.

---

## Switching Modes and RESTORE

Identical to production:

- **Mode Switcher** — HD/CRT Mode Switcher tool from EmulationStation > CRT Tools menu
- **RESTORE** — run `Batocera-CRT-Script-v43.sh RESTORE` to remove X11 and return to
  Wayland-only

---

## Beta vs Production — Summary of Differences

| | Beta | Production |
|---|---|---|
| v43 Wayland image | Provided mirror URL — flash manually | batocera.org/download — flash manually |
| CRT Script install | Manual zip → WinSCP/USB → SSH run | `curl` one-liner |
| X11 image URL | User pastes URL → script downloads | batocera.org — script downloads automatically |
| MD5 URL | Derived from pasted URL + `.md5` — auto-fetched | batocera.org — auto-fetched |
| X11 kernel extracted | ✅ `/boot/crt/linux` — identical | ✅ Identical |
| GRUB CRT paths | `/crt/linux` + `/crt/initrd-crt.gz` | ✅ Identical |
| Overlay persistence | `batocera-save-crt-overlay` → `/boot/crt/overlay` | ✅ Identical |
| Steps 3–11 | ✅ Identical | ✅ Identical |
