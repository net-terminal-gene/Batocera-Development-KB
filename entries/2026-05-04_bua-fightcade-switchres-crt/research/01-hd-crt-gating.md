# Research — HD vs CRT detection for Fightcade Switchres

## Source

- Batocera-CRT-Script `Geometry_modeline/mode_switcher_modules/01_mode_detection.sh`
- `03_backup_restore.sh`: removes `/userdata/system/videomodes.conf` when switching to HD

## Finding

`detect_current_mode()` is **userdata-based**, not runtime-display-based:
1. If `/userdata/system/videomodes.conf` exists → report CRT
2. Else if `batocera.conf` contains `crt_switch_resolution` or `CRT CONFIG RETROARCH` → CRT
3. Else → HD

The mode switcher deletes `videomodes.conf` on proper HD switch, but **stale CRT userdata**
while actually booted HD/Wayland (dual-boot v43, interrupted switch, manual edits) can
still make step 1 or 2 true while the session is HD-shaped.

## Design implication

Fightcade wrapper must use **defense in depth**: Switchres binary present, runtime
videomode signal (`batocera-resolution currentMode` or equivalent), dual-boot boot
path when applicable, optional opt-in file. See session `design/README.md` § CRT
activation gates.
