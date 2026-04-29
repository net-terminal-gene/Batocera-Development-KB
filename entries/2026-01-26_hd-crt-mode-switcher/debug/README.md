# Debug — HD/CRT Mode Switcher

## Verification

```bash
# Check current mode
grep videooutput /userdata/system/batocera.conf

# Check overlay state
ls -la /boot/boot/overlay 2>/dev/null || echo "no overlay (HD mode)"

# Check display
DISPLAY=:0.0 xrandr | grep connected

# Check backups
ls -la /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/
ls -la /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/

# Check mode switcher log
tail -100 /userdata/system/logs/BUILD_15KHz_Batocera.log | grep -E "Backup|Restored"
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Black screen after switch | Stale X11 config in overlay; wrong output in 10-monitor.conf |
| ES VIDEO MODE shows "AUTO" | videomode not written to batocera.conf during backup |
| CRT tools missing from ES menu | es_systems_crt.cfg not copied to /userdata/system/configs/emulationstation/ |
| MAME configs wrong after switch | Folder swap didn't complete; check backup dirs |
| VNC not working in HD mode | /usr/bin/vnc not created from userdata scripts |
