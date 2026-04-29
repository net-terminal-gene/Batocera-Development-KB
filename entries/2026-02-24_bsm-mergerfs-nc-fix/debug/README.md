# Debug — batocera-storage-manager mergerFS =NC Fix

## Verification

```bash
# 1. Confirm mergerFS is mounted and check branch modes
mount | grep roms
# Look for =NC on the .roms_base path — should show after fix

# 2. Check NVMe base dir BEFORE writing a test file
ssh root@batocera.local 'ls /userdata/.roms_base/batoparrot/ | wc -l'

# 3. Write a test file through the mergerFS pool
ssh root@batocera.local 'touch /userdata/roms/batoparrot/TEST_FILE.wsquashfs'

# 4. Confirm test file landed on external drive, NOT on NVMe
ssh root@batocera.local 'ls /userdata/.roms_base/batoparrot/TEST_FILE.wsquashfs 2>&1'
# Should say: No such file or directory

ssh root@batocera.local 'ls /media/BATO-PARROT/roms/batoparrot/TEST_FILE.wsquashfs 2>&1'
# Should say: file exists

# 5. Clean up test file
ssh root@batocera.local 'rm /userdata/roms/batoparrot/TEST_FILE.wsquashfs'

# 6. Verify existing NVMe content still readable through pool
ssh root@batocera.local 'ls /userdata/roms/steam/ | wc -l'
ssh root@batocera.local 'ls /userdata/roms/ports/ | wc -l'
# Should still show full counts (NVMe content readable even with =NC)
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Test file appears in `/userdata/.roms_base/` after write | `=NC` not applied to BASE_DIR — fix not working |
| Existing NVMe games (steam, ports) disappear after fix | `=NC` incorrectly applied to wrong branch |
| mergerFS mount fails after fix | Syntax error in `=NC` flag — check branch string format |
| Pool not rebuilt after drive eject/reinsert | `unmount_live_pool` rebuild (~line 895) still missing `=NC` |
| Files split between NVMe and external during large upload | `moveonenospc=true` redirecting to NVMe on ENOSPC — may need additional `=NC` guard |

## Fix Applied — 2026-02-24

Fix deployed directly to `/usr/bin/batocera-storage-manager` on the live Batocera system.

**Method:** Due to expect/Tcl quoting limitations in `ssh-batocera.sh` (double quotes in commands cause `extra characters after close-quote` error), the fix was applied via a base64-encoded Python script:
1. Python fix script written locally at `/tmp/batocera_nc_fix.py`
2. Base64-encoded and piped to Batocera via SSH: `echo BASE64 | base64 -d > /tmp/batocera_nc_fix.py && python3 /tmp/batocera_nc_fix.py`
3. All 3 substitutions confirmed applied by script output

**Backup:** `/userdata/system/batocera-storage-manager.backup`

**Rollback:** `cp /userdata/system/batocera-storage-manager.backup /usr/bin/batocera-storage-manager`

**Confirmed applied lines (via `grep -n`):**
```
637:    VALID_BRANCHES="$BASE_DIR=NC"
807:    BRANCHES_CMD="$BASE_DIR=NC:$FULL_BRANCHES"
895:        BRANCHES_CMD="$BASE_DIR=NC:$CLEAN_CONFIG"
```

**Status:** Awaiting test with external drives connected.

## Pre-Fix Observed State

With all external drives ejected, NVMe showed these systems with real content (>4 files):

```
98  segacd      ← should have been on BATO-ALL
79  steam       ← intentional NVMe
75  batoparrot  ← should have been on BATO-PARROT
23  gamehouse   ← should have been on BATO-ALL
6   ports       ← intentional NVMe
6   pcengine    ← intentional NVMe
5   prboom      ← intentional NVMe
```

User cleaned up `segacd` manually (moved to BATO-ALL, deleted NVMe copies).
`batoparrot` and `gamehouse` NVMe copies confirmed as **100% duplicates** of external drive content
(initial `comm` comparison showed false 0% overlap due to filename encoding differences between SSH/Linux and macOS; FileZilla transfer test confirmed all NVMe files already existed on external drives).
