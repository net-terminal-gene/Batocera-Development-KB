# Debug — CRT Tools on Boot Drive (mergerFS Conflict)

## Verification

```bash
# 1. Confirm CRT content is on boot drive (not external)
ls -la /userdata/.roms_base/crt/
ls /media/BATO-PARROT/roms/crt/ 2>/dev/null | wc -l

# 2. Confirm bind mount is active (if using Option A)
mount | grep "crt"

# 3. Mode switch test: boot with only boot drive connected
#    - Eject all external drives
#    - Reboot, trigger HD→CRT or CRT→HD switch
#    - CRT tools should still appear in EmulationStation

# 4. Verify no new crt files on external after mode switch
ls /media/BATO-PARROT/roms/crt/ | wc -l
# Should remain 0 (or previous count) — no new writes
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| CRT system empty in EmulationStation after mode switch | CRT tools on external drive that wasn't mounted |
| `GunCon2_Calibration.sh` not found | Path points to external; drive disconnected |
| Bind mount fails | Script runs before mergerFS mounts /userdata/roms |
| Mode switcher writes to BATO-PARROT crt | Bind mount not in place; =NC routing to external |
