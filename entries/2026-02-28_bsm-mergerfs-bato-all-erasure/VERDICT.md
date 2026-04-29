# VERDICT — BATO-ALL ROMs Erasure

## Status: FIXED (2026-03-01)

## Summary

ROM folders were being erased from BATO-ALL when adding BATO-LG to the mergerFS pool. Root cause: the merge step in `batocera-storage-manager` runs `mv "$POOL_PATH"/* "$BASE_DIR"/` after `umount -l`. Lazy unmount leaves the mergerFS view visible; the move operates on the merged view and deletes from BATO-ALL for paths that exist only there. Eight systems were affected: bigfish, c64, gamehouse, model1, neogeo64, popcap, segacd, zinc. Fix: (1) correct grep pattern `" $POOL_PATH "` so the unmount block runs (upstream had broken `"fuse.mergerfs on $POOL_PATH"`); (2) unmount retry loop before move. **No changes were made to batocera.linux in this session** — someone else merged the fix upstream. We deployed a patched `batocera-storage-manager` to live Batocera via FileZilla/SCP and `batocera-save-overlay`. Merge with BATO-PARROT validated no erasure.

## Plan vs reality

- **Plan:** Identify root cause, add wait loop, validate, open PR to batocera.linux.
- **Reality:** Wait loop insufficient; erasure recurred. Upstream fix had grep bug (`"fuse.mergerfs on $POOL_PATH"` never matches). We identified the correct pattern and deployed a patched build locally. **Someone else merged the fix into batocera.linux** — we did not submit a PR. User restored all 50 systems; BATO-ALL intact; merge with BATO-PARROT confirmed fix.

## Root Causes

1. **Merge `mv` operates on mergerFS view** — After `umount -l`, the mergerFS mount can remain visible to the same process. The move then reads/deletes from the merged view; for paths only on BATO-ALL, the delete targets BATO-ALL.
2. **Lazy unmount delay** — `umount -l` detaches the mount but cleanup is deferred until references are released. The storage manager can still see the mergerFS during this window.
3. **Long-running move** — The move processes hundreds of folders; erasure is staggered (user restored 6, then segacd/zinc were erased later in the same merge).

## Changes Applied

| Location | Change |
|----------|--------|
| **batocera.linux** (by others) | Correct grep pattern `" $POOL_PATH "`; unmount retry loop. Merged upstream by someone else — no PR or edits from this session. |
| **Live Batocera** | Patched `batocera-storage-manager` deployed via FileZilla to `/usr/bin/`, `batocera-save-overlay` for persistence. |

## Unanticipated

- Wait loop alone did not prevent erasure; lazy unmount behavior required a stronger guard.
- Move can run 10+ minutes; erasure happens incrementally.

## Debug Docs

| Doc | Content |
|-----|---------|
| `debug/merge-mv-erasure-root-cause.md` | Root cause analysis, proposed fixes |
| `debug/bato-lg-mount-2026-02-28T090851.md` | BATO-LG mount event; BATO-ALL 50 systems |
| `debug/bato-lg-eject-2026-02-28T103017.md` | BATO-LG eject; pool rebuilt |
| `debug/bato-lg-merge-2026-02-28T103219.md` | BATO-LG merge post-fix; erasure recurred (guard not yet applied) |

## Outstanding

- [x] Fix merged upstream (by others; we did not open a PR)
- [x] Test merge with BATO-LG / BATO-PARROT; confirm no erasure

## 2026-03-02: Upstream Fix Had grep Bug

Build 43-dev-8ecd0729a2: Erasure recurred. Root cause: grep pattern `"fuse.mergerfs on $POOL_PATH"` never matches mount output. Correct pattern: `" $POOL_PATH "`. See `debug/upstream-fix-grep-bug-2026-03-02.md`. This fix was later merged by someone else into batocera.linux.
