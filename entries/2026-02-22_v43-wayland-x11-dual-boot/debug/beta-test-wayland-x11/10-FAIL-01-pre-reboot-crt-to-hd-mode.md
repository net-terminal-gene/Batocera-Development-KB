# Step 10 — FAIL 01 — Pre-Reboot CRT to HD Mode

**Date:** 2026-02-21
**Action:** Verify mode switcher installation and saved configs before testing HD mode switch
**Result:** FAIL — Mode switcher saved configs but did **not** change syslinux boot default. All syslinux.cfg files still had `DEFAULT crt` after running the mode_switcher to switch to HD mode. The mode_switcher lacked dual-boot awareness — it swapped userdata configs (batocera.conf, emulator settings) but never flipped `DEFAULT crt` → `DEFAULT batocera` in syslinux, so a reboot would boot back into CRT instead of Wayland.

**Fix:** Added `is_dualboot_system()` detection and `set_syslinux_boot_default()` to mode_switcher modules. In dual-boot mode, the switcher now flips the `DEFAULT` line instead of restoring entire syslinux.cfg files, and skips overlay/boot-custom.sh manipulation (each boot env has its own).

---

## Boot Default — Will NOT reboot into Wayland

| File | DEFAULT |
|---|---|
| `/boot/EFI/batocera/syslinux.cfg` | `DEFAULT crt` |
| `/boot/boot/syslinux.cfg` | `DEFAULT crt` |
| `/boot/boot/syslinux/syslinux.cfg` | `DEFAULT crt` |
| `/boot/EFI/BOOT/grub.cfg` | `set default="1"` (CRT) |

The mode_switcher has not been run yet. To boot into Wayland, the mode_switcher (or manual edit) must change `DEFAULT crt` → `DEFAULT batocera`.

---

## Mode Switcher Installation

| Check | State |
|---|---|
| Main script | `/userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher.sh` (7807 bytes) |
| CRT wrapper | `/userdata/roms/crt/mode_switcher.sh` (xterm launcher) |
| `.keys` file | `/userdata/roms/crt/mode_switcher.sh.keys` (2068 bytes) |
| `gamelist.xml` | `/userdata/roms/crt/gamelist.xml` (4743 bytes) |

---

## CRT Mode Backup (24 files)

Path: `/userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/`

### Metadata

```
MODE=crt
TIMESTAMP=2026-02-21T01:43:38+01:00
BATOCERA_VERSION=43ov-dev-13c569bd4a 2026/02/16 18:50
VIDEO_OUTPUT=none
VIDEO_MODE=
BACKUP_SIZE_BYTES=104921654
BACKUP_FILES_COUNT=24
```

### Video Settings

| File | Content |
|---|---|
| `video_output.txt` | `global.videooutput=DP-1` |
| `video_mode.txt` | `global.videomode=769x576.50.00060` |
| `video_output2.txt` | present |
| `video_output3.txt` | present |
| `available_outputs.txt` | present |
| `available_modes.txt` | present |

### Boot Configs

- `boot/syslinux.cfg`
- `EFI/batocera/syslinux.cfg`
- `boot-custom.sh`

### Emulator Configs

- `emulationstation/es_systems_crt.cfg`
- `emulationstation/es_settings.cfg`
- `mame/mame.ini`, `mame.ini.bak`, `ui.ini`, `plugin.ini`
- `mame/ini/vertical.ini`

### Overlay

- `overlay/overlay.crt` (CRT overlay snapshot)

### Userdata Configs

- `batocera.conf`
- `videomodes.conf`
- `es.arg.override`
- `GunCon2_Calibration.sh`
- `scripts/first_script.sh`
- `scripts/1_GunCon2.sh`

---

## HD Mode Backup (1 file)

Path: `/userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/`

| File | Content |
|---|---|
| `video_settings/video_output.txt` | `global.videooutput=eDP-1` |

HD mode backup is sparse — only the video output is saved. This is expected since the system started as Wayland and the CRT script only captures what existed before CRT mode was applied.
