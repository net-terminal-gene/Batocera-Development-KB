# 00 — v43 Wayland Factory Settings (Baseline)

**Date:** 2026-02-20
**State:** Factory Wayland v43 — no CRT Script installed, no dual-boot configured.

---

## System Info

| Field | Value |
|---|---|
| Batocera version | `43-dev-13c569bd4a 2026/02/16 12:08` |
| Kernel | `6.18.9 #1 SMP PREEMPT_DYNAMIC Mon Feb 16 12:34:20 Europe 2026 x86_64` |
| Boot mode | EFI |
| Display stack | **Wayland** (labwc PIDs: 2185, 2249) |

## Kernel Command Line

```
BOOT_IMAGE=/boot/linux label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0 initrd=/boot/initrd.gz
```

## Disk Space

```
Filesystem      Size  Used Avail Use% Mounted on
/dev/nvme0n1p1   10G  4.4G  5.7G  44% /boot
/dev/nvme0n1p2  1.8T  140M  1.7T   1% /userdata
```

## /boot/boot/ (Wayland boot files)

```
total 4501016
drwxr-xr-x 3 root root       8192 Feb 16 18:30 .
drwxr-xr-x 7 root root       8192 Jan  1  1970 ..
-rwxr-xr-x 1 root root 3411271680 Feb 16 18:30 batocera
-rwxr-xr-x 1 root root         10 Feb 16 18:30 batocera.board
-rwxr-xr-x 1 root root     751170 Feb 16 18:30 initrd.gz
-rwxr-xr-x 1 root root   23068672 Feb 16 18:30 linux
-rwxr-xr-x 1 root root 1173901312 Feb 16 18:30 rufomaculata
drwxr-xr-x 2 root root       8192 Feb 16 18:30 syslinux
-rwxr-xr-x 1 root root        458 Feb 16 18:30 syslinux.cfg
```

## /boot/crt/

**Does not exist.** (Expected — no dual-boot configured.)

## /boot/boot-custom.sh

**Does not exist.** (Expected — no CRT Script installed.)

## grub.cfg

```
set default="0"
set timeout="1"

menuentry "Batocera.linux (normal)" {
    echo Booting Batocera.linux... (grub2)
    linux /boot/linux label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
    initrd /boot/initrd.gz
}

menuentry "Batocera.linux (verbose)" {
    echo Booting Batocera.linux... (grub2)
    linux /boot/linux label=BATOCERA vt.global_cursor_default=0
    initrd /boot/initrd.gz
}
```

## syslinux.cfg

```
UI menu.c32

TIMEOUT 10
TOTALTIMEOUT 300

SAY Booting Batocera.linux...

MENU CLEAR
MENU TITLE Batocera.linux
MENU HIDDEN

LABEL batocera
	MENU LABEL Batocera.linux (^normal)
	MENU DEFAULT
	LINUX /boot/linux
	APPEND label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
	INITRD /boot/initrd.gz

LABEL verbose
	MENU lABEL Batocera.linux (^verbose)
	LINUX /boot/linux
	APPEND label=BATOCERA vt.global_cursor_default=0
	INITRD /boot/initrd.gz
```

## Xorg Configs (/etc/X11/xorg.conf.d/)

```
20-amdgpu.conf
20-radeon.conf
80-nvidia-egpu.conf
99-avoid-joysticks.conf
99-nvidia.conf
```

### 20-amdgpu.conf

```
Section "OutputClass"
     Identifier "Fix AMD Tearing and add VRR"
     Driver "amdgpu"
     MatchDriver "amdgpu"
     Option "TearFree" "true"
     Option "VariableRefresh" "true"
EndSection
```

## /lib/firmware/edid/

**Does not exist.** (Expected — no EDID binary deployed.)

## /userdata/system/Batocera-CRT-Script/

**Does not exist.** (Expected — CRT Script not installed.)

## Phase Flag

**Does not exist.** (Expected — no dual-boot install in progress.)

## batocera.conf

Stock defaults — no CRT Script modifications. First 20 lines:

```
# ------------ A - System Options ----------- #

## Security
## Enable this to enforce security, requiring a password to access the network share.
#system.security.enabled=0

## Services
# exampe: system.services=service1 service2
#system.services=

## Display rotation
## Leave commented out -> Auto.
## 0 -> No rotation.
## 1 -> Rotate 90 degrees clockwise.
## 2 -> Rotate 180 degrees clockwise.
## 3 -> Rotate 270 degrees clockwise.
#display.rotate=0

## Power button behavior
## Change what the power button does when pressed.
```

---

## Summary

This is a clean v43 Wayland factory state:
- Single-boot GRUB with two entries (normal + verbose), both pointing to `/boot/linux` and `/boot/initrd.gz`
- No `/boot/crt/` directory
- No `/boot/boot-custom.sh`
- No CRT Script directory on `/userdata`
- No phase flag
- No `/lib/firmware/edid/` directory
- `20-amdgpu.conf` present in squashfs with `TearFree=true` and `VariableRefresh=true`
- 5.7GB free on `/boot`, 1.7TB free on `/userdata`
