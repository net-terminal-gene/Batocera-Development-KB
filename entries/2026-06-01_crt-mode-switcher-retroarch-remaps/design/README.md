# Design — Mode Switcher RetroArch Remaps Loss

## Architecture

Mode switcher (`mode_switcher.sh`) on each transition:

1. `backup_mode_files(current_mode)` — snapshot live userdata to `mode_backups/{crt,hd}_mode/`
2. `restore_mode_files(target_mode)` — replace live userdata from target snapshot

RetroArch handling in `03_backup_restore.sh`:

```
Backup:  cp -ra /userdata/system/configs/retroarch → mode_backups/{mode}_mode/emulator_configs/retroarch
Restore: rm -rf live retroarch; cp -ra snapshot → live
```

Canonical Batocera remap path:

```
/userdata/system/configs/retroarch/config/remaps/<Core>/<Core>.rmp
```

Configgen launches games with `--config .../retroarchcustom.cfg`; remaps resolve under `RETROARCH_CONFIG/config/remaps/` (`/userdata/system/configs/retroarch`).

## Bug flow (nested cp)

```
First CRT backup:  emulator_configs/retroarch/          ← correct (dest did not exist)
Second CRT backup: emulator_configs/retroarch/          ← stale first snapshot
                   emulator_configs/retroarch/retroarch/ ← current live (has remaps)
Restore to live:   both layers copied → RA reads top-level config/remaps (empty)
```

## Intended vs actual separation

| Content | Intended per-mode? | Current behavior |
|---------|-------------------|------------------|
| CRT overlays, videomode-related RA cfg | Yes | Swapped |
| HD vanilla RA cfg | Yes | Swapped |
| Input remaps (.rmp) | No (user pref) | Swapped (fragile) |
