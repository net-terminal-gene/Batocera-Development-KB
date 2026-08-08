# Debug — HippOS BC-250 boot bring-up

## Verification

```bash
# From Mac after graphical boot
ssh root@hippos.local   # password: linux

hostname
cat /proc/cmdline
systemctl is-system-running
systemctl is-active hippos-xserver hippos-es
ls /dev/dri
DISPLAY=:0 xrandr --query
```

Offline edit mounts (from Batocera with HippOS as sda):

```bash
mkdir -p /tmp/hippos-efi /tmp/hippos-root
mount /dev/sda1 /tmp/hippos-efi
mount -o subvol=@rootfs /dev/sda3 /tmp/hippos-root
# do NOT use /media/HippOS for rootfs edits — that is @userdata
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Stuck ~30s+ between systemd lines | wait-online / remote-fs / fstab PARTUUID |
| Shell but dead USB keyboard | no udev (`init=/bin/bash` without udevd) |
| SSH never comes up in debug-init | NM/dbus not started; used dhclient path by mistake |
| X never starts / black after systemd | amdgpu blacklisted or `nomodeset` still on cmdline |
| BTRFS checksum / I/O errors | raw byte patch of rootfs — reflash from pristine `.zst` |
| GRUB silently rewritten | `hippos-update-grub` / `hippos-select-kernel` not masked |
