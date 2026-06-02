# mergerFS Write Routing and S12populateshare Awareness

## Problem

When multiple drives are merged via `batocera-storage-manager`, users have no control over which drive receives new content. Two separate issues compound:

1. **`S12populateshare` is mergerFS-unaware.** It runs before mergerFS mounts and repopulates stock ROM directories (gamelist.xml, demo ROMs) into `/userdata/roms/` whenever a system folder is missing or empty. These files get moved to `.roms_base` by the storage manager, where they shadow identically-named files on external drives due to mergerFS's `ff` (first-found) read policy. This causes artwork and gamelists from external drives to be invisible.

2. **`category.create=eplfs` is a single global policy.** All file creates across all system folders are routed by "existing path, least free space." Users cannot specify per-system write targets (e.g., "SNES goes to BATO-ALL, Windows goes to BATO-PARROT"). New ROMs, scraped artwork, and installed content land on whichever qualifying branch has the least free space, which can split a system's files across drives unpredictably.

## Root Cause

- `S12populateshare` (`/etc/init.d/S12populateshare`) checks only `/userdata/roms/{system}` for existence. It has no knowledge of `batocera-boot.conf` mergerFS config or external drive branches.
- `batocera-storage-manager` hardcodes `MERGERFS_OPTS` with `category.create=eplfs` at line 10. No per-path or per-system override mechanism exists.
- The `mv` from `/userdata/roms/` to `.roms_base/` fails silently when the destination directory is non-empty, leaving stock content "trapped" in the raw partition path on some boots.

## Solution

### Phase 1: Prevent gamelist shadowing (targeted, low-risk)

In `batocera-storage-manager`'s `refresh_pool` logic, after moving content to `.roms_base` but before mounting mergerFS: for each system directory that exists on both `.roms_base` and an external branch, remove the `.roms_base` copy of `gamelist.xml` if the external branch already has one.

### Phase 2: Make S12populateshare mergerFS-aware (medium risk)

Before populating a system directory, check if `mergerfs.roms` is configured in `batocera-boot.conf`. If so, also check each configured external branch for the system directory. Skip population if the system exists on any branch.

### Phase 3: Per-system write routing (design discussion needed)

Add optional config in `batocera-boot.conf` for per-system-folder write targets:

```
mergerfs.roms.create.snes=/media/BATO-ALL/roms
mergerfs.roms.create.windows=/media/BATO-PARROT/roms
mergerfs.roms.create.default=/userdata/.roms_base
```

The storage manager reads these and applies path-specific `func.create` policies via mergerFS's runtime control API (`.mergerfs` control file at mount root).

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera.linux | `board/batocera/fsoverlay/etc/init.d/S12populateshare` | Add mergerFS branch awareness (Phase 2) |
| batocera.linux | `package/batocera/core/batocera-scripts/scripts/batocera-storage-manager` | Gamelist dedup in refresh_pool (Phase 1); per-system create policy (Phase 3) |
| batocera.linux | `/boot/batocera-boot.conf` | New optional keys for per-system write routing (Phase 3) |

## Validation

- [ ] Fresh install with external drive: stock systems on external drive are not shadowed by `.roms_base` gamelists
- [ ] Reboot cycle: S12populateshare does not repopulate systems that exist on external drives
- [ ] New ROM added via ES scraper lands on the expected drive
- [ ] Ejecting all drives restores `.roms_base` content correctly (no data loss)
- [ ] Existing single-drive setups (no mergerFS) are unaffected
