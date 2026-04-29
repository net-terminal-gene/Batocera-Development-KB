# Beta Test — Wayland → X11 Dual-Boot (v43)

## Purpose

End-to-end validation of the `Batocera-CRT-Script-v43.sh` dual-boot flow on real hardware. Each step is documented in a numbered `.md` file that captures the live system state via SSH before and after each action.

## Commands

| Command | What it does |
|---|---|
| `bato-doc` | SSH into Batocera, scan all relevant files/configs, write findings into the next numbered `.md` file, then stop. The user provides context for the filename. |

## `bato-doc` Procedure

When the user says `bato-doc`:

1. Read this README to know the current step number and what was last documented.
2. SSH into the Batocera system using `~/bin/ssh-batocera.sh`.
3. Scan the following areas (adjust per step — not all are relevant every time):
   - `/usr/share/batocera/batocera.version` — build version
   - `/proc/cmdline` — kernel boot line
   - `pgrep -x labwc` — display stack (Wayland vs X11)
   - `/boot/EFI/batocera/syslinux.cfg` — EFI syslinux config (active boot path)
   - `/boot/boot/syslinux.cfg` — Legacy BIOS syslinux config
   - `/boot/EFI/BOOT/grub.cfg` — GRUB config (fallback only)
   - `df -h /boot /userdata` — disk space
   - `ls -la /boot/boot/` — Wayland boot files
   - `ls -la /boot/crt/` — CRT boot files (if present)
   - `/boot/boot-custom.sh` — early boot script (if present)
   - `/etc/X11/xorg.conf.d/` — Xorg configs
   - `/lib/firmware/edid/` — EDID directory
   - `/userdata/system/Batocera-CRT-Script/` — script directory
   - `/userdata/system/Batocera-CRT-Script/.install_phase` — phase flag
   - `/userdata/system/batocera.conf` — system config (relevant lines)
   - `/etc/switchres.ini` — switchres config (if relevant)
4. Create the `.md` file in `beta-test-wayland-x11/` with the next number and user-provided context as filename.
5. Update the step log below.
6. Stop and wait for the user's next instruction.

## File Naming

```
00-v43-Wayland-factory-settings.md
01-<context-from-user>.md
02-<context-from-user>.md
03-FAIL-01-<context>.md          ← failure during step 03, first failure
03-FAIL-02-<context>.md          ← failure during step 03, second failure
04-<context-from-user>.md        ← next successful step continues numbering
...
```

Failures are numbered under their parent step: `{step}-FAIL-{n}-{context}.md`. The next successful step increments from the parent step number, not the fail count.

## Step Log

| Step | File | Description | Date |
|---|---|---|---|
| 00 | `00-v43-Wayland-factory-settings.md` | Factory Wayland v43 baseline — no CRT Script installed | 2026-02-20 |
| 01 | `01-added-batocera-crt-script-via-filezilla.md` | CRT Script directory transferred to `/userdata/system/` via FileZilla | 2026-02-20 |
| 02 | `02-ran-v43-script-wayland-detected-no-image.md` | Script ran, detected Wayland, entered Phase 1, no X11 image found — waiting at prompt | 2026-02-20 |
| 03 | `03-transferred-x11-image-scan-found.md` | X11 image transferred via FileZilla (4.3GB), scan found it — waiting at use/download/cancel prompt | 2026-02-20 |
| 03-FAIL-01 | `03-FAIL-01-md5-validation-failed-double-md5-url.md` | BUG: user pasted `.md5` URL, script doubled it to `.md5.md5` — failed. Fixed in script. | 2026-02-20 |
| 04 | `04-md5-passed-extract-initrd-grub-overlay.md` | MD5 passed, extracted 4 files to `/boot/crt/`, initrd patched, GRUB updated (3 entries, default=1), overlay script deployed — waiting at cleanup prompt | 2026-02-20 |
| 05 | `05-cleanup-phase-flag-ready-to-reboot.md` | Source image deleted, phase flag=2 written, Phase 1 complete — waiting at reboot prompt | 2026-02-20 |
| 06-FAIL-01 | `06-FAIL-01-reboot-booted-wayland-syslinux-not-grub.md` | BUG: Rebooted into Wayland — Batocera v43 uses syslinux (not GRUB) for EFI boot. grub.cfg was never in the active boot path. Script must modify syslinux.cfg instead. | 2026-02-21 |
| 06 | `06-syslinux-fix-phase1-rerun-pre-reboot.md` | Phase 1 re-run with syslinux fix — all 3 syslinux.cfg files updated, DEFAULT=crt, MENU DEFAULT on crt entry. Waiting at cleanup prompt. | 2026-02-21 |
| 07 | `07-reboot-x11-booted-phase2-ready.md` | SUCCESS: Rebooted into X11 via syslinux CRT entry. Kernel from `/crt/linux`, squashfs from `/boot/crt/`. Phase flag=2, ready for Phase 2. | 2026-02-21 |
| 08-FAIL-01 | `08-FAIL-01-phase2-complete-syslinux-crt-entry-removed.md` | BUG: Phase 2 ran but syslinux template overwrite destroyed CRT boot entry. Fixed by gating overwrite behind `IS_DUALBOOT_INSTALL`. | 2026-02-21 |
| 08 | `08-phase2-complete-syslinux-fix-pre-reboot.md` | Fresh reflash + fix. Phase 2 complete — CRT entry **preserved** in all 3 syslinux.cfg files, APPEND has CRT kernel params, Wayland entry clean. Ready to reboot. | 2026-02-21 |
| 09 | `09-crt-reboot-success.md` | SUCCESS: Rebooted into X11/CRT. `DEFAULT crt`, `MENU HIDDEN`, kernel has EDID params. All 3 syslinux fixes confirmed working. Ready for first-boot setup. | 2026-02-21 |
| 10-FAIL-01 | `10-FAIL-01-pre-reboot-crt-to-hd-mode.md` | BUG: Mode switcher saved configs but did not flip syslinux boot default. `DEFAULT crt` remained — reboot would return to CRT. Fixed by adding `is_dualboot_system()` + `set_syslinux_boot_default()` to mode_switcher modules. | 2026-02-21 |
| 10 | `10-pre-reboot-crt-to-hd-mode.md` | SUCCESS: Mode switcher flipped `DEFAULT batocera` in all syslinux.cfg, `MENU DEFAULT` on batocera, grub default=0. CRT backup 20 files. Dual-boot structure preserved. Ready to reboot into Wayland. | 2026-02-21 |
| 11-FAIL-01 | `11-FAIL-01-reboot-hd-wayland-wrong-rotation.md` | BUG: Rebooted into Wayland but screen in portrait (no rotation). `global.videooutput=eDP-1` set by mode_switcher broke ES display checker (empty settled list → "Invalid output" → rotation=0). Factory Wayland uses auto-detect. Fixed by skipping `restore_video_settings` for dual-boot HD. | 2026-02-21 |
