# Live Wayland v43 System — Findings & Gap Analysis

**Date:** 2026-02-19
**System:** Batocera v43-dev Wayland — kernel 6.18.9
**SSH source:** `batocera.local`
**Companion to:** `live-x11-system-findings.md`, `official-official-dual-boot-grub-architecture.md`

---

## System Identity

```
Batocera.linux 43-dev
Kernel: 6.18.9 SMP PREEMPT_DYNAMIC x86_64
Compositor: labwc (Wayland)
```

Wayland compositor confirmed running:
```
2245 /bin/sh /usr/bin/labwc-launch
2269 /usr/bin/labwc -d -C /userdata/system/.config/labwc
```

---

## Disk Layout (confirmed)

```
nvme0n1  1.8T
├── nvme0n1p1  10G   vfat   BATOCERA  → /boot         (4.4GB used, 5.7GB free)
└── nvme0n1p2  1.8T  ext4   SHARE     → /userdata      (140MB used, 1.7TB free)

Squashfs mounts (active):
  loop0  3.2GB  squashfs  → /overlay/base    (Wayland OS)
  loop1  1.1GB  squashfs  → /overlay/base2   (board/arch layer)
```

**Space for X11 install:** 5.7GB free on `/boot`. The full CRT directory (`/boot/crt/`) requires ~4.4GB (X11 squashfs ~3.2GB + rufomaculata ~1.1GB + kernel ~23MB + initrd-crt.gz ~1MB + overlay ≤100MB), leaving ~1.3GB to spare. Confirmed feasible — see `x11-image-extraction-and-boot-requirements.md` for the full space breakdown.

---

## Boot Configuration (EFI — GRUB is active)

**`/boot/EFI/BOOT/grub.cfg` (active bootloader):**
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

**`/proc/cmdline` (running kernel):**
```
BOOT_IMAGE=/boot/linux label=BATOCERA console=tty3 quiet loglevel=0
vt.global_cursor_default=0 initrd=/boot/initrd.gz
```

**No CRT kernel parameters present** — clean Wayland boot as expected.

**Boot partition layout:**
```
/boot/
├── boot/
│   ├── batocera        (3.2GB — Wayland squashfs)
│   ├── batocera.board  (text: board identifier)
│   ├── initrd.gz       (initramfs)
│   ├── linux           (kernel)
│   ├── rufomaculata    (1.1GB — board/arch squashfs)
│   ├── syslinux/       (syslinux files — legacy BIOS support, not active)
│   └── syslinux.cfg
└── EFI/BOOT/
    ├── BOOTX64.EFI     (shim)
    ├── grub.cfg        ← ACTIVE bootloader config (EFI/GRUB)
    └── ...
```

**Key clarification:** This v43 machine boots via **EFI/GRUB**, not syslinux. The syslinux files exist inside `/boot/boot/syslinux/` for legacy BIOS compatibility but are not the active bootloader. The CRT Script must modify `grub.cfg` — not syslinux.cfg — on this machine.

---

## Binary Audit: What Is Present vs Missing

| Binary | X11 v42 | Wayland v43 | Notes |
|---|---|---|---|
| `switchres` | ✅ | ❌ MISSING | Not built into Wayland squashfs |
| `xrandr` | ✅ | ❌ MISSING | Not built into Wayland squashfs |
| `libswitchres.so` | ✅ | ❌ MISSING | No switchres = no library |
| `geometry` | ✅ | ❌ MISSING | Depends on switchres |
| `grid` | ✅ | ❌ MISSING | Part of switchres package |
| `batocera-resolution` | ✅ (xorg patched) | ✅ (labwc variant) | **Wrong variant** — see below |
| `edid-decode` | ✅ | ✅ | Same binary, present in both |
| `S00bootcustom` stub | ✅ | ✅ | Same stub, calls `/boot/boot-custom.sh` |

**Confirmed absent from Wayland build:**
- `/etc/switchres.ini` — does not exist
- `/lib/firmware/edid/` — directory does not exist
- `/boot/boot-custom.sh` — not on boot partition (expected — nothing has written it yet)

---

## batocera-resolution on Wayland — Wrong Variant

The Wayland build ships `batocera-resolution.wayland-labwc` — not the xorg variant.

```bash
#!/bin/sh
log="/userdata/system/logs/display.log"
WLR_RANDR="wlr-randr"      ← Wayland-native display tool, NOT xrandr

_reconfigure_labwc() {
    local LABWC_PID
    LABWC_PID=$(pgrep -o -x labwc)
    ...
}
```

