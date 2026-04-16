# Debug — CRT Boot Resolution Persistence

## Verification

```bash
# Check current boot resolution config
grep -E 'global.videomode|es.resolution|CRT.videomode' /userdata/system/batocera.conf

# Check syslinux CRT boot entry
grep -i 'label crt' -A5 /boot/boot/syslinux.cfg

# Check mode switcher backup contents
ls -la /userdata/Batocera-CRT-Script-Backup/mode_backups/
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt/batocera.conf 2>/dev/null | grep -E 'global.videomode|es.resolution'
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| CRT boot resolution resets to default after HD->CRT switch | backup_mode_files not capturing videomode/resolution |
| Boot_576i replaced with AUTO or wrong resolution | restore_mode_files not restoring videomode settings |
