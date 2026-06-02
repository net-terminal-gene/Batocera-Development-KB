# Debug — mergerFS Write Routing and S12populateshare Awareness

## Verification

```bash
# Check current mergerFS mount options
grep mergerfs /proc/mounts

# Check which branches have a system directory
ls /userdata/.roms_base/snes/
ls /media/BATO-ALL/roms/snes/

# Check if stock gamelist is shadowing external
diff <(head -5 /userdata/.roms_base/snes/gamelist.xml) <(head -5 /media/BATO-ALL/roms/snes/gamelist.xml)

# Check mergerFS create policy at runtime
xattr -l /userdata/roms/.mergerfs 2>/dev/null

# Check boot config for mergerFS branches
grep mergerfs /boot/batocera-boot.conf
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Artwork missing after merge | Stock gamelist in .roms_base shadows external gamelist (ff policy) |
| Stock ROMs reappear after reboot | S12populateshare repopulated empty system dir |
| New ROM lands on wrong drive | eplfs routed to branch with least free space |
| mv errors in storage log | .roms_base/{system} non-empty, silent mv failure |
