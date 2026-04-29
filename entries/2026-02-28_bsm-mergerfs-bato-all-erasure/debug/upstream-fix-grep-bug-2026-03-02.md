# Upstream Fix Broken: grep Pattern Never Matches

**Date:** 2026-03-02  
**Build:** 43-dev-8ecd0729a2  
**Status:** Root cause of upstream fix failure

## Summary

The upstream fix (sync unmount + retry loop) **never runs** because the grep condition is wrong. The mount output format does not contain the substring `fuse.mergerfs on /userdata/roms`, so the unmount block is always skipped. The move runs with the pool still mounted → erasure persists.

## Evidence

**Storage log (BATO-LG merge):** No "POOL: Reloading MergerFS" — unmount block skipped.

**Actual mount output:**
```
userdata/.roms_base:media/BATO-TEST/roms:media/BATO-LG/roms on /userdata/roms type fuse.mergerfs (rw,...)
```

**BSM condition (line 804):**
```bash
if mount | grep -q "fuse.mergerfs on $POOL_PATH"; then
```

**Test on Batocera:**
```bash
mount | grep -q 'fuse.mergerfs on /userdata/roms' && echo MATCH || echo NO MATCH
# NO MATCH
```

The mount format is `SOURCE on MOUNT_POINT type fuse.mergerfs` — "fuse.mergerfs" comes after "type ", not before " on ". The pattern expects "fuse.mergerfs on /userdata/roms" which does not exist.

## Correct Pattern

```bash
# Match mount point (works):
mount | grep -q " $POOL_PATH "

# Or more specific:
mount | grep -q " on $POOL_PATH "
```

## Fix

Replace `"fuse.mergerfs on $POOL_PATH"` with `" $POOL_PATH "` (or `" on $POOL_PATH "`) in:
- Line 804: `if mount | grep -q ...`
- Line 808: `while mount | grep -q ...`
- And any other merge/refresh blocks using the same pattern

## Reproduce

1. Add msu-md to BATO-TEST
2. Merge BATO-TEST (first drive)
3. Mount BATO-LG and accept merge
4. msu-md is erased from BATO-TEST (confirmed 2026-03-02)
