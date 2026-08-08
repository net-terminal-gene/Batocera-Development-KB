# Exact live-disk changes (HippOS on BC-250)

**Host when editing offline:** Batocera `batocera.local` / `10.23.6.77` with HippOS USB/NVMe as `/dev/sda` (later sole boot as `nvme0n1`).  
**Host when applying graphical prep:** HippOS via SSH after debug-init (`root` / `linux`).  
**Image:** `hippos-amd64-0.5.3-dev.3` (version `0.5.3-dev.3`).  
**Btrfs UUID:** `43d2fb61-96a6-4d87-bf0c-150fef2e3238` (LABEL=`HippOS`).  
**Subvols:** `@rootfs`, `@userdata`, `@overlay`.

Batocera auto-mounts LABEL=HippOS as **`/media/HippOS` = `@userdata` only**. Rootfs edits require:

```bash
mount -o subvol=@rootfs /dev/sda3 /tmp/hippos-root   # or nvme0n1p3
mount /dev/sda1 /tmp/hippos-efi                      # or nvme0n1p1 LABEL=EFI
```

---

## 1. `/etc/fstab` (`@rootfs`)

**Before (stock, caused ~30s “Expecting device” ladders):** hard `PARTUUID=…` mounts without short timeouts (EFI had `0 1` fsck semantics).

**After (current):**

```
LABEL=EFI /boot/efi vfat umask=0077,nofail,x-systemd.device-timeout=5 0 0
LABEL=HippOS /userdata btrfs defaults,noatime,commit=5,compress=zstd:1,subvol=@userdata,nofail,x-systemd.device-timeout=5 0 0
```

---

## 2. New file: `/usr/local/sbin/hippos-debug-init` (`@rootfs`)

**Mode:** `0755`  
**Source template (Mac):** `hippos-linux/docs/hippos-debug-init.sh`  
**Purpose:** GRUB `init=` target when systemd is bypassed.

**Behavior:**

1. Mount `proc` / `sys` / `dev` / `devpts`; remount `/` rw  
2. `tmpfs` on `/run`; dirs for sshd / NetworkManager / dbus  
3. Start `systemd-udevd`, `udevadm trigger` + `settle` (USB keyboard + NIC names)  
4. Start `dbus-daemon --system`  
5. Start `/usr/sbin/NetworkManager --no-daemon` (image has **no** dhclient/dhcpcd)  
6. Wait up to ~30s for a global IPv4  
7. `hostname hippos`; optional `avahi-daemon`  
8. `ssh-keygen -A`; `echo root:linux | chpasswd`; start `sshd`  
9. Print banner (`IF` / `IP`); `exec /bin/bash`

---

## 3. New file: `/etc/ssh/sshd_config.d/99-debug-init.conf` (`@rootfs`)

```
PermitRootLogin yes
PasswordAuthentication yes
UsePAM no
```

(Stock already had `PermitRootLogin yes` in `hippos.conf`; this forces password auth without PAM for emergency SSH.)

---

## 4. EFI GRUB: `/boot/efi/grub/grub.cfg` (FAT `LABEL=EFI`)

Backups created on disk (names may coexist):

- `grub.cfg.bak-pre-bash`
- `grub.cfg.bak-pre-debug-init`
- `grub.cfg.bak-pre-nm-init`
- `grub.cfg.bak-pre-graphical`

### Intermediate (debug-only) menu — superseded

Default entry used `init=/usr/local/sbin/hippos-debug-init` with `nomodeset` + `module_blacklist=amdgpu,radeon`.

### Current (graphical) menu — what boots ES

Template on Mac: `hippos-linux/docs/grub-graphical.cfg`

