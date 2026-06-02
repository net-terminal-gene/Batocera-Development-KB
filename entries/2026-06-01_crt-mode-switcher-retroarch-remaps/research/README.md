# Research — Mode Switcher RetroArch Remaps Loss

## Findings

### User report summary

Mega Drive controller override saved at core level → `config/remaps/Genesis Plus GX/Genesis Plus GX.rmp`. After CRT→HD, remaps folder empty (expected for HD snapshot). After HD→CRT, remap not restored. Backup inspection shows duplicate structure: `emulator_configs/retroarch` and `emulator_configs/retroarch/retroarch`, remap only in nested path.

### Code locations (Batocera-CRT-Script)

**Backup** (`03_backup_restore.sh` ~608–612): no pre-delete before `cp -ra`.

**Restore HD** (~1224–1231): replaces live tree; if no HD retroarch snapshot, deletes live entirely.

**Restore CRT** (~1377–1384): replaces live from CRT snapshot.

**Install bootstrap** (`Batocera-CRT-Script-v43.sh` ~5452–5457): seeds `hd_mode/video_settings` only, not `emulator_configs/retroarch`.

### Batocera canonical paths

- `CONFIGS` = `/userdata/system/configs` (`batocera_common/paths.py`)
- `RETROARCH_CONFIG` = `/userdata/system/configs/retroarch` (`libretroPaths.py`)
- Remaps: `RETROARCH_CONFIG/config/remaps/` (S12populateshare creates `system/configs/retroarch/config/remaps`)

### cp behavior

When destination directory exists, `cp -ra source dest` copies **into** dest as `dest/$(basename source)`, producing `retroarch/retroarch/`. Restore already does `rm -rf` before copy on live system; backup does not.

### X11 vs Wayland

Same module for both. Dual-boot differs only for overlay/syslinux handling, not RetroArch swap.

## Related sessions

- `2026-01-26_hd-crt-mode-switcher` — original mode switcher (merged via #395)
- `2026-05-30_crt-hd-wayland-es-resolution-restore` — separate HD restore issue (es.resolution)
