# Debug — CRT Mode Switcher: NAS Gamelist Visibility Fix

## Verification

```bash
# After switching to HD mode — expect 1+ <hidden> tags, 0 for mode_switcher block
grep -c '<hidden>' /userdata/roms/crt/gamelist.xml

# After switching to CRT mode — expect 0 <hidden> tags
grep -c '<hidden>' /userdata/roms/crt/gamelist.xml

# Confirm all tool files still present on disk in HD mode
ls /userdata/roms/crt/*.sh

# Confirm gamelist visibility update logged
grep 'gamelist.xml' /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -5
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| mode_switcher missing from ES after reboot | Old `rm -rf` logic still present; NAS write-back race |
| All CRT tools visible in HD mode | `set_crt_gamelist_visibility` not called, or called with wrong mode |
| gamelist.xml has duplicate `<hidden>` tags | awk pass running multiple times without stripping existing tags |
| ES CRT system not appearing at all | gamelist.xml has 0 visible entries (mode_switcher hidden by mistake) |
| mode_switcher won't open from ES | `emulatorlauncher.py` crash — check `/userdata/system/logs/es_launch_stderr.log` for `ValueError` |

## Session Log (2026-04-11)

1. Confirmed mode_switcher.sh absent from `/userdata/roms/crt/` after HD mode switch + reboot
2. Identified `rm -rf $CRT_ROMS/crt/*` in `install_crt_tools()` as root cause
3. Replaced with unified `cp -a` + `set_crt_gamelist_visibility()` on `crt-hd-mode-switcher` branch
4. Deployed to live Batocera via SSH, confirmed gamelist updated correctly (0 hidden in CRT, N hidden in HD)
5. Full CRT → HD → CRT cycle tested and passed
6. Same fix applied to `crt-hd-mode-switcher-v43` branch — not yet tested on hardware
