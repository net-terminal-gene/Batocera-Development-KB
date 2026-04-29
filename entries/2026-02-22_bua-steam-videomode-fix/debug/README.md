# Debug — BUA Steam VIDEO MODE Fix

## Useful Commands for Verification

```bash
# On Batocera (or via SSH)
grep steam /userdata/system/batocera.conf
batocera-resolution currentResolution
cat /userdata/system/logs/es_launch_stderr.log
cat /userdata/system/logs/es_launch_stdout.log
```

## Typical Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| `batocera-resolution currentResolution` shows boot mode during game | configgen not loading steam["rom"].videomode |
| `error: app/com.valvesoftware.Steam/x86_64/master not installed` | steam generator used; steam.emulator=sh missing |
| VIDEO MODE appears twice in ES | duplicate videomode in es_features_steam.cfg |

## Batocera.conf Keys to Check

```
steam.emulator=sh
steam.core=sh
steam["2772080_Crystal_Breaker.sh"].videomode=854x480.60.00045
```
