# Design — BATO-ALL ROMs Erasure

## Architecture

### mergerFS Pool Layout

```
/userdata/roms (merged view)
├── .roms_base (NVMe)     — first branch, writable
├── BATO-ALL/roms (mmcblk0p1)
└── BATO-LG/roms (sdb1)
```

**Branch order:** `.roms_base:BATO-ALL:BATO-LG`
**Config:** `mergerfs.roms = /userdata/roms@/media/BATO-ALL/roms:/media/BATO-LG/roms` (storage manager adds .roms_base implicitly)

### mergerFS Options

```
-o cache.files=off,dropcacheonclose=false,category.create=mfs,allow_other,use_ino,moveonenospc=true,minfreespace=4G
```

- **category.create=mfs** — new files go to branch with most free space (often NVMe)
- **moveonenospc=true** — on write failure, try next branch
- **No =NC** on .roms_base — NVMe branch is writable

### batocera-storage-manager Merge Flow

When adding BATO-LG:

1. Unmount mergerFS from `/userdata/roms`
2. If mount point has content: `mv /userdata/roms/* /userdata/.roms_base/`
3. Remount with `.roms_base:BATO-ALL:BATO-LG`

**Critical:** The move operates on the mount point directory (NVMe). BATO-ALL is a separate block device. The move does not touch BATO-ALL.

### REFRESH Flow (Hotplug)

Same move logic: only moves from mount point to .roms_base when mergerFS is unmounted, before remount.

### Possible Erasure Paths (Hypotheses)

1. **mergerFS delete** — When user/ES deletes a file through merged view, mergerFS deletes from the branch that holds it. If BATO-ALL held the file, delete would hit BATO-ALL.
2. **ES/scraper** — Recursive folder operations or metadata writes that could corrupt/delete.
3. **Storage manager bug** — Undocumented path that incorrectly moves/deletes from external branches.
4. **Race or mount-order confusion** — Drive letters or mount point order changing, causing wrong branch to be targeted.
