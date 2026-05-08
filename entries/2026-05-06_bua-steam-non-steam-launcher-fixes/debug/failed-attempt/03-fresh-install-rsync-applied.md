# 03 — Fresh Install, BUA Steam Installed, Rsync Applied (Pre-Launch)

## Date: 2026-05-07

## Context

Fresh v43 image. BUA Steam addon installed. Patched `create-steam-launchers2.sh` rsynced BEFORE first Steam launch.

## What was rsynced

- **File:** `steam/extra/create-steam-launchers2.sh` (17479 bytes)
- **To:** `/userdata/system/add-ons/steam/create-steam-launchers.sh`
- **Permissions:** `-rwxr-xr-x` (chmod +x applied)
- **Contains:**
  - SLR launcher template (SteamLinuxRuntime_4 + Proton Experimental)
  - Artwork dimension fallback (460x215 -> 920x430 -> any)
  - Nested folder search term logic (uses game-named dir under `non-steam-games/`)
  - NO `ensure_proton_deps` logic (removed)

## State

- Steam has NOT been launched yet
- No `shortcuts.vdf`, no `steamapps/common/`, no non-Steam games
- Ready for first launch from ES

## Next Step

User will launch Steam Big Picture from ES, log in, install Proton Experimental from Library, add non-Steam games, then verify launchers are generated correctly.
