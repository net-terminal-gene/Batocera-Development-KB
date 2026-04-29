# Design — batocera-storage-manager mergerFS =NC Fix

## Architecture

### mergerFS Branch Modes

mergerFS supports per-branch access modes appended to the path:

| Mode | Meaning |
|------|---------|
| (none) | Read + Write + Create — fully writable |
| `=RO` | Read Only |
| `=RW` | Read + Write (no create) — same as NC effectively |
| `=NC` | No Create — existing files readable/writable, new files cannot be created here |

### How the Pool is Built

When an external drive with a `/roms` folder is detected, `batocera-storage-manager detect` eventually calls `batocera-storage-manager merge`:

```
detect → mount_partition → (drive has /roms) → merge
```

The `merge` command:
1. Reads `mergerfs.roms` from `/boot/batocera-boot.conf` to get existing branches
2. Adds the new drive's `/roms` path to the branch list
3. Moves any existing content from `/userdata/roms` to `/userdata/.roms_base`
4. Builds: `BRANCHES_CMD="$BASE_DIR:$FULL_BRANCHES"`  ← **bug is here**
5. Mounts: `/usr/bin/mergerfs $MERGERFS_OPTS "$BRANCHES_CMD" "$POOL_PATH"`

### mergerFS Options in Use

```
cache.files=off
dropcacheonclose=false
category.create=mfs        ← Most Free Space — picks branch with most available space for new files
allow_other
use_ino
moveonenospc=true          ← On ENOSPC, moves file to another branch and retries
minfreespace=4G            ← Branch must have >4G free to be eligible for creates
xattr=passthrough
```

With `mfs` and no `=NC` on NVMe: if NVMe has more free space than an external drive at time of write, the file goes to NVMe.

### Intended vs Actual Behavior

```
Intended:
  User writes → /userdata/roms/system/file.ext
  mergerFS → evaluates external branches only (NVMe is NC)
  Result: file lands on external drive

Actual (bug):
  User writes → /userdata/roms/system/file.ext
  mergerFS → evaluates ALL branches including NVMe (mfs policy)
  Result: file lands wherever has most free space — sometimes NVMe
```

### Fix Flow

Change all three BRANCHES_CMD constructions in `batocera-storage-manager`:

```bash
# merge command (~line 807)
BRANCHES_CMD="$BASE_DIR=NC:$FULL_BRANCHES"

# unmount_live_pool rebuild (~line 895)
BRANCHES_CMD="$BASE_DIR=NC:$CLEAN_CONFIG"
```

Also verify the `VALID_BRANCHES` variable at ~line 637 if it feeds into a mergerFS mount.

### Why =NC is Safe for Retro ROMs

- NVMe content that already exists (steam, ports, pcengine, prboom, etc.) remains fully accessible — mergerFS reads from all branches regardless of create mode
- Only new file creation is blocked on the NVMe branch
- This matches the intent: NVMe is the internal fallback storage, not a destination for retro game uploads

### Complication: Steam Launcher Creation

**Discovered 2026-02-24.** A blanket `=NC` on the NVMe breaks Steam game installs.

**Evidence:**
- `stat /userdata/roms/steam/1091500_Cyberpunk_2077.sh` → `Device: 259,2` = `nvme0n1p2`
- All existing Steam `.sh` launchers physically live on the NVMe
- `/proc/partitions` confirms `259,2` = `nvme0n1p2`

**The conflict:**

```
User installs new Steam game
  ↓
Steam add-on creates /userdata/roms/steam/APPID_Name.sh
  ↓
This write goes through mergerFS at /userdata/roms
  ↓
With =NC on NVMe: mergerFS cannot create there
  ↓
mfs policy picks external drive (BATO-ALL, BATO-LG, etc.)
  ↓
Launcher lands on external drive — disappears when drive isn't connected
```

**User intent:** Steam launchers must stay on NVMe. The user has 2TB NVMe and wants Steam games portable without external drives attached.

**mergerFS limitation:** Branch modes (`=NC`) apply per-branch to the entire branch, not per-subdirectory. You cannot say "NVMe is NC except for the `steam/` subdirectory."

### Candidate Solutions for Steam Conflict

**Option A — Move steam launchers outside the mergerFS pool**
- Change Steam add-on to write launchers to `/userdata/steam_launchers/` (directly on NVMe, outside the pool)
- Update ES steam system config to point to that path
- Pro: Clean separation; `=NC` fix is fully safe
- Con: Requires modifying Steam add-on and ES config

**Option B — Write directly to the physical NVMe base path**
- Change Steam add-on to write to `/userdata/.roms_base/steam/` instead of `/userdata/roms/steam/`
- Pro: Bypasses mergerFS entirely for Steam; `=NC` fix is fully safe
- Con: Requires modifying Steam add-on; the physical path is an implementation detail

**Option C — Staged fix (retro ROMs now, Steam later)**
- Apply `=NC` to lines 807 and 895 now (protects retro ROMs from duplication)
- Document the Steam launcher issue as a follow-up
- Steam installs are infrequent and the risk is known/controlled
- Pro: Immediate protection against the primary bug
- Con: Incomplete — Steam launchers still vulnerable to misrouting
