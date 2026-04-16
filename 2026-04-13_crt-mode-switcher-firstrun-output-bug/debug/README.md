# Debug — CRT Mode Switcher: First-Run Pre-Selects eDP-1

## Verification

```bash
# Check what global.videooutput is at first Mode Switcher run
batocera-settings-get global.videooutput

# Check if crt_mode backup exists
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_output.txt

# Check what xrandr says is the active output
DISPLAY=:0.0 xrandr | grep " connected primary"

# Find the first-run output read in the mode switcher
grep -n "videooutput\|video_output\|first.run\|crt_mode" \
  /userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher_modules/03_backup_restore.sh | head -30
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Mode Switcher shows eDP-1 pre-selected for CRT output | `global.videooutput=eDP-1` in batocera.conf + empty crt_mode backup |
| Mode Switcher switches to eDP-1 on CRT→HD then back | Backup write/read cycle uses wrong output |
| After switch: CRT comes up on laptop screen | Mode Switcher restored eDP-1 as the output |