```
set default=0
set timeout=3
set timeout_style=menu

menuentry "HippOS graphical (LTS + amdgpu)" {
    ...
    linux /@rootfs/boot/vmlinuz-6.18.43-hippos-lts root=LABEL=HippOS rootfstype=btrfs rootflags=subvol=@rootfs rw random.trust_cpu=on amd_iommu=off iommu=off plymouth.enable=0 systemd.mask=NetworkManager-wait-online.service console=tty0
    initrd /@rootfs/boot/initrd.img-6.18.43-hippos-lts
}

menuentry "HippOS DEBUG init (udev+nm+sshd, no GPU)" {
    ...
    linux ... nomodeset module_blacklist=amdgpu,radeon ... init=/usr/local/sbin/hippos-debug-init ...
    initrd ...
}
```

**Kernel used for success:** `vmlinuz-6.18.43-hippos-lts` (not `7.1.7`).  
**Not on graphical cmdline:** `quiet`, `splash`, `nomodeset`, amdgpu blacklist, custom `init=`.

---

## 5. systemd masks (`/etc/systemd/system/<unit>` → `/dev/null`)

Applied by `hippos-enable-graphical.sh` (and earlier offline session for some):

| Unit | Why |
|------|-----|
| `NetworkManager-wait-online.service` | Classic multi-minute boot stall |
| `remote-fs.target` | NFS/remote wait ladder |
| `nfs-client.target` | same |
| `hippos-select-kernel.service` | Rewrites EFI GRUB / picks kernels |
| `hippos-update-grub.service` | Regenerates GRUB with hardcoded `quiet splash` |
| `hippos-network-roms.service` + `.timer` | Network ROM mounts at boot |
| `hippos-network-roms-discover.service` + `.timer` | LAN discovery |
| `waydroid-container.service` | Irrelevant stall risk |
| `nvidia-persistenced.service` | No NVIDIA on BC-250 |
| `nvidia-suspend.service` | stub |
| `nvidia-resume.service` | stub |
| `nvidia-hibernate.service` | stub |
| `nvidia-suspend-then-hibernate.service` | stub |

Also removed symlink:

- `/etc/systemd/system/network-online.target.wants/NetworkManager-wait-online.service`

**Earlier offline session** also removed/masked various `multi-user.target.wants` stallers (remote-fs, Samba/NFS stubs, flatpak firstboot, LXC, HHD, etc.). Current disk state: confirm with `ls -l /etc/systemd/system/*.wants` and `readlink` of masks above.

---

## 6. graphical.target.wants (ensured present)

Symlinks under `/etc/systemd/system/graphical.target.wants/`:

- `hippos-xserver.service`
- `hippos-session.service`
- `hippos-es.service`
- `hippos-hotkeys.service`

(plus pre-existing: `power-profiles-daemon`, `switcheroo-control`, `udisks2`)

---

## 7. FAT dirty bit (EFI)

Ran `fsck.vfat` on EFI partition during recovery (dirty bit from unclean unmount). One-time repair, not a content change.

---

## 8. Root password (runtime from debug-init)

`chpasswd` set **`root` / `linux`** when debug-init ran. That persists in `/etc/shadow` on `@rootfs` after the successful debug-init boot. Graphical boot still accepts that password for SSH.

---

## 9. What was NOT left as permanent “product” change

| Item | Note |
|------|------|
| Raw byte patches inside btrfs | **Abandoned** — caused BTRFS checksum failures; drive was re-flashed from pristine `.zst` before successful path |
| Mac image dual-kernel menu on `.img` | Built for experiments; live drive GRUB is what matters now |
| CRT settings in `hippos.conf` | Left `crt.enabled=false` (stock overlay); ES shown on DP @ 1080p |
| Upstream hippos-linux PR | None yet — live disk only + local `docs/` helpers |

---

## 10. Observed working state (2026-08-08)

```
hostname: hippos
IP: 10.23.6.77 (enp4s0) — also answers hippos.local
PID 1: systemd ; is-system-running: running
hippos-xserver: active
hippos-es: active
/dev/dri: card0, renderD128
xrandr: DisplayPort-0 connected 1920x1080
```

User confirmed EmulationStation visible.
