# Debug — HD Mode Wayland es.resolution Restore Fix

## Verification

```bash
# On Batocera (SSH)
grep -E 'es.resolution|videomode|videooutput' /userdata/system/batocera.conf | grep -v '^#'
grep es.resolution /boot/batocera-boot.conf

# Must match after fix — boot conf is authoritative for Wayland boot
batocera-settings-get-master -f /boot/batocera-boot.conf es.resolution

# Live compositor
XDG_RUNTIME_DIR=/run WAYLAND_DISPLAY=wayland-0 wlr-randr --output DP-1 | grep -E 'Enabled|current'

# Boot log
tail -60 /userdata/system/logs/display.log
grep -E 'Invalid|Hotplug|Setting resolution' /userdata/system/logs/display.log

# Mode switcher backup
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/video_mode.txt
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/es_resolution.txt
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Black screen after CRT→HD, CRT works | `es.resolution=default` → 165Hz hotplug loop |
| ES shows 1080 max, reboot is 1440 | Only `batocera.conf` updated; `batocera-boot.conf` stale |
| `Invalid output - none` in log | `global.videooutput2=none` (harmless noise) |
| `Invalid output - DP-1` + empty display list | Hotplug restart race (wlr-randr not ready) |
| `Setting resolution ... to 'default'` | HD restore did not pin explicit mode |
| Picture after SSH wlr-randr only | Boot config wrong; runtime fix temporary |

## Test matrix (pending)

1. Fresh CRT→HD with explicit 3440x1440@60 in mode switcher UI
2. CRT→HD with max-1920x1080 in mode switcher UI
3. Reboot HD twice without mode switch
4. HD→CRT→HD round trip
5. DP switch on HD side before reboot (user workflow)
