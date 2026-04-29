# Debug — Steam Mode Switcher Preservation

## Verification Commands

```bash
# Before and after mode switch
grep steam /userdata/system/batocera.conf

# Steam launch failure
cat /userdata/system/logs/es_launch_stderr.log
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| `grep steam` returns nothing after CRT→HD or HD→CRT | batocera.conf restore overwrote steam.* |
| `error: app/com.valvesoftware.Steam/x86_64/master not installed` | steam.emulator=sh missing |
