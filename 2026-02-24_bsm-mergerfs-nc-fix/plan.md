# batocera-storage-manager mergerFS =NC Fix

## Agent/Model Scope

Investigation via ssh-batocera + batocera.linux repo analysis. PR target: `batocera.linux` master.

## Problem

When external drives are merged into the mergerFS ROM pool via `batocera-storage-manager`, the internal NVMe base directory (`/userdata/.roms_base`) is mounted as a fully writable branch. With the `mfs` (Most Free Space) create policy, mergerFS silently routes new file writes to the NVMe when it has more free space than the external drives — even though the user's intent is for all new game files to land on external drives.

Additionally, `moveonenospc=true` can cause files to migrate to the NVMe if an external drive write fails, further compounding the issue.

Confirmed real-world impact: a full game library upload to BATO-PARROT resulted in 75 `.wsquashfs` files (batoparrot system) and 26 `.wtgz` files (gamehouse system) silently written to the NVMe **in addition to** the external drive — creating full duplicate copies on the NVMe. Initial cross-drive comparison (via SSH vs macOS `ls`) appeared to show 0% overlap due to filename encoding differences, but FileZilla transfer tests confirmed all NVMe copies were exact duplicates already present on the correct external drives. Net effect: ~63GB of wasted NVMe space across batoparrot (63GB) and gamehouse (594MB). No game data was lost — only duplicated.

## Root Cause

`batocera-storage-manager` builds the mergerFS branch string without `=NC` (No Create) on `BASE_DIR`:

```bash
# CURRENT (broken) — merge command, line 807
BRANCHES_CMD="$BASE_DIR:$FULL_BRANCHES"

# CURRENT (broken) — unmount_live_pool rebuild, line 895
BRANCHES_CMD="$BASE_DIR:$CLEAN_CONFIG"
```

The `S12mergerfs` init script (used for manual `batocera-boot.conf` mergerfs entries) correctly uses `=NC`:

```bash
/usr/bin/mergerfs $MERGERFS_OPTS "$BASE=NC:${BRANCHES}" "$POOL"
```

The storage manager was never updated to match.

## Complication: Steam Launcher Conflict

**Discovered 2026-02-24.** A blanket `=NC` on the NVMe branch breaks Steam game installs.

When a new Steam game is installed, Batocera's Steam add-on creates a new `.sh` launcher file at `/userdata/roms/steam/APPID_Name.sh`. That path goes **through the mergerFS pool**. With `=NC` on the NVMe, mergerFS cannot create the new launcher on the NVMe — it falls back to the external drive with the most free space (BATO-ALL, BATO-LG, etc.).

**Confirmed:** Existing Steam launchers in `/userdata/roms/steam/` are physically on `nvme0n1p2` (NVMe), verified via `stat` → `Device: 259,2`. The user intends Steam launchers to remain on the NVMe for portability (2TB NVMe, Steam games portable without external drives).

**Result:** A blanket `=NC` fix is not safe as-is. The solution must account for the Steam system's need to create new files on the NVMe.

## Solution (Revised — TBD)

A blanket `=NC` on `BASE_DIR` is the correct fix for retro ROM systems, but it conflicts with Steam launcher creation. The solution requires one of the following approaches (not yet decided):

**Option A — Move Steam launchers outside the mergerFS pool**
Reconfigure the Steam add-on and ES system config to write launchers to a path outside `/userdata/roms` (e.g. `/userdata/steam_launchers/`), which is directly on the NVMe and never touched by mergerFS. The `=NC` fix on the pool is then safe.

**Option B — Write Steam launchers to the physical NVMe base path directly**
Have the Steam add-on write to `/userdata/.roms_base/steam/` (the physical NVMe mount point) instead of through the mergerFS pool at `/userdata/roms/steam/`. This bypasses mergerFS entirely for Steam and leaves the pool's `=NC` rule intact.

**Option C — Apply =NC conditionally (per-run, not per-branch)**
Only apply `=NC` on drives that should never receive new writes (i.e. NVMe for retro ROMs), while allowing a Steam-specific write path to bypass the restriction. Requires custom tooling or a wrapper script.

**Immediate safe fix (retro ROMs only):** The `=NC` change on lines 807 and 895 can be applied now — it protects retro ROM systems from duplication. Steam launchers would be affected but Steam installs are rare and the impact is known. The Steam launcher issue should be resolved separately.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera.linux | `package/batocera/core/batocera-scripts/scripts/batocera-storage-manager` | Add `=NC` to BASE_DIR in mergerFS branch strings (3 locations) |

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera.linux | `package/batocera/core/batocera-scripts/scripts/batocera-storage-manager` | Add `=NC` to BASE_DIR in mergerFS branch strings (3 locations) |

## Validation

- [ ] Boot Batocera with external drives connected
- [ ] Upload test files to a system folder via the mergerFS pool (e.g. write to `/userdata/roms/batoparrot/`)
- [ ] Confirm files land on external drive, NOT on NVMe (`/userdata/.roms_base/`)
- [ ] Verify existing NVMe ROM content (steam, ports, pcengine, prboom) is still readable through the pool
- [ ] Test drive removal/re-add (eject + hotplug) rebuilds pool correctly with =NC still applied

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

