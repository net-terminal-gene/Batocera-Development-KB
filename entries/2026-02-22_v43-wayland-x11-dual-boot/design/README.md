# Build Manifest — Batocera-CRT-Script v43 (Wayland + X11 Dual-Boot)

**Purpose:** This document is the entry point for the agent building `Batocera-CRT-Script-v43.sh`.
Read this first. Then read the companion docs in the order listed below before writing any code.

---

## Document Map

### `docs/design/` — What to build

| File | What it is |
|---|---|
| `official-dual-boot-grub-architecture.md` | Full technical architecture: disk layout, GRUB config, initrd patching, overlay persistence, mode switcher, RESTORE. The definitive spec. |
| `official-flow-v43-wayland-x11.md` | User-facing step-by-step install flow (production). Maps directly to script prompts and output. |
| `beta-dual-boot-grub-architecture.md` | Beta variant of the architecture doc. Differences from production are explicitly called out. |
| `beta-testing-flow-v43-wayland-x11.md` | Beta user flow. Read alongside the official flow to understand where they diverge. |

### `docs/research/` — Why decisions were made

| File | What it is |
|---|---|
| `x11-image-extraction-and-boot-requirements.md` | **Read this second.** Low-level implementation spec: exactly what to extract from the image, how to patch initrd, GRUB/syslinux entries, overlay persistence, Phase 2 write map, space requirements. |
| `x11-crt-stack-requirements.md` | Every binary, config file, and runtime dependency required for CRT mode. The Phase 2 checklist. |
| `vanilla-x11-v43-live-findings.md` | Live SSH audit of a vanilla X11 v43 build. Ground truth for what exists before the script runs. |
| `wayland-v43-live-findings.md` | Live SSH audit of the Wayland v43 build. Ground truth for what is missing on Wayland. |
| `live-x11-system-findings.md` | Live SSH audit of a v42 system with CRT Script installed. Shows the target end state. ⚠️ See warning header — v42/post-install, not v43 baseline. |
| `batocera-linux-crt-integration.md` | How switchres, geometry, grid, and related tools are packaged in the batocera.linux Buildroot tree. |

---

## Beta vs Official — Build Strategy

**Build beta logic first. Official logic is written alongside it but commented out.**

The script ships as a single file. Beta testers run it immediately. When v43 goes public,
uncomment the `OFFICIAL` blocks and remove the `BETA` blocks — no restructuring needed.

### Comment flag convention

```bash
# OFFICIAL: hardcoded URL — uncomment when v43 ships publicly
# IMAGE_URL="https://mirrors.o2switch.fr/batocera/x86_64/stable/last/batocera-x86_64-43-YYYYMMDD.img.gz"

# BETA: user pastes URL at runtime — remove this block when going official
echo "Paste the direct download URL for the X11 beta image:"
read -r IMAGE_URL
# END BETA
```

- `# OFFICIAL:` — prefix on every commented-out official line. One block per logical unit.
- `# BETA:` / `# END BETA:` — wraps beta-only blocks that get deleted at launch.
- Never nest them. Keep each block self-contained and clearly delimited.

### Where the split lives — it is narrow

The beta/official divergence is **localized to one block** in the Wayland install path:
how `IMAGE_URL` and `MD5_URL` are established. Everything after that point is identical code.

```
Script entry
    │
    ▼
[ Display stack detection ]
    │
    ├── X11 detected ──► standard CRT install (no beta/official split at all)
    │
    └── Wayland detected ──► [ IMAGE URL BLOCK ] ← ONLY place with BETA/OFFICIAL split
                                    │
                                    ▼
                             All remaining logic is identical:
                             scan → validate MD5 → extract → patch initrd →
                             GRUB → phase flag → reboot → Phase 2 → overlay save
```

Do not introduce beta/official branching anywhere else in the script.

---

## Script Architecture — Key Facts

### Two-phase install (Wayland path only)

