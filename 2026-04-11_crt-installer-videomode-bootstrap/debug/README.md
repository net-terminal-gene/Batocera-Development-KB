# Debug — CRT Installer: Bootstrap global.videomode and global.videooutput

## Verification

```bash
# After install — confirm CRT values written to batocera.conf
batocera-settings-get global.videooutput   # expect: DP-1 (or chosen output)
batocera-settings-get global.videomode     # expect: Boot_576i 1.0:0:0 15KHz 50Hz (or chosen profile)

# Confirm HD backup pre-populated
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/video_mode.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/video_output.txt

# Confirm CRT backup pre-populated
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_mode.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_output.txt

# After first boot — confirm ES shows correct Video Mode (not "Auto")
batocera-settings-get global.videomode
DISPLAY=:0.0 batocera-resolution currentMode

# After mode switcher CRT→HD switch — confirm HD values restored
batocera-settings-get global.videomode     # expect: default (or user's prior HD value)
batocera-settings-get global.videooutput   # expect: empty or user's prior HD output

# After mode switcher HD→CRT switch — confirm CRT values restored (full precision)
batocera-settings-get global.videomode     # expect: Boot_576i... (no truncation)
batocera-settings-get global.videooutput   # expect: DP-1
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| `global.videomode` still missing after install | Step 4 insertion point wrong; check batocera.conf write block line numbers |
| `global.videomode` shows truncated value | `batocera-resolution listModes` unavailable during install (SSH/no DISPLAY); static mapping fallback not triggered |
| HD backup contains CRT values | Steps 1–2 ran after Step 4 (ordering violation) |
| Mode switcher still re-picks all 3 settings | Backup dir path mismatch between installer and mode switcher (`$MODE_BACKUP_DIR`) |
| ES shows "Auto" in Video Mode after install | Boot_ name written to `batocera.conf` doesn't match any entry in `batocera-resolution listModes` |
| Black screen on Wayland dual-boot first CRT boot | `global.videooutput` not written or wrong value |
