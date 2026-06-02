# code-changes — 03_backup_restore.sh

**Branch:** `fix/crt-mode-switcher-retroarch-remaps` (uncommitted as of 2026-06-01)

## Changes

1. **`flatten_nested_emulator_config_backup()`** — merges `retroarch/retroarch/` (or `mame/mame/`) nested trees from prior bad backups; called on backup snapshot and live path during restore.

2. **Backup:** `rm -rf "${backup_dir}/emulator_configs/{mame,retroarch}"` before `cp -ra` so second+ backups do not nest.

3. **Restore (HD and CRT):** flatten backup tree before copy; flatten live tree after copy.

## File

`userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher_modules/03_backup_restore.sh`