**Phase 1** runs on Wayland. It cannot configure CRT output — `xrandr` under Wayland does
not enumerate real DRM connectors. Phase 1 only sets up the boot environment:
- Validate image → extract to `/boot/crt/` → patch initrd → update GRUB → set phase flag → reboot

**Phase 2** runs after the first reboot into X11. The phase flag
(`/userdata/system/Batocera-CRT-Script/.install_phase=2`) tells the script to skip Phase 1
entirely and jump straight to CRT configuration.

### What gets extracted to `/boot/crt/`

All four files come from the VFAT partition of the `.img.gz` disk image:

| Source (inside image VFAT) | Destination |
|---|---|
| `boot/batocera` | `/boot/crt/batocera` (~3.2GB — X11 OS squashfs) |
| `boot/rufomaculata` | `/boot/crt/rufomaculata` (~1.1GB — board squashfs) |
| `boot/linux` | `/boot/crt/linux` (~23MB — X11 kernel) |
| `boot/initrd.gz` | `/boot/crt/initrd-src.gz` → patched → `/boot/crt/initrd-crt.gz` |

The kernel is extracted separately (not shared with Wayland) to guarantee kernel/module
version compatibility with the X11 squashfs.

### initrd patch — one sed, total replacement

```bash
sed -i 's|/boot_root/boot/|/boot_root/crt/|g' init
```

This single substitution covers squashfs mounts, overlay persistence, and the squashfs
update mechanism — every hardcoded path in the init script. Nothing else in the initrd
needs to change.

### GRUB CRT entry paths

Paths in `grub.cfg` are relative to the VFAT partition root:

```
menuentry "Batocera CRT (X11)" {
    echo Booting Batocera.linux... CRT Mode (X11)
    linux /crt/linux label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0
    initrd /crt/initrd-crt.gz
}
```

`/boot/crt/linux` on the mounted filesystem = `/crt/linux` in grub.cfg. Same for syslinux.

### Overlay persistence — CRITICAL

Batocera's root filesystem is overlayFS on tmpfs. **Nothing written in Phase 2 survives a
reboot unless explicitly saved.** `batocera-save-overlay` (stock) saves to
`/boot/boot/overlay` — the Wayland boot's overlay. The CRT boot needs its own:

```bash
# batocera-save-crt-overlay — deployed to /userdata/system/Batocera-CRT-Script/
OVERLAYFILE="/boot/crt/overlay"   # CRT-specific — not /boot/boot/overlay
```

`batocera-save-crt-overlay` MUST be called:
1. At the end of Phase 2 — before the final reboot (first-time creation of `/boot/crt/overlay`)
2. By the mode switcher when switching CRT → HD (snapshot before leaving X11)

The overlay save is not automatic on shutdown. If Phase 2 exits without calling it, all
config writes are lost and Phase 2 must run again.

### Phase 2 write sequence

In this order — each step writes to the tmpfs overlay, all persisted at Step 11:

1. Verify X11 (`xrandr` present)
2. Detect display connector → `/var/run/drmConn`
3. `mkdir -p /lib/firmware/edid` (absent on all vanilla v43 builds)
4. Write EDID binary via switchres
5. Update `/etc/switchres.ini` (file exists with defaults — overwrite with user profile)
6. Write `10-monitor.conf` (output enable)
7. Write `20-modesetting.conf` (modesetting DDX, TearFree=false, VariableRefresh=false)
   — `20-amdgpu.conf` ships in X11 squashfs with TearFree=true, VariableRefresh=true (x86
   board-level config, not Wayland-specific). Back it up and replace — mandatory on every install.
8. Write `/boot/boot-custom.sh` (generates `15-crt-monitor.conf` at each CRT boot)
9. Install patched `batocera-resolution`
10. EmulationStation configuration
11. Call `batocera-save-crt-overlay` → creates `/boot/crt/overlay`, syncs all of the above
12. Delete phase flag
13. Reboot

