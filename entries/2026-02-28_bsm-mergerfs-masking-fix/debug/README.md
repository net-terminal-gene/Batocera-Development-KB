# Debug — mergerFS Merge Move Safe Masking Fix

## Verification

```bash
# SSH to Batocera
~/bin/ssh-batocera.sh "command"

# Check overlapping paths (masking scenario)
ls -la /userdata/.roms_base/megadrive 2>/dev/null | head -3
ls -la /media/BATO-LG/roms/megadrive 2>/dev/null | head -3
ls -la /userdata/roms/megadrive 2>/dev/null | head -3  # merged view

# Storage log
tail -50 /var/log/batocera-storage.log
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Erasure of external drive content | Move touched merged view or external paths |
| Masking unexpected | mergerFS policy; different branch shown |
