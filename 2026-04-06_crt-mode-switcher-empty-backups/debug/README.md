# Debug — Mode Switcher Empty Backups

## Verification

```bash
# Check backup files exist
ssh root@batocera.local "find /userdata/Batocera-CRT-Script-Backup/mode_backups -type f | sort"

# Check backup file contents
ssh root@batocera.local "cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_mode.txt 2>/dev/null || echo MISSING"
ssh root@batocera.local "cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_output.txt 2>/dev/null || echo MISSING"
ssh root@batocera.local "cat /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/video_output.txt 2>/dev/null || echo MISSING"
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Mode switcher asks for boot resolution every time | `get_crt_boot_resolution()` returns empty — backup `video_mode.txt` missing AND `global.videomode` missing from `batocera.conf` |
| Mode switcher asks for HD output every time | `get_current_hd_output()` returns empty — backup `video_output.txt` missing |
| Mode switcher asks for CRT output every time | `get_current_crt_backup_output()` and `get_current_crt_output()` both return empty — backup missing AND `global.videooutput` missing from `batocera.conf` |
| Backup directories exist but are empty | `run_mode_switch_ui()` never completed a full cycle (user cancelled or script was interrupted) |

## Initial SSH Snapshot — Single-Boot v43ov (2026-04-06)

```
=== Current Mode ===
CRT mode (videomodes.conf exists)

=== global.videomode in batocera.conf ===
NOT FOUND

=== global.videooutput in batocera.conf ===
NOT FOUND

=== mode_backups directory tree ===
(empty — 0 files in either crt_mode/ or hd_mode/)

=== batocera-resolution currentMode ===
(empty)

=== batocera-resolution listOutputs ===
(empty)

=== videomodes.conf Boot_ entries ===
641x480.60.00059:Boot_480i 1.0:0:0 15KHz 60Hz
769x576.50.00060:Boot_576i 1.0:0:0 15KHz 50Hz
1028x576.50.00061:Boot_576p 1.0:0:0 15KHz 50Hz
```

## Post-Cycle Snapshot — Single-Boot v43ov (2026-04-06)

After completing one full CRT→HD→CRT round trip, all settings recalled:

```
[16:42:37]: Config check - HD: HDMI-2, CRT: DP-1, Boot: Boot_576i 1.0:0:0 15KHz 50Hz
[16:42:37]: Needs - HD: false, CRT: false, Boot: false, All configured: true
```

Backup state: CRT 25 files, HD 11 files.
