# Debug — Mode Switcher RetroArch Remaps Loss

## Verification

```bash
# Confirm nested backup structure (smoking gun)
ls -la /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/emulator_configs/retroarch/
ls -la /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/emulator_configs/retroarch/retroarch/ 2>/dev/null

# Find all remap files in backup vs live
find /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/emulator_configs/retroarch -name '*.rmp' 2>/dev/null
find /userdata/system/configs/retroarch -name '*.rmp' 2>/dev/null

# Mode switcher log
tail -80 /userdata/system/logs/BUILD_15KHz_Batocera.log | grep -i retroarch
```

## Manual workaround (reporter)

```bash
# Hoist nested remaps to canonical path (CRT mode)
SRC="/userdata/system/configs/retroarch/retroarch/config/remaps"
DST="/userdata/system/configs/retroarch/config/remaps"
if [ -d "$SRC" ]; then
  mkdir -p "$DST"
  cp -a "$SRC"/. "$DST"/
fi

# Rebuild clean CRT backup snapshot
BACKUP="/userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/emulator_configs"
if [ -d "$BACKUP/retroarch/retroarch" ]; then
  rm -rf "$BACKUP/retroarch"
  cp -ra /userdata/system/configs/retroarch "$BACKUP/retroarch"
fi
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Remap works in CRT, lost after first mode round trip | First backup OK; check if remap was created after first backup |
| Remap lost after second+ round trip | cp nesting corrupts CRT snapshot |
| Remap in backup under `.../retroarch/retroarch/config/remaps/` | Nested cp bug confirmed |
| Empty remaps in HD after switch | Expected (separate HD tree); not the restore bug |
| `config/remaps/` empty on CRT after restore but `.rmp` exists deeper | Restore copied nested tree; RA reads wrong level |
