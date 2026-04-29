    # Merge `mv` Erasure — Root Cause Analysis

**Date:** 2026-02-28  
**Status:** Root cause identified

## Summary

Eight ROM folders were erased from BATO-ALL during merge(s) when adding BATO-LG: bigfish, c64, gamehouse, model1, neogeo64, popcap, segacd, zinc. The cause is a bug in `batocera-storage-manager` merge logic: `mv "$POOL_PATH"/* "$BASE_DIR"/` runs while the mergerFS mount may still be visible (lazy unmount), so the move operates on the merged view and deletes from BATO-ALL.

---

## Timeline (2026-02-28)

| Time     | Event |
|----------|-------|
| 09:07:29 | User triggered merge (add BATO-LG) |
| 09:07:29 | MERGE: Added /media/BATO-LG/roms to boot config |
| 09:07:29 | MERGE: Moving internal ROMs to base directory |
| 09:11:56 | (merge completed; sdc detect) |
| 09:13:12 | refresh_pool ran (no erasure; refresh doesn't touch branches) |

**BATO-ALL at 09:08:** 50 systems (verified in `bato-lg-mount-2026-02-28T090851.md`)  
**BATO-ALL after merge:** 44 systems — 6 missing

---

## Root Cause: merge Logic (lines 787–803)

```bash
# batocera-storage-manager, merge command
if mount | grep -q "fuse.mergerfs on $POOL_PATH"; then
    log_msg "POOL: Reloading MergerFS to include new drive..."
    umount -l "$POOL_PATH"                    # Lazy unmount
fi

# ...
if [ -n "$(ls -A "$POOL_PATH" 2>/dev/null)" ]; then
    log_msg "MERGE: Moving internal ROMs to base directory ($BASE_DIR) to prevent masking..."
    mv "$POOL_PATH"/* "$BASE_DIR"/ 2>/dev/null   # BUG: may still see mergerFS
    mv "$POOL_PATH"/.[!.]* "$BASE_DIR"/ 2>/dev/null
fi
```

### The Bug

1. **`umount -l` (lazy unmount)** — Detaches the mount immediately; the filesystem may remain visible until no process references it.
2. **No wait** — The script proceeds immediately to `ls` and `mv`.
3. **`$POOL_PATH` still shows mergerFS** — For a brief period, `ls -A /userdata/roms` can still list the merged view (`.roms_base` + BATO-ALL).
4. **`mv` operates on merged view** — For paths that exist only on BATO-ALL (e.g. `bigfish`, `c64`), mergerFS serves BATO-ALL content. The move:
   - Reads from mergerFS (resolves to BATO-ALL)
   - Writes to `.roms_base`
   - Deletes from mergerFS (applied to BATO-ALL)
5. **Copy can fail, delete still happens** — If `.roms_base` is full or `mv` fails on large dirs, the delete may still be applied. Or the copy succeeds but we never verified; the 6 folders are gone from both locations.

### Why 6 Specific Folders?

Those folders existed only on BATO-ALL (not in `.roms_base`). mergerFS policy: for read, it serves the first branch that has the path. For paths only on BATO-ALL, the read comes from BATO-ALL. The delete then targets BATO-ALL.

---

## Proposed Fix

**Option A: Wait for mount to fully release before move**

```bash
if mount | grep -q "fuse.mergerfs on $POOL_PATH"; then
    log_msg "POOL: Reloading MergerFS to include new drive..."
    umount -l "$POOL_PATH"
    # Wait for mount to fully release before touching POOL_PATH
    while mount | grep -q " $POOL_PATH "; do
        sleep 0.5
    done
fi
```

**Option B: Only move content known to be on BASE_DIR**

Before unmount, record which paths exist under `$BASE_DIR` (or under the first branch). After unmount, only move those. More complex; Option A is simpler.

**Option C: Move before unmount, but only from BASE_DIR**

If the intent is to move "internal" (NVMe) content only, iterate over `$BASE_DIR` and move `$BASE_DIR/*` to a temp, then after remount merge temp into pool. That avoids touching the merged view. Requires rethinking the flow.

**Recommendation:** Option A — add the wait loop. Low risk, minimal change.

**Update (post-fix failure):** The wait loop did not prevent erasure; bigfish, c64, gamehouse, model1 were erased again during merge at 10:32. Lazy unmount may leave the filesystem visible to the same process until references are released. **Safer fix:** Add a guard before the move: if `POOL_PATH` is still a mount point, skip the move entirely. Applied in batocera-storage-manager.

---

## Verification After Fix

1. Restore the 6 systems to BATO-ALL (user doing this).
2. Add BATO-LG again (or simulate: run merge with a test drive).
3. Verify BATO-ALL still has 50 systems.
4. Check `/var/log/batocera-storage.log` for merge events.

---

## Files

| File | Location |
|------|----------|
| batocera-storage-manager | `batocera.linux/package/batocera/core/batocera-scripts/scripts/batocera-storage-manager` |
| Merge block | Lines 751–822 |
