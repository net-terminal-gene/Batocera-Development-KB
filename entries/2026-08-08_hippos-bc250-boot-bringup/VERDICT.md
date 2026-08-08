# VERDICT — HippOS BC-250 boot bring-up

## Status: FIXED

## Summary

HippOS `0.5.3-dev.3` on BC-250 now boots to EmulationStation (DisplayPort-0 @ 1920×1080). Kernel/console were never the hard failure; systemd wait paths + opaque GRUB hid progress. Live EFI/`@rootfs` edits: emergency debug-init for SSH, then graphical LTS+amdgpu GRUB with stallers masked. User confirmed ES on screen 2026-08-08.

## Plan vs reality

Planned “diagnose then fix.” Reality: binary proof via `init=/bin/bash` → keyboardless debug-init with NM/sshd → graphical reboot. No upstream PR; changes are on the live drive + local `hippos-linux/docs/` templates.

## Root Causes

1. systemd device/network waits (fstab, wait-online, remote-fs/NFS)
2. Stock GRUB quiet/hidden + non-LTS default obscured boot state
3. Rescue without udev = dead USB keyboard
4. Image uses NetworkManager only for DHCP

## Changes Applied

Authoritative detail: [research/01-exact-live-disk-changes.md](research/01-exact-live-disk-changes.md).

| Location | Change |
|----------|--------|
| `@rootfs` `/etc/fstab` | LABEL=EFI + LABEL=HippOS `@userdata`, `nofail`, 5s device timeout |
| `@rootfs` `/usr/local/sbin/hippos-debug-init` | **NEW** — udev/dbus/NM/sshd then bash |
| `@rootfs` `/etc/ssh/sshd_config.d/99-debug-init.conf` | **NEW** — root password auth, UsePAM no |
| `@rootfs` `/etc/shadow` | root password set to `linux` (via debug-init `chpasswd`) |
| `@rootfs` systemd masks → `/dev/null` | wait-online, remote-fs, nfs-client, hippos-select-kernel, hippos-update-grub, network-roms*, waydroid, nvidia-* stubs |
| `@rootfs` `graphical.target.wants` | ensure hippos-xserver / session / es / hotkeys |
| EFI `grub/grub.cfg` | default: LTS graphical + amdgpu; fallback: debug-init no GPU |
| EFI FAT | fsck.vfat dirty-bit repair (one-time) |
| Local `hippos-linux/docs/*` | templates: debug-init, grub cfgs, enable-graphical.sh |

## Unanticipated bugs

- Raw patching strings inside btrfs rootfs → **checksum verify failed**; required pristine reflash. Never raw-edit btrfs again.
- First debug-init used dhclient path; image has only NetworkManager — fixed before successful SSH.

## Models used

Cursor agent session (Composer) with SSH/rsync to Batocera and HippOS.

## What worked / what didn't

| Worked | Didn't |
|--------|--------|
| `init=/bin/bash` as binary hang test | Assuming amdgpu ERROR lines = hard hang |
| debug-init + NM for keyboardless SSH | Leaving Batocera shutdown before verifying NM path |
| Mask wait-online + LTS+amdgpu GRUB | Relying on Magic Keyboard without udev |
| Offline edit from Batocera `@rootfs` mount | Editing `/media/HippOS` thinking it is rootfs |

## Live disk caveats

Recovery config, not stock. Network ROM / NFS / wait-online / auto-GRUB paths were masked; SSH is loosened (`root`/`linux`). Details: [research/02-live-disk-caveats.md](research/02-live-disk-caveats.md).

## Follow-up (upstream / lead)

Bring-up is **FIXED** on the live disk. Packaging for a fresh flash is still open: see [design/proposed-flash-boot-flow.md](design/proposed-flash-boot-flow.md) (visible GRUB, latest default, LTS choice, first-boot grub policy, systemd wait hardening).