This variant uses `wlr-randr` (a Wayland-native tool for `wlroots`-based compositors) and
sends display reconfiguration commands to the `labwc` compositor process directly. It
**cannot inject arbitrary modelines** — Wayland compositors manage their own display
state and do not allow arbitrary EDID/modeline injection from userspace.

**Implication:** Even if switchres were somehow present on Wayland, `batocera-resolution`
could not apply its output. xrandr modeline injection is an X11-only mechanism.

---

## /etc/X11/xorg.conf.d/ — Present but Wayland-irrelevant (with one exception)

The Xorg config directory exists on Wayland with these files:

```
/etc/X11/xorg.conf.d/
├── 20-amdgpu.conf        ← ACTIVE (affects X11 sessions under Wayland, if any)
├── 20-radeon.conf        ← present
├── 80-nvidia-egpu.conf   ← present
├── 99-avoid-joysticks.conf ← present
└── 99-nvidia.conf        ← present
```

These files are in the squashfs. Under a pure Wayland session they have limited effect
(Wayland compositor owns display management), but they matter for any nested Xorg session.

### 20-amdgpu.conf — CONFLICTS with CRT requirements

**Wayland v43 version:**
```
Section "OutputClass"
    Identifier "Fix AMD Tearing and add VRR"
    Driver "amdgpu"
    MatchDriver "amdgpu"
    Option "TearFree" "true"      ← must be FALSE for CRT
    Option "VariableRefresh" "true" ← must be FALSE for CRT
EndSection
```

**X11 CRT version (from live v42 system):**
```
Section "OutputClass"
    Identifier "AMD via modesetting (amdgpu)"
    MatchDriver "amdgpu"
    Driver "modesetting"           ← different driver!
    Option "TearFree" "false"      ← correct for CRT
    Option "VariableRefresh" "false" ← correct for CRT
EndSection
```

The Wayland version keeps the `amdgpu` DDX driver with TearFree and VRR enabled — the
opposite of what CRT mode requires. In the X11 squashfs this file will be the X11 CRT
version already. But if the CRT Script Phase 2 writes `20-modesetting.conf` into the
overlay over the X11 squashfs, these settings are already correct in the X11 image.

**The live v42 system showed `20-amdgpu.conf.bak`** — the CRT Script backs up and
disables the original amdgpu config, then writes `20-modesetting.conf` in its place.
This backup/replacement step must happen during Phase 2 on the X11 boot.

---

## What the CRT Script Will and Won't Work On Out of the Box

### Running `Batocera-CRT-Script-v43.sh` from this Wayland build:

**What WILL work:**
- ✅ Wayland detection (labwc is running — script detects this correctly)
- ✅ Phase 1 flow: extracting X11 squashfs, writing `initrd-crt.gz`, modifying `grub.cfg`
- ✅ Space check — 5.7GB free on `/boot`, plenty of room
- ✅ `S00bootcustom` stub is already in the squashfs — will call `/boot/boot-custom.sh` on next boot
- ✅ `/userdata/system/` is writable — phase flag, videomodes.conf, configs all land here
- ✅ `edid-decode` is present — used by `boot-custom.sh` after Phase 1 writes the EDID binary

**What will NOT work without the X11 squashfs installed:**
- ❌ `switchres` — absent, cannot generate any modeline or EDID
- ❌ `xrandr` — absent, cannot set or query X11 display modes
- ❌ CRT output detection — `xrandr --query` will fail
- ❌ `batocera-resolution setMode` for CRT resolutions — wrong variant
- ❌ MAME switchres — no `switchres.ini`, no switchres binary
- ❌ RetroArch CRT switching — `crt_switch_resolution` requires xrandr path to work

**This is expected** — Phase 1 installs the X11 squashfs (which contains all missing
pieces). Phase 2, which runs after rebooting into X11, is where all CRT configuration
happens. Everything missing here is present in the X11 squashfs.

---

## Gaps Found in official-dual-boot-grub-architecture.md

The following items were discovered on the live Wayland system that are either absent
or under-specified in the current architecture doc:

### 1. EFI vs BIOS boot path is not clearly resolved

The doc mentions both grub.cfg and syslinux.cfg but does not clearly establish which
takes precedence on a v43 machine. The live system confirms:

