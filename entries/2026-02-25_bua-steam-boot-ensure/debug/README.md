# Debug — BUA Steam Boot-Time Ensure

## Verification

```bash
# When steam.* is missing (e.g. after config overwrite), before reboot
grep -E '^steam\.' /userdata/system/batocera.conf

# After reboot
grep -E '^steam\.' /userdata/system/batocera.conf
# Expect: steam.emulator=sh, steam.core=sh (re-added by ensure script if missing)
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Steam games fail with "app not installed" | steam.emulator/core missing; ensure script not registered or not running |
| Duplicate steam.emulator lines | ensure script should exit when present; check grep gate |
