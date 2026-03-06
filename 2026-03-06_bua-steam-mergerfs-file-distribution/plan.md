# mergerfs File Distribution — Pin Addon/Tool Systems to Internal Drive

## Problem

mergerfs `category.create=mfs` policy routes new file creation to the drive with the most free space. This scatters addon/tool files (steam, crt, flatpak, ports) across external drives when those drives have more free space than the internal NVMe.

Affected systems:
- `steam` — game launchers, .steam shortcuts, images, videos, gamelist.xml
- `crt` — CRT Script tools (geometry, grid, mode switcher, GunCon2 calibration)
- `flatpak` — Fightcade flatpak shortcut, images
- `ports` — BUA addon launchers (Crunchyroll, Chrome, Kodi, RGSX, etc.)

None of these should ever live on external drives. They are system tools/addons tied to the internal installation.

## Root Cause

mergerfs mount options: `category.create=mfs` (most free space).

BATO-PARROT (3.7 TB SSD, 2.4 TB free) wins the free-space competition vs NVMe (1.8 TB, 1.3 TB free).

## Solution

### 1. Steam (remote only)

Modified `create-steam-launchers.sh` on remote Batocera to detect `.roms_base` and pin writes there. BUA repo scripts were **not** modified — user reverted those changes.

### 2. CRT (committed & pushed)

Modified 3 files in Batocera-CRT-Script repo, committed `85e95a1` to `crt-hd-mode-switcher-v43`:
- `Batocera-CRT-Script-v43.sh` — `CRT_ROMS` variable + all CRT write targets use it
- `mode_switcher.sh` — `CRT_ROMS` defined in parent (inherited by modules)
- `03_backup_restore.sh` — 41 refs to `/userdata/roms/crt` → `$CRT_ROMS/crt`

Left `DIRS_TO_REMOVE` array at `/userdata/roms/crt` (restore/uninstall path — must delete through merged view).

### 3. Boot guard (remote only)

`mergerfs-pin-internal.sh` deployed to remote. Pre-creates protected dirs on `.roms_base`, moves strays from external drives, runs 5-min background watcher. Called from `custom_service` at boot.

### 4. flatpak, ports (DEFERRED)

All unique files migrated from BATO-PARROT to `.roms_base`. BATO-PARROT directories deleted.
BUA scripts not modified — boot guard covers these at the system level.

### 5. Systemic solution (future, if needed)

The proper fix would be in `batocera-storage-manager` itself — either:
- A config key like `mergerfs.exclude=steam,crt,flatpak,ports` to prevent these dirs from being part of the pool
- Or changing the create policy per-directory (mergerfs supports `.mergerfs` policy files)

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `Batocera_ALLINONE/Batocera-CRT-Script-v43.sh` | `CRT_ROMS` variable + all crt write targets use it |
| Batocera-CRT-Script | `Geometry_modeline/mode_switcher.sh` | `CRT_ROMS` variable defined in parent (inherited by all modules) |
| Batocera-CRT-Script | `Geometry_modeline/mode_switcher_modules/03_backup_restore.sh` | All 41 `/userdata/roms/crt` refs → `$CRT_ROMS/crt` (runtime mode switch) |
| Remote only | `create-steam-launchers.sh` | `ROMS_ROOT` pins Steam writes to `.roms_base` |
| Remote only | `mergerfs-pin-internal.sh` + `custom_service` | Boot guard + watcher for all 4 subsystems |

## Validation

- [x] All unique BATO-PARROT steam files copied to `.roms_base`
- [x] BATO-PARROT steam directory deleted (user approved)
- [x] All unique BATO-PARROT crt files copied to `.roms_base`
- [x] All unique BATO-PARROT flatpak files copied to `.roms_base`
- [x] All unique BATO-PARROT ports files copied to `.roms_base`
- [x] Delete crt/flatpak/ports from BATO-PARROT (user approved, done)
- [x] Test: Steam game (Balatro) loads from `.roms_base` after migration
- [x] Test: new Steam install (ZeroRanger) lands on `.roms_base`
- [x] Test: mode switcher (CRT→HD, HD→CRT) writes CRT tools to `.roms_base`
- [x] Test: boot guard runs at boot, watcher process active
- [x] Test: no protected dirs on external drives after reboot
- [x] CRT script changes committed & pushed (`85e95a1` on `crt-hd-mode-switcher-v43`)