- `/boot/EFI/BOOT/grub.cfg` — **active on EFI machines** (this machine)
- `/boot/boot/syslinux/syslinux.cfg` — **active on legacy BIOS machines only**

The two are mutually exclusive. The CRT Script must detect EFI vs BIOS at runtime and
modify the correct file. On EFI machines, syslinux.cfg modifications are ignored at boot.

Reliable EFI detection:
```bash
if [ -d /sys/firmware/efi ]; then
    BOOT_MODE="efi"   # modify /boot/EFI/BOOT/grub.cfg
else
    BOOT_MODE="bios"  # modify /boot/boot/syslinux.cfg (or /boot/EFI/BOOT/syslinux.cfg)
fi
```

### 2. The 20-amdgpu.conf conflict is not documented

The Wayland squashfs contains `20-amdgpu.conf` with `TearFree=true` and
`VariableRefresh=true`. These settings survive into the X11 overlay unless explicitly
overridden. The CRT Script must:

1. Back up `/etc/X11/xorg.conf.d/20-amdgpu.conf` → `20-amdgpu.conf.bak` (confirmed from live v42)
2. Write `/etc/X11/xorg.conf.d/20-modesetting.conf` with CRT-safe settings

This step is not currently documented in the architecture doc.

### 3. boot-custom.sh runs on BOTH boots via S00bootcustom

`S00bootcustom` is present in **both** the Wayland and X11 squashfs. It calls
`/boot/boot-custom.sh` if it exists. Since `/boot/` is the shared VFAT partition,
writing `boot-custom.sh` there means it runs on both boots.

The script handles this gracefully (checks `10-monitor.conf` for enabled output; exits
cleanly if none found) but this cross-boot behavior is not documented in the architecture.

The implication: `boot-custom.sh` must remain CRT-specific and must exit cleanly when
booting into Wayland (no `10-monitor.conf` → no enabled output → graceful exit).

### 4. /lib/firmware/edid/ directory must be created

The directory `/lib/firmware/edid/` does not exist on the Wayland build. The CRT Script
Phase 1 must create this directory on the X11 squashfs overlay before writing the EDID
binary. The architecture doc refers to writing `custom.bin` to this path but does not
note that the directory may not exist.

### 5. wlr-randr vs xrandr — not mentioned as a detection signal

The presence of `wlr-randr` and absence of `xrandr` on the Wayland build is an
additional Wayland detection signal. The architecture doc documents `pgrep labwc` and
`$XDG_SESSION_TYPE` as detection methods. `which xrandr` returning empty is a third
independent signal that can be used as a fallback or cross-check.

### 6. labwc config path

The labwc compositor reads its config from `/userdata/system/.config/labwc` — confirmed
from the running process arguments. This is on `/userdata/` (shared partition). If the
CRT Script ever needs to interact with labwc config (e.g., to set a wallpaper or launch
item), this is the correct path.

---

## Summary: What the X11 Squashfs Must Provide

Everything absent from the Wayland build that CRT mode requires must come from the
X11 squashfs. Confirmed absent on Wayland, confirmed present on X11 v42:

| Component | Must come from |
|---|---|
| `switchres` binary | X11 squashfs |
| `xrandr` binary | X11 squashfs |
| `libswitchres.so` | X11 squashfs |
| `geometry`, `grid` | X11 squashfs |
| `batocera-resolution` (xorg variant, base) | X11 squashfs |
| `/etc/switchres.ini` (default) | X11 squashfs |
| `/etc/X11/xorg.conf.d/20-amdgpu.conf` (CRT version) | X11 squashfs |
| `/lib/firmware/edid/` directory | Created by CRT Script Phase 2 |
| `/etc/switchres.ini` (user profile) | Written by CRT Script Phase 2 |
| `/etc/X11/xorg.conf.d/10-monitor.conf` | Written by CRT Script Phase 2 |
| `/etc/X11/xorg.conf.d/15-crt-monitor.conf` | Generated by boot-custom.sh at every boot |
| `/etc/X11/xorg.conf.d/20-modesetting.conf` | Written by CRT Script Phase 2 |
| `/boot/boot-custom.sh` | Written by CRT Script Phase 1 (to shared boot partition) |
| EDID binary (`/lib/firmware/edid/custom.bin`) | Written by CRT Script Phase 2 |
| CRT kernel params in grub.cfg or syslinux.cfg | Modified by CRT Script Phase 1 |
