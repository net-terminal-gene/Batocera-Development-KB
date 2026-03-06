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

### 1. Steam (implemented)

Modified 4 BUA scripts to detect `.roms_base` and write directly there:
- `steam/extra/create-steam-launchers2.sh`
- `steam/extra/create-steam-launchers.sh`
- `steam/steam2.sh`
- `steam/steam.sh`

### 2. CRT (implemented)

Modified `Batocera-CRT-Script-v43.sh` to detect `.roms_base` and write CRT tools there.
Added `CRT_ROMS` variable near line 5069 that resolves to `/userdata/.roms_base` (when mergerfs active) or `/userdata/roms` (fallback).
Updated all write targets: `cp -a crt/`, `chmod` of tool scripts/keys, mode_switcher copy, gamelist.xml copy, overlays_overrides copy, GunCon2_Calibration.sh generation.
Left `DIRS_TO_REMOVE` array at `/userdata/roms/crt` (restore/uninstall path — must delete through merged view).

### 3. flatpak, ports (file migration done, script fixes pending)

All unique files from BATO-PARROT copied to `.roms_base` for all 3 folders plus crt. BATO-PARROT directories deleted (user approved).

Script fix scope:
- **flatpak**: Written by BUA flatpak template + individual addon scripts (7 scripts). Feasible to fix.
- **ports**: Written by 100+ BUA addon scripts. Not feasible to fix individually — needs a systemic solution (shared helper function or batocera-storage-manager exclusion list).

### 3. Systemic solution (future)

The proper fix is in `batocera-storage-manager` itself — either:
- A config key like `mergerfs.exclude=steam,crt,flatpak,ports` to prevent these dirs from being part of the pool
- Or changing the create policy per-directory (mergerfs supports `.mergerfs` policy files)

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera-unofficial-addons | `steam/extra/create-steam-launchers2.sh` | Write to `.roms_base` when mergerfs active |
| batocera-unofficial-addons | `steam/extra/create-steam-launchers.sh` | Write to `.roms_base` when mergerfs active |
| batocera-unofficial-addons | `steam/steam2.sh` | Write to `.roms_base` when mergerfs active |
| batocera-unofficial-addons | `steam/steam.sh` | Write to `.roms_base` when mergerfs active |
| Batocera-CRT-Script | `Batocera_ALLINONE/Batocera-CRT-Script-v43.sh` | `CRT_ROMS` variable + all crt write targets use it |
| Batocera-CRT-Script | `Geometry_modeline/mode_switcher.sh` | `CRT_ROMS` variable defined in parent (inherited by all modules) |
| Batocera-CRT-Script | `Geometry_modeline/mode_switcher_modules/03_backup_restore.sh` | All 41 `/userdata/roms/crt` refs → `$CRT_ROMS/crt` (runtime mode switch) |

## Validation

- [x] All unique BATO-PARROT steam files copied to `.roms_base`
- [x] BATO-PARROT steam directory deleted (user approved)
- [x] All unique BATO-PARROT crt files copied to `.roms_base`
- [x] All unique BATO-PARROT flatpak files copied to `.roms_base`
- [x] All unique BATO-PARROT ports files copied to `.roms_base`
- [x] Delete crt/flatpak/ports from BATO-PARROT (user approved, done)
- [ ] Test: reinstall Steam addon and verify files land on `.roms_base`
- [ ] Test: run CRT Script and verify files land on `.roms_base`
