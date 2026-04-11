# Debug — Mode Switcher Truncated global.videomode

## Verification

```bash
# Check global.videomode precision
ssh root@batocera.local "grep '^global.videomode=' /userdata/system/batocera.conf"

# Compare against listModes
ssh root@batocera.local "batocera-resolution listModes | grep '769x576'"

# Check backup file
ssh root@batocera.local "cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_mode.txt"

# Check mode switcher log for save behavior
ssh root@batocera.local "grep -i 'video_mode\|Preserving\|Saved.*mode\|converting' /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -10"
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| ES Video Mode shows "Auto" instead of boot resolution | `global.videomode` in batocera.conf is truncated — doesn't match full-precision mode ID from `batocera-resolution listModes` |
| Mode switcher log says "Preserving existing" | Stale `video_mode.txt` backup has truncated value; line 821 guard prevents overwrite with correct resolved value |
| `batocera-resolution currentMode` returns empty | Normal in X11/CRT mode — tool is DRM/Wayland-based |

## Truncated videomode Snapshot — Wayland Dual-Boot v43 (2026-04-08)

After a fresh install, first mode switch cycle (CRT→HD→CRT), and reboot back to CRT:

```
=== batocera.conf ===
global.videooutput=DP-1              ← correct (written by mode switcher restore)
global.videomode=769x576.50.00       ← TRUNCATED (should be 769x576.50.00060)
es.customsargs=--screensize 769 576 --screenoffset 00 00

=== batocera-resolution listModes (grep 769x576) ===
769x576.50.00060:Boot_576i 1.0:0:0 15KHz 50Hz

=== batocera-resolution currentMode ===
(empty — does not work in X11 mode)

=== ES UI > System Settings > Video Mode ===
Shows "Auto" (769x576.50.00 doesn't match 769x576.50.00060)

=== Mode switcher log ===
Converting boot mode - input: 'Boot_576i 1.0:0:0 15KHz 50Hz', output: '769x576.50.00060'
Preserving existing CRT video_mode.txt from prior backup

=== video_mode.txt backup ===
global.videomode=769x576.50.00       ← stale value preserved by line 821 guard
```

Root cause: "Preserve existing backup" logic (line 821) protects stale truncated value instead of using the correctly resolved `769x576.50.00060`.
