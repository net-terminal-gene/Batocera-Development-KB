# Debug — CRT Combo Mode Switch

## Verification

```bash
# Check if combo listener is running
ps aux | grep crt_combo_listener

# Check evdev devices available (which controllers the listener can see)
evtest --list

# Test combo detection without triggering mode switch (dry-run flag)
python3 /userdata/system/Batocera-CRT-Script/Geometry_modeline/crt_combo_listener.py --dry-run

# Check if HD settings backup exists
ls -la /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/

# Check current mode
grep -E "crt_switch_resolution|CRT CONFIG" /userdata/system/batocera.conf
test -f /userdata/system/videomodes.conf && echo "CRT Mode" || echo "HD Mode"

# Run headless mode switch manually (careful: will reboot!)
# bash /userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switch_headless.sh
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Combo listener not running after boot | `boot-custom.sh` not launching it, or Python crash on startup |
| Combo pressed but nothing happens | evdev button codes don't match expected; check with `evtest` |
| L2/R2 not registering as pressed | Controller uses analog axes (ABS_Z/ABS_RZ) instead of BTN_TL2/BTN_TR2; listener must handle both |
| Mode switch runs but HD Mode doesn't work | HD settings backup is stale, corrupt, or missing; check `mode_backups/hd_mode/` |
| Reboot instead of poweroff on dual-boot | `is_dualboot_system` detection failed; check `/boot/crt/linux` exists |
| ES/games don't get controller input | Listener is grabbing the device (bug); must use passive read, no `device.grab()` |
| Combo triggers during gameplay | Timer too short or button set too common; 2s hold + 6-button chord should prevent this |
| Listener crashes on controller disconnect | Missing error handling for `ENODEV` on USB hot-unplug |
| No audio/haptic feedback | ALSA not available at that boot stage, or controller doesn't support FF_RUMBLE |
