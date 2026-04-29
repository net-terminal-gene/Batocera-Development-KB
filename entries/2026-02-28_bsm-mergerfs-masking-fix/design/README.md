# Design — mergerFS Merge Move Safe Masking Fix

## Architecture

TBD. The safe move must:

1. Never operate on paths that exist only on external drives
2. Only consolidate or move content known to be in `.roms_base`
3. Preserve the mount guard as the safety net

## Flow (Current)

```
merge command
  → umount -l POOL_PATH
  → wait loop (optional)
  → if pool still mounted: skip move, log WARNING (guard)
  → else: mv POOL_PATH/* BASE_DIR/  (unsafe when guard bypassed)
  → remount with new drive
```

## Flow (Proposed)

TBD. Options:

- **Option A:** Before unmount, copy `.roms_base` paths to temp; after remount, merge back. Avoids touching merged view.
- **Option B:** Only move paths explicitly listed from `.roms_base`; use `rsync` or `cp` with explicit source (not POOL_PATH).
- **Option C:** Accept masking; document as known limitation. No code change.
