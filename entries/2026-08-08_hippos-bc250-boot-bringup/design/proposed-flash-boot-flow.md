# Proposed product flash → boot flow (upstream ask)

**Audience:** HippOS lead engineer conversation.  
**Status:** Proposal (not shipped). Live BC-250 disk is a **proof**, not this packaged UX.  
**Related:** live recovery inventory in `research/01-exact-live-disk-changes.md`.

---

## Today (fresh `0.5.3-dev.3` flash, no live patches)

1. Flash image → reboot to HippOS EFI.
2. GRUB is effectively invisible (`GRUB_TIMEOUT=0` / `hidden` in `etc/default/grub`).
3. One entry boots (on this image: **7.1.7**), quiet-ish cmdline. Both kernels can exist under `@rootfs/boot`, but the user does not get a real picker.
4. First boot runs `hippos-update-grub` → `update-grub-first-boot` → `hippos-upgrade update-grub`, regenerating **EFI** `/boot/efi/grub/grub.cfg` (not `/boot/grub` on btrfs).
5. systemd continues into graphical. On BC-250 that path felt “stuck” (device waits / wait-online / remote-fs style stalls) even after root was mounted.
6. Non–BC-250 boxes that boot cleanly never notice; they land in ES on the newest kernel.

**Summary:** one silent path, newest kernel preferred, no deliberate LTS choice, opaque when systemd stalls.

---

## If the fix is implemented (desired UX)

Goal: **one image for everyone**. Default stays newest kernel. BC-250 (and anyone who needs it) can pick LTS at GRUB. Boot must finish to ES without hand-editing the disk.

### Flash → first boot

1. User flashes the new image and powers on.
2. **Visible GRUB menu** for a few seconds (e.g. 5–8s), every boot (or until a remembered kernel choice is saved).
3. Menu entries:

| Entry | Kernel | Who |
|-------|--------|-----|
| HippOS (latest) | e.g. `7.1.7-hippos` | **Default** — everyone else |
| HippOS (LTS) | e.g. `6.18.x-hippos-lts` | BC-250 / recovery |
| Optional: recovery / verbose | LTS or latest + less quiet | support |

4. No keypress → **latest** boots (no BC-250 tax on normal users).
5. BC-250 user selects **LTS** once. Ideal: GRUB remembers (`saved` / `grubenv`) so they do not re-pick every reboot.
6. Kernel mounts `@rootfs`, systemd starts **without** the long stalls from the bring-up.
7. `hippos-xserver` → `hippos-es` → EmulationStation.
8. First-boot `update-grub` must **regenerate that same dual-kernel menu**, not collapse to a single quiet “latest only” entry.

### Diagram

```text
Flash new image
    → GRUB menu (visible)
         ├─ [default] Latest kernel  → normal users → systemd → ES
         └─ [choice]  LTS kernel     → BC-250       → systemd → ES
    → update-grub on first boot regenerates the SAME dual menu
    → systemd does not sit on wait-online / remote-fs for minutes
```

---

## What “the fix” must include (not only GRUB labels)

A dual-kernel menu alone is not enough for BC-250. From the bring-up that reached ES:

### 1. GRUB policy

- Visible timeout / menu.
- Explicit entries for **latest** and **LTS** (both already ship in the image).
- Default = latest.
- Optional: persist last selection.
- `hippos-upgrade update-grub` / first-boot must emit this into **`/boot/efi/grub/grub.cfg`**.

### 2. Boot reliability (all hardware)

- Safer fstab: `LABEL=` + `nofail` + short `x-systemd.device-timeout` (what landed on the live disk).
- Do not block appliance boot for minutes on `NetworkManager-wait-online` / remote-fs / NFS wants.
- First-boot grub rewriter must not erase recovery / dual-kernel policy.

### 3. BC-250 guidance (docs / Discord)

- Prefer **LTS** on Cyan Skillfish / BC-250.
- ACPI / RDSEED / early amdgpu HPD noise can look scary; with a proper boot they are not the hang.
- SSH remains available for support (`system.ssh.enabled`).

### 4. Not the default product path

- `init=/bin/bash` / custom debug-init: support/recovery only.
- Forcing LTS as the only kernel for all users.

---

## One-line ask for the lead

Can first-boot / `hippos-upgrade update-grub` ship a **visible dual-kernel EFI menu (latest default, LTS selectable + preferably remembered)**, and harden early systemd so BC-250 (and others) actually reach ES without silent multi-minute stalls?

---

## Stock hooks in tree (context)

| Path | Role |
|------|------|
| `overlays/rootfs/etc/default/grub` | `GRUB_TIMEOUT=0`, `hidden`, `quiet loglevel=3` |
| `overlays/rootfs/usr/lib/systemd/system/hippos-update-grub.service` | First boot when no `/var/lib/hippos/grub-updated` |
| `overlays/rootfs/usr/lib/hippos/update-grub-first-boot` | Calls `hippos-upgrade update-grub` if `enable_bootloader` |
| `overlays/rootfs/usr/sbin/update-grub` | Wrapper → `hippos-upgrade update-grub` (EFI target) |

Live proof used LTS + stall masks → ES; packaging that into the above hooks is the upstream work.
