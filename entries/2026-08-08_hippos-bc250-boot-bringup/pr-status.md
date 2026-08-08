# PR Status — HippOS BC-250 boot bring-up

## No PR yet

Live disk recovery + local helper scripts under `hippos-linux/docs/` only.

**Product proposal for lead:** [design/proposed-flash-boot-flow.md](design/proposed-flash-boot-flow.md)

Candidates for a future upstream PR (not filed):

- Visible dual-kernel EFI menu: **latest default**, **LTS selectable** (+ preferably remembered via grubenv)
- First-boot / `hippos-upgrade update-grub` must regenerate that menu (not collapse to quiet latest-only)
- Safer default fstab (`LABEL=` + `nofail` + short `x-systemd.device-timeout`)
- Soften / mask `NetworkManager-wait-online` (and remote-fs/NFS wants) on appliance images
- Document BC-250: prefer LTS; RDSEED/ACPI noise expected; debug-init is recovery-only
