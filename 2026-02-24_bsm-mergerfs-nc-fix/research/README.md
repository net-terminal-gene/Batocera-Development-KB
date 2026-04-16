# Research — batocera-storage-manager mergerFS =NC Fix

## Findings

### Discovery Context

Issue discovered during a data loss investigation. User's PopCap games (`.wtgz` files) disappeared from their library. Investigation revealed:
- No `popcap` ROM directory on any connected drive
- `es_systems_popcap.cfg` properly configured pointing to `/userdata/roms/popcap`
- The directory simply did not exist — games deleted (separate issue)

During investigation, inconsistencies in file placement across NVMe and external drives were uncovered.

### System Configuration

- **Batocera version:** `43acu-dev-13c569bd4a 2026/02/16`
- **Internal storage:** `/dev/nvme0n1p2` (1.8T ext4) → `/userdata`
- **sharedevice:** `INTERNAL`
- **mergerfs.roms:** empty in `batocera-boot.conf` (managed dynamically by storage manager)

**External drives (exFAT, auto-detected):**
| Label | Device | Size | Mount |
|-------|--------|------|-------|
| BATO-ALL | /dev/mmcblk0p1 | 955GB SD card | /media/BATO-ALL |
| BATO-PARROT | /dev/sda2 | 3.7TB HDD | /media/BATO-PARROT |
| BATO-LG | /dev/sdc1 | 955GB | /media/BATO-LG |

**mergerFS union mount (observed):**
```
userdata/.roms_base:media/BATO-ALL/roms:media/BATO-PARROT/roms:media/BATO-LG/roms
  on /userdata/roms type fuse.mergerfs
  (rw,nosuid,nodev,relatime,user_id=0,group_id=0,default_permissions,allow_other)
```

Note: No `=NC` visible on `.roms_base` in mount output.

### NVMe Content vs External Drives (at time of discovery)

Files found on NVMe (`/userdata/roms/` with all drives ejected) with more than 4 files:

| System | NVMe count | External drive | External count | Overlap |
|--------|-----------|----------------|----------------|---------|
| segacd | 100 | BATO-ALL | 205 | 0 (all unique) |
| gamehouse | 26 | BATO-ALL | 121 | 0 (all unique) |
| batoparrot | 75 | BATO-PARROT | 299 | 0 (all unique) |
| steam | 79 | NVMe intentional | — | intentional |
| ports | 6 | NVMe intentional | — | intentional |
| pcengine | 6 | NVMe intentional | — | intentional |
| prboom | 5 | NVMe intentional | — | intentional |

**Key finding (revised):** Initial `comm` comparison showed 0% overlap, but this was a false negative caused by filename encoding differences between SSH output and macOS `ls` output (special characters, Unicode normalization). Verified via FileZilla transfer test: copying the 75 "NVMe-only" batoparrot files to BATO-PARROT left the count unchanged at 299 — confirming all were already present. Same result for gamehouse (121 count unchanged). **All NVMe copies are exact duplicates of files already on the correct external drives.** mergerFS was writing files to both NVMe and the external drive simultaneously due to the missing `=NC`, wasting ~63GB of NVMe space.

### Code Analysis

**File:** `package/batocera/core/batocera-scripts/scripts/batocera-storage-manager`

**MERGERFS_OPTS:**
```bash
MERGERFS_OPTS="-o cache.files=off,dropcacheonclose=false,category.create=mfs,allow_other,use_ino,moveonenospc=true,minfreespace=4G"
```

**Broken merge command (line ~807):**
```bash
FULL_BRANCHES=$(batocera-settings-get -f "$BOOT_CONF_FILE" "$CONFIG_KEY" | cut -d'@' -f2)
BRANCHES_CMD="$BASE_DIR:$FULL_BRANCHES"   # ← NVMe has no =NC
/usr/bin/mergerfs $MERGERFS_OPTS "$BRANCHES_CMD" "$POOL_PATH"
```

**Broken pool rebuild (line ~895):**
```bash
BRANCHES_CMD="$BASE_DIR:$CLEAN_CONFIG"    # ← NVMe has no =NC
/usr/bin/mergerfs $MERGERFS_OPTS "$BRANCHES_CMD" "$POOL_PATH"
```

**Correct pattern in S12mergerfs:**
```bash
/usr/bin/mergerfs $MERGERFS_OPTS "$BASE=NC:${BRANCHES}" "$POOL"
```

### Git History

Most recent storage manager commit: `4914cd3b64` — Jan 31, 2026
Author: Daniel Martin (dmanlfc)
Subject: "more verbose merge game drive info"

The `=NC` omission appears to have been present since the storage manager was written — it was never updated to match `S12mergerfs`'s correct pattern.

### Impact

Any user who:
1. Has Batocera installed to internal NVMe/SSD
2. Uses external drives auto-detected by the storage manager
3. Adds game files through Batocera's mergerFS path (Samba, ES scraping, direct file copy)

...will have game files silently spread across internal and external storage, making drive management unreliable and causing unexpected behavior when external drives are disconnected.

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

