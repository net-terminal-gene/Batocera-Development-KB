# Debug — v43 Docked Detection Display Override

## Verification Commands

```bash
# Check docked flag
cat /var/run/batocera-docked 2>/dev/null || echo 'docked flag not present'

# Check DRM connector statuses
for f in /sys/class/drm/*/status; do echo "$f: $(cat $f)"; done

# Check configured outputs
grep -i videooutput /userdata/system/batocera.conf

# Check xrandr output names (what batocera-resolution sees)
DISPLAY=:0 xrandr --query

# Check what batocera-resolution listOutputs returns
DISPLAY=:0 batocera-resolution listOutputs

# Check display log
tail -40 /userdata/system/logs/display.log

# Check dmesg for EDID errors
dmesg | grep -iE 'EDID|drm.*connect|hotplug' | tail -20

# Check which batocera-switch-screen-checker is running (MD5)
md5sum /usr/bin/batocera-switch-screen-checker
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Primary display goes blank when second display connected | Docked flag written, ES overriding videooutput |
| `/var/run/batocera-docked` exists with output name | `_detect_docked_output()` flagged second display |
| `display.log`: "Docked mode active. External output: DP-1" | Docked flag being acted on by emulationstation-standalone |
| `display.log`: "Invalid output - HDMI-A-2" | DRM name written to conf instead of xrandr name |
| EDID errors in dmesg on DP outputs | CRT has no EDID chip; intermittent on some AMD GPUs |
| All DRM connectors show disconnected despite cable plugged in | EDID read failure; GPU not registering display |

## Test Sequence Used

1. Fresh v43 PC — set `global.videooutput=HDMI-2`, `global.videooutput2=none` via ES UI
2. Rebooted — confirmed HDMI-2 active, no docked flag
3. Plugged DP-1 → docked flag appeared immediately containing `DP-1`
4. Confirmed HDMI-2 went blank on ES restart

Then on dmanlfc's patched image:
1. Same setup — `global.videooutput=HDMI-2`, `global.videooutput2=none`
2. Plugged DP-1 → docked flag NOT written
3. `display.log`: "Explicit video outputs configured (HDMI-2 none). Skipping docked detection."
4. HDMI-2 remained active — fix confirmed working

## MD5 Checksums

| Version | MD5 | Notes |
|---------|-----|-------|
| Broken (GitHub master as of March 28) | `a4f74af1e664f5ca6c0c4fbe2e1eb5d7` | Matched on Steam Deck |
| Fixed (dmanlfc Google Drive image) | Different | Logic-inverted guard; not yet on GitHub |
