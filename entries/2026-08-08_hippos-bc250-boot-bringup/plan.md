# HippOS BC-250 boot bring-up

## Agent/Model Scope

Composer + SSH to Batocera (`batocera.local`) for offline disk edits; SSH to HippOS (`hippos.local` / `10.23.6.77`) after debug-init; local helper scripts under `hippos-linux/docs/`.

## Problem

Flash HippOS `hippos-amd64-0.5.3-dev.3` to SPCC M.2 on BC-250. Boot appeared stuck: red ACPI/`RDSEED`/amdgpu HPD lines, no usable VT keyboard, no `hippos.local` SSH, multi-minute systemd gaps. Goal: get EmulationStation on a display.

## Root Cause

1. Stock EFI GRUB hid menus (`timeout=0`) and defaulted to noisy/quiet path; early console noise was mostly firmware/GPU init, not hard hangs.
2. systemd boot stalled on device/network waits (`PARTUUID` fstab without short timeouts; `NetworkManager-wait-online`; `remote-fs` / NFS wants).
3. `init=/bin/bash` rescue proved kernel+rootfs OK but left USB keyboard dead (no udev).
4. Image has NetworkManager, not dhclient/dhcpcd — debug networking must start NM + dbus.

## Solution

1. Offline-edit live drive from Batocera: fix fstab, install emergency init, rewrite EFI GRUB.
2. Prove SSH via `hippos-debug-init` (udev + dbus + NM + sshd).
3. Mask stallers; GRUB graphical entry: LTS kernel, amdgpu enabled (no `nomodeset`/blacklist), systemd default init.
4. Reboot → X + `hippos-es` on DP-0.

## Files Touched

See [research/01-exact-live-disk-changes.md](research/01-exact-live-disk-changes.md) for authoritative inventory. Local helpers only:

| Repo / path | File | Change |
|-------------|------|--------|
| hippos-linux (local) | `docs/hippos-debug-init.sh` | Emergency init template |
| hippos-linux (local) | `docs/grub-debug-init.cfg` | Debug GRUB template |
| hippos-linux (local) | `docs/grub-graphical.cfg` | Graphical GRUB template |
| hippos-linux (local) | `docs/hippos-enable-graphical.sh` | Mask + wants + fstab + grub apply |
| Live NVMe (HippOS) | EFI + `@rootfs` | See research inventory |

## Validation

- [x] `init=/bin/bash` reaches shell (keyboard may fail without udev)
- [x] debug-init: SSH `root`/`linux` @ `10.23.6.77`
- [x] Graphical boot: `systemctl is-system-running` → `running`
- [x] `hippos-xserver` + `hippos-es` active; xrandr DP-0 1920×1080
- [x] User confirms EmulationStation visible