### Space requirements

| Check | Threshold | Notes |
|---|---|---|
| `/userdata` free (before download) | 5GB | Holds the `.img.gz` during download |
| `/boot` free (before extraction) | 4GB | Full `/boot/crt/` dir is ~4.4GB |

A fresh v43 Wayland install leaves ~5.7GB free on `/boot` (10GB partition, ~4.4GB used).
Confirmed on live hardware. No partition resize logic needed for v43.

### Boot config — syslinux is the primary bootloader

Batocera v43 uses **syslinux** (via `menu.c32`) for both EFI and Legacy BIOS boot.
The EFI boot chain is: `shimx64.efi` → `grubx64.efi` → syslinux (`ldlinux.e64` / `menu.c32`) → `syslinux.cfg`.

There are up to three identical syslinux.cfg files on the boot partition:

| Path | Purpose |
|---|---|
| `/boot/EFI/batocera/syslinux.cfg` | EFI boot (active path) |
| `/boot/boot/syslinux.cfg` | Legacy BIOS boot |
| `/boot/boot/syslinux/syslinux.cfg` | Legacy BIOS boot (alternate location) |

`grub.cfg` at `/boot/EFI/BOOT/grub.cfg` is only a removable-media fallback — it is **not** in the
active EFI boot path. The script updates it as a secondary fallback but syslinux.cfg is authoritative.

All syslinux.cfg copies must be kept in sync. The script loops through all three paths.

### Mode switcher — syslinux DEFAULT

```
DEFAULT batocera   → Wayland (HD mode)
DEFAULT crt        → X11 CRT mode
```

Plus `MENU DEFAULT` under the target label when using `menu.c32`. Mode switching = one sed
in a plain text file. Remount `/boot` read-write → edit → remount read-only.

### RESTORE

Removes all CRT infrastructure and returns to a clean Wayland-only system:
1. Restore Wayland configs
2. Remove `LABEL crt` from all `syslinux.cfg` files; restore `MENU DEFAULT` to `batocera`;
   restore `MENU HIDDEN`, `TIMEOUT 10`, and original label names
3. Remove CRT `menuentry` from `grub.cfg` fallback; reset `default="0"`, `timeout="1"`
4. `rm -rf /boot/crt/` (~4.4GB reclaimed)
5. `rm /boot/boot-custom.sh`
6. Reboot

---

## Key Constraints — Do Not Get These Wrong

1. **`initrd-crt.gz` lives inside `/boot/crt/`** — not at `/boot/initrd-crt.gz` root level.
2. **Syslinux/GRUB use `/crt/linux` and `/crt/initrd-crt.gz`** — not `/boot/linux`.
3. **The X11 kernel is NOT shared with Wayland** — always extracted to `/boot/crt/linux`.
4. **`batocera-save-crt-overlay` is not automatic** — must be called explicitly before every reboot that should persist CRT config.
5. **`20-amdgpu.conf` is in the X11 squashfs** — it is not Wayland-only. Backing it up and replacing it is mandatory on every fresh X11 v43 install.
6. **`/lib/firmware/edid/` does not exist** on any vanilla v43 build (Wayland or X11). Phase 2 must `mkdir -p` it.
7. **Phase 2 runs on X11** — the phase flag is the only detection mechanism. The script must check for the flag before anything else, then branch immediately.
8. **The beta/official split is in one place only** — how `IMAGE_URL` is set. Do not spread it.
9. **The script must work on stock X11 Batocera as if Wayland never existed.** Not every Batocera build uses Wayland. All dual-boot / Phase 1 / syslinux-modification code paths must be gated behind Wayland or Phase-flag detection. On a stock X11 system, the routing block must fall through to the standard CRT install flow with zero side effects — no boot config changes, no function calls, no file writes. Verify this invariant after every change to the routing or boot-config code.
