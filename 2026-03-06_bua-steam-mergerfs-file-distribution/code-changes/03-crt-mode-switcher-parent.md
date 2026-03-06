# Change 03: CRT — mode_switcher.sh (Parent Script)

## Status: DEPLOYED TO REMOTE BATOCERA

## File

**Local repo path:** `Batocera-CRT-Script/userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher.sh`
**Remote path:** `/userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher.sh`

This is the main HD/CRT Mode Switcher script. It sources 4 modules (`01_mode_detection.sh`, `02_hd_output_selection.sh`, `03_backup_restore.sh`, `04_user_interface.sh`). By defining `CRT_ROMS` here, all modules inherit it.

## What Was Changed

Added the `CRT_ROMS` variable definition after the script directory definitions and before the log file path.

## Diff

```diff
 CRT_BACKUP_DIR="/userdata/Batocera-CRT-Script-Backup/BACKUP"
 CRT_BACKUP_CHECK="${CRT_BACKUP_DIR%/*}/backup.file"
 
+# Pin CRT tools to internal drive to avoid mergerfs scattering to external drives
+if [ -d "/userdata/.roms_base" ]; then
+  CRT_ROMS="/userdata/.roms_base"
+else
+  CRT_ROMS="/userdata/roms"
+fi
+
 # Log file
 LOG_FILE="/userdata/system/logs/BUILD_15KHz_Batocera.log"
```

## Why Here

`mode_switcher.sh` sources all 4 modules (lines 50-53). By defining `CRT_ROMS` before the `source` commands, all modules — especially `03_backup_restore.sh` which has 41 write targets — inherit the variable automatically. No module needs its own detection logic.

## This Script Has No Write Targets Itself

The parent script only defines variables, sources modules, and calls functions. All actual `/userdata/roms/crt` write operations are in `03_backup_restore.sh` (see Change 04).
