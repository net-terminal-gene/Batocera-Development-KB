# Change 01: Steam — create-steam-launchers.sh

## Status: DEPLOYED TO REMOTE BATOCERA

## File

**Remote path:** `/userdata/system/add-ons/steam/create-steam-launchers.sh`

This is the continuously running daemon that generates `.sh` launchers, `.keys` padtokey profiles, downloads images, and maintains `gamelist.xml` for installed Steam games. It runs in a loop every 5 seconds.

## What Was Changed

The CONFIG block at the top of the script was replaced. The original hardcoded `roms="/userdata/roms/steam"` path was changed to dynamically detect `.roms_base`.

## Before

```bash
########################
# CONFIG
########################
roms="/userdata/roms/steam"
images="/userdata/roms/steam/images"
GAMELIST_PATH="$roms/gamelist.xml"
```

## After

```bash
########################
# CONFIG
########################

# Pin Steam files to the internal drive so mergerfs mfs policy
# cannot scatter them across external drives.
if [ -d "/userdata/.roms_base" ]; then
  ROMS_ROOT="/userdata/.roms_base"
else
  ROMS_ROOT="/userdata/roms"
fi
roms="${ROMS_ROOT}/steam"
images="${ROMS_ROOT}/steam/images"
GAMELIST_PATH="$roms/gamelist.xml"
```

## How It Was Applied

Applied via `sed` commands executed remotely through `ssh-batocera.sh`. The original CONFIG block lines were replaced in-place on the live script. No reboot was required — the daemon was restarted by the addon service.

## Variables Affected

| Variable | Before | After |
|----------|--------|-------|
| `ROMS_ROOT` | (did not exist) | `/userdata/.roms_base` or `/userdata/roms` |
| `roms` | `/userdata/roms/steam` | `${ROMS_ROOT}/steam` |
| `images` | `/userdata/roms/steam/images` | `${ROMS_ROOT}/steam/images` |
| `GAMELIST_PATH` | `$roms/gamelist.xml` | `$roms/gamelist.xml` (unchanged, inherits from `roms`) |

## Write Operations Protected

All downstream writes in the script use `$roms`, `$images`, and `$GAMELIST_PATH`, so every file creation is now pinned:
- `.sh` launcher scripts
- `.keys` padtokey profiles
- Downloaded header images (`.jpg`)
- `gamelist.xml` entries
- `mkdir -p "$roms" "$images"` directory creation
