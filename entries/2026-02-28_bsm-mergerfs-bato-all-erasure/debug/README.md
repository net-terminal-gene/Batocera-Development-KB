# Debug — BATO-ALL ROMs Erasure

## Doc Index

| Doc | Content |
|-----|---------|
| `merge-mv-erasure-root-cause.md` | Root cause, proposed fixes, wait loop + mount guard |
| `upstream-fix-grep-bug-2026-03-02.md` | Upstream grep bug: `"fuse.mergerfs on $POOL_PATH"` never matches |
| `bato-lg-mount-2026-02-28T090851.md` | BATO-LG mount; BATO-ALL 50 systems |
| `bato-lg-eject-2026-02-28T103017.md` | BATO-LG eject; pool rebuilt |
| `bato-lg-merge-2026-02-28T103219.md` | BATO-LG merge post-fix; erasure recurred (guard not yet applied) |

## Timeline

| Time | Event |
|------|-------|
| 09:07:29 | Merge add BATO-LG; merge started |
| 09:09–09:11 | Move ran; 6 systems erased |
| 09:13:12 | refresh_pool ran (no erasure) |
| 10:30:17 | BATO-LG eject; pool rebuilt |
| 10:32:19 | Merge with BATO-LG again; erasure recurred (guard not yet applied) |
| 10:32+ | Mount guard applied; user restored all 50 systems |
| 2026-03-01 | Patched `batocera-storage-manager` deployed via FileZilla; `batocera-save-overlay` |
| 2026-03-01 | Merge BATO-PARROT — no erasure; fix validated |
| — | **batocera.linux:** Fix merged upstream by someone else (no PR from this session) |

## Root Cause

**Identified:** `merge-mv-erasure-root-cause.md` — The merge step runs `mv "$POOL_PATH"/* "$BASE_DIR"/` after `umount -l`. Lazy unmount leaves the mergerFS view visible briefly; the move operates on the merged view and deletes from BATO-ALL for paths that exist only there.

## Verification

```bash
# SSH to Batocera
~/bin/ssh-batocera.sh "command"

# Check mergerFS mount
mount | grep mergerfs

# Compare BATO-ALL vs user's expected list
ls -1 /media/BATO-ALL/roms/ | sort
ls -1 /userdata/.roms_base/ | sort
ls -1 /userdata/roms/ | sort

# Check specific missing system
ls -la /media/BATO-ALL/roms/bigfish 2>/dev/null || echo "MISSING"
ls -la /userdata/.roms_base/bigfish 2>/dev/null || echo "MISSING"

# Storage log
tail -100 /var/log/batocera-storage.log

# Timestamps (when was folder created?)
stat /userdata/.roms_base/megadrive
stat /userdata/.roms_base/megadrivez
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| 7 systems missing from BATO-ALL after adding BATO-LG | Erasure during merge/refresh or ES writes |
| megadrive reappears in .roms_base after rename to megadrivez | ES/scraper create via mergerFS (category.create=mfs) |
| User re-uploaded roms twice | Recurring erasure; not one-off |

## Reproduce Steps (To Capture Next Occurrence)

1. Note full BATO-ALL contents before any change
2. Add BATO-LG or trigger REFRESH (hotplug)
3. Immediately compare BATO-ALL contents
4. Check `/var/log/batocera-storage.log` for merge/refresh events
5. Consider `inotifywait` on `/media/BATO-ALL/roms` to capture writes/deletes
