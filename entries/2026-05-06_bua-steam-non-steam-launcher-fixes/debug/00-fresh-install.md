# 00 — Fresh Install (Clean Slate)

## Date: 2026-05-07

## Purpose

Starting a fresh debugging session. Previous attempt archived in `failed-attempt/`.

## Device Baseline

- **OS:** Batocera v43 (fresh image or wiped userdata)
- **Connection:** SSH via `ssh-batocera` skill
- **Branch:** `fix/steam-non-steam-launcher-slr` in `batocera-unofficial-addons`
- **Patched file:** `steam/extra/create-steam-launchers2.sh` (17479 bytes, 523 lines)

## What the Patch Changes (vs upstream main)

| Area | Before (main) | After (patch) |
|------|---------------|---------------|
| Launch chain | `"$PROTON_PATH" run "$EXE"` (bare Proton) | `SLR_ENTRY --verb=run -- PROTON_PATH run EXE` (full SteamLinuxRuntime container) |
| Proton selection | `detect_proton()` scans all versions | Hardcoded `Proton - Experimental` |
| Controller | `SDL_GAMECONTROLLERCONFIG` Steam Deck hack | Removed (SLR provides SDL env) |
| Env vars | `STEAM_COMPAT_DATA_PATH`, `STEAM_COMPAT_CLIENT_INSTALL_PATH`, `STEAM_COMPAT_APP_ID` | All of those + `SteamAppId`, `SteamGameId`, `PULSE_SERVER`, `PROTON_NO_STEAM_OVERLAY=1`, `WINEDLLOVERRIDES="lsteamclient=d;steam.exe=d"` |
| Artwork | `sgdb_get_image()` hardcodes `dimensions=460x215` | Cascades: 460x215 -> 920x430 -> any |
| Search term | `os.path.basename(startdir)` | Detects `non-steam-games/` marker, uses game-named directory (handles nested exe) |
| Cleanup | `pkill steam/steamwebhelper` | `pkill wineserver` (avoids killing actual Steam) |
| Wine prefix init | `"$PROTON_PATH" run wineboot -u` | `"$SLR_ENTRY" --verb=run -- "$PROTON_PATH" run wineboot -u` |

## Key Findings from Failed Attempt

1. Proton Experimental and SteamLinuxRuntime_4 are NOT present on fresh install; user must install manually from Steam Library.
2. `steam://install/<APPID>` does NOT work as auto-install mechanism in RunImage container.
3. Upstream file is `steam/extra/create-steam-launchers2.sh` deployed by `steam2.sh` (NOT the `create-steam-launchers.sh` at addon root).
4. BUA deploys the script to `/userdata/system/add-ons/steam/create-steam-launchers.sh` (no "2" suffix on device).

## What Needs to Be Tested

- [ ] Rsync patched script to device
- [ ] Launch Steam Big Picture from ES
- [ ] Confirm `create-steam-launchers.sh` runs (check process list)
- [ ] Verify non-Steam game launchers are generated in `/userdata/roms/steam/`
- [ ] Launch a non-Steam game from ES: confirm sound, controller, no assertion dialog
- [ ] Confirm artwork downloads via SGDB fallback
- [ ] Clean exit back to ES after game close

## Issue Being Debugged

(Fill in: what went wrong that the previous agent couldn't resolve)

---

## Current Device State

(To be populated via SSH inspection)
