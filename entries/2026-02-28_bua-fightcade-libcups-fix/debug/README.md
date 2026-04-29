# Debug — BUA Fightcade libcups Fix

## Verification

```bash
# Check libcups presence
find /userdata/system/add-ons -name '*cups*'

# Check port launcher has LD_LIBRARY_PATH
grep LD_LIBRARY_PATH /userdata/roms/ports/Fightcade.sh

# Check fightcade log for error
tail -30 /userdata/system/logs/fightcade.log
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| `libcups.so.2: cannot open shared object file` | LD_LIBRARY_PATH not set; .dep not in library path |
| fc2-electron exits immediately | Same; dynamic linker fails before UI starts |
