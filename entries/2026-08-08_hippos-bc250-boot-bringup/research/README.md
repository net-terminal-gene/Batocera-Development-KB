# Research — HippOS BC-250 boot bring-up

## Findings

1. **RDSEED / ACPI `_PR.C00x` / amdgpu HPD dummy IRQ** on Cyan Skillfish: noisy but not the boot-blocker when `quiet` is on.
2. **Stock GRUB** shipped `timeout=0` and booted **7.1.7** with `quiet splash`; both kernels exist on disk (`6.18.43-hippos-lts` and `7.1.7-hippos`). BC-250 bring-up used **LTS**.
3. **systemd stalls** dominated the “stuck for minutes” feeling: fstab device waits, `NetworkManager-wait-online`, remote-fs/NFS wants.
4. **`init=/bin/bash`** proved rootfs boots; USB keyboard needs **udev**.
5. Image networking = **NetworkManager only** (no dhclient/dhcpcd).
6. Graphical path needs **amdgpu loaded** (`hippos-xserver` waits for `/dev/dri/card*`).

## Documents

| File | Content |
|------|---------|
| [01-exact-live-disk-changes.md](01-exact-live-disk-changes.md) | Authoritative list of every live change |
| [02-live-disk-caveats.md](02-live-disk-caveats.md) | What may be broken/degraded on the recovery disk |
