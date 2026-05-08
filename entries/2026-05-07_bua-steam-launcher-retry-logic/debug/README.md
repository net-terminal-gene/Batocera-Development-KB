# Debug — BUA Steam: Launcher Retry Logic

## Verification

```bash
# Check if Steam is running
ps aux | grep -E 'steam|dwarfs|bwrap' | grep -v grep

# Check for stale FUSE mounts
mount | grep steam
ls /tmp/.mount_steam*

# Check for zombie processes
ps aux | grep defunct

# Check if lbfix.sh still exists (should self-delete after first run)
ls -la /userdata/system/add-ons/steam/lbfix.sh

# Check libcurl state (should be a real file after lbfix, not symlink)
ls -la /userdata/system/add-ons/steam/.local/share/Steam/ubuntu12_32/steam-runtime/pinned_libs_64/libcurl.so.4
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Steam exits to ES within 30-60s of first launch | lbfix.sh replaced libcurl while Steam was running |
| Second launch stuck (black screen, no Steam window) | RunImage binary won't start (dirty state from crash) |
| wmctrl returns nothing | No X11 windows exist (Steam binary never mounted) |
| Zombie `[steam] <defunct>` processes | First launch crash left orphaned children |
| Launcher at 100% CPU in sleep loop | Stuck in wmctrl polling, Steam window will never appear |
