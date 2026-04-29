# Step 10 — Pre-Reboot CRT to HD Mode

**Date:** 2026-02-21
**Action:** Mode switcher ran CRT → HD switch with dual-boot fix. Verify syslinux boot default flipped and configs saved before reboot.
**Result:** SUCCESS — All 3 syslinux.cfg files now `DEFAULT batocera`, `MENU DEFAULT` on batocera entry, grub.cfg `default="0"`. CRT configs backed up (20 files). HD video output set to `eDP-1`. System will reboot into Wayland.

---

## Boot Default — Will reboot into Wayland

| File | DEFAULT | MENU DEFAULT on |
|---|---|---|
| `/boot/EFI/batocera/syslinux.cfg` | `DEFAULT batocera` | `LABEL batocera` |
| `/boot/boot/syslinux.cfg` | `DEFAULT batocera` | `LABEL batocera` |
| `/boot/boot/syslinux/syslinux.cfg` | `DEFAULT batocera` | `LABEL batocera` |
| `/boot/EFI/BOOT/grub.cfg` | `set default="0"` (Wayland) | — |

Dual-boot structure preserved — `LABEL crt` still present but not default:

```
DEFAULT batocera
MENU HIDDEN
LABEL batocera
	MENU DEFAULT
	MENU LABEL Batocera HD - Wayland (^normal)
LABEL verbose
	MENU LABEL Batocera HD - Wayland (^verbose)
LABEL crt
	MENU LABEL Batocera CRT (X11)
```

---

## Current System State (Still X11 until reboot)

| Check | Value |
|---|---|
| Display stack | X11 |
| Kernel | `BOOT_IMAGE=/crt/linux` with EDID params |
| `videomodes.conf` | GONE (removed by HD restore) |
| `global.videooutput` | `eDP-1` (HD internal screen) |
| `global.videooutput2` | `none` (multiscreen disabled) |
| CRT tools | HD-only: `mode_switcher.sh` + `gamelist.xml` + images |

---

## CRT Mode Backup (20 files)

Path: `/userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/`

### Metadata

```
MODE=crt
TIMESTAMP=2026-02-21T02:06:28+01:00
BATOCERA_VERSION=43ov-dev-13c569bd4a 2026/02/16 18:50
VIDEO_OUTPUT=none
VIDEO_MODE=
MONITOR_PROFILE=
BACKUP_SIZE_BYTES=59367
BACKUP_FILES_COUNT=20
```

### Saved Configs

- `userdata_configs/batocera.conf`
- `userdata_configs/videomodes.conf`
- `userdata_configs/es.arg.override`
- `userdata_configs/GunCon2_Calibration.sh`
- `userdata_configs/scripts/first_script.sh`
- `userdata_configs/scripts/1_GunCon2.sh`
- `emulator_configs/emulationstation/es_settings.cfg`
- `emulator_configs/emulationstation/es_systems_crt.cfg`
- `emulator_configs/mame/mame.ini`, `mame.ini.bak`, `ui.ini`, `plugin.ini`
- `emulator_configs/mame/ini/vertical.ini`
- `video_settings/video_output.txt`, `video_output2.txt`, `video_output3.txt`
- `video_settings/video_mode.txt`
- `video_settings/available_outputs.txt`, `available_modes.txt`

### Dual-boot note

No `boot_configs/` or `overlay/` in CRT backup — correctly skipped by `is_dualboot_system()` gate.

---

## HD Mode Backup (1 file)

Path: `/userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/`

| File | Content |
|---|---|
| `video_settings/video_output.txt` | `global.videooutput=eDP-1` |

HD backup is sparse — expected since Wayland was factory state before CRT install.

---

## Fix Verified

The `set_syslinux_boot_default("batocera")` function in `03_backup_restore.sh` correctly:
1. Changed `DEFAULT crt` → `DEFAULT batocera` in all 3 syslinux.cfg files
2. Moved `MENU DEFAULT` from `LABEL crt` to `LABEL batocera`
3. Changed `grub.cfg` from `default="1"` to `default="0"`
4. Preserved the dual-boot structure (`LABEL crt` still present)
