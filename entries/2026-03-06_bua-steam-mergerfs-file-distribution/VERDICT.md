# VERDICT — mergerfs File Distribution (steam, crt, flatpak, ports)

## Status: FIXED (CRT + Boot Guard) / DEFERRED (BUA scripts)

## Summary

mergerfs `category.create=mfs` policy was scattering BUA addon and CRT Script files across external drives (primarily BATO-PARROT, which has the most free space). Four ROM subsystems were affected: steam, crt, flatpak, and ports.

All unique files have been consolidated to the internal NVMe (`.roms_base`). All four directories deleted from BATO-PARROT after user approval.

## What Was Fixed

### Batocera-CRT-Script (committed & pushed)

CRT installer and mode switcher scripts now detect `.roms_base` and write CRT tools there, preventing mergerfs from scattering files on install or mode switch. Commit `85e95a1` pushed to `crt-hd-mode-switcher-v43` branch.

### Remote Batocera (deployed, not in any repo)

- **Steam**: `create-steam-launchers.sh` modified on remote to pin writes to `.roms_base`
- **Boot guard**: `mergerfs-pin-internal.sh` deployed to `/userdata/system/scripts/`, called from `custom_service` at boot. Pre-creates protected dirs on internal, moves strays back, runs a 5-minute background watcher. Covers all four subsystems.

### BUA scripts (DEFERRED)

BUA addon scripts for steam, flatpak, and ports were **not** modified. The boot guard handles these at the system level. If BUA changes are desired in the future, the `.roms_base` detection pattern is documented in `code-changes/`.

## Plan vs Reality

Original plan called for modifying BUA scripts directly. This was abandoned in favor of:
1. Fixing CRT scripts at the source (committed to repo)
2. Fixing Steam on the remote only (not committed to BUA repo)
3. A systemic boot guard for all four subsystems (remote only)

## Root Causes

1. mergerfs `category.create=mfs` routes new files to the drive with the most free space
2. BATO-PARROT (3.7 TB SSD, 2.4 TB free) consistently wins the free-space competition
3. Addon scripts hardcode `/userdata/roms/` which goes through the merged view

## Changes Applied

| Repo / Location | File | Change |
|-----------------|------|--------|
| Batocera-CRT-Script | `Batocera-CRT-Script-v43.sh` | `CRT_ROMS` variable pins writes to `.roms_base` |
| Batocera-CRT-Script | `mode_switcher.sh` | `CRT_ROMS` variable defined (inherited by modules) |
| Batocera-CRT-Script | `03_backup_restore.sh` | 41 refs to `/userdata/roms/crt` → `$CRT_ROMS/crt` |
| Remote only | `create-steam-launchers.sh` | `ROMS_ROOT` pins Steam writes to `.roms_base` |
| Remote only | `mergerfs-pin-internal.sh` | Boot guard + 5-min watcher for all 4 subsystems |
| Remote only | `custom_service` | Appended boot guard invocation |
| Remote only | BATO-PARROT `/roms/{steam,crt,flatpak,ports}` | All deleted after file migration |

## Models Used

- claude-4.6-opus-max — investigation, root cause analysis, fix design, deployment, debugging

## What Worked

- `.roms_base` detection pattern is clean and backward-compatible (falls back to `/userdata/roms` when no mergerfs)
- Boot guard as a catch-all eliminated the need to fix 100+ BUA scripts individually
- Incremental testing (reboot, mode switch, game install, game launch) caught boot guard deployment issues early

## What Didn't Work

- Initial attempt to use `/userdata/system/custom.sh` as boot hook — deprecated in v43, silently ignored
- Had to discover that `custom_service` is the real v43 boot mechanism
