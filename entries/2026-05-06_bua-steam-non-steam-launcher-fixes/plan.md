# BUA Steam: Non-Steam Launcher Fixes

## Agent/Model Scope

Opus 4.6 High + ssh-batocera for on-device testing

## Problem

`create-steam-launchers.sh` (the Steam addon's launcher generator for EmulationStation) has two critical issues with non-Steam game shortcuts:

1. **No sound, broken controller input** — Launchers invoke `proton run` directly, bypassing the Steam Linux Runtime container that provides audio routing and controller environment.
2. **Artwork silently fails for many games** — `sgdb_get_image()` hardcodes `dimensions=460x215`. If no image exists at that exact size, no artwork appears.

## Root Causes

1. **Launcher template** uses bare Proton (`"$PROTON_PATH" run "$EXE"`). Steam itself uses `SteamLinuxRuntime_4/_v2-entry-point --verb=run -- proton run` which wraps the game in a bubblewrap container providing PulseAudio/PipeWire forwarding and proper SDL environment.
2. **Artwork function** sends a single API request with a fixed dimension filter. Many games only have artwork at other sizes (512x512, 600x900, 920x430).

## Solution

### Fix 1: SteamLinuxRuntime launch chain (VALIDATED on device)

Replace the non-Steam launcher template (lines ~403-435) to use:

```bash
SLR_ENTRY="${STEAM_APPS}/common/SteamLinuxRuntime_4/_v2-entry-point"
PROTON_PATH="${STEAM_APPS}/common/${proton_name}/proton"

export PROTON_NO_STEAM_OVERLAY=1
export WINEDLLOVERRIDES="lsteamclient=d;steam.exe=d"
export PULSE_SERVER="unix:/var/run/pulse/native"

"$SLR_ENTRY" --verb=run -- "$PROTON_PATH" run "$EXE"
```

- `PROTON_NO_STEAM_OVERLAY=1` — Prevents overlay from trying to connect to non-existent Steam daemon
- `WINEDLLOVERRIDES="lsteamclient=d;steam.exe=d"` — Suppresses assertion in Wine's steamclient stub
- `PULSE_SERVER` — Explicit PipeWire/PulseAudio socket path

### Fix 2: SteamGridDB dimension fallback

Replace single API call in `sgdb_get_image()` with cascading attempts:
1. `460x215` (current, matches Steam library header ratio)
2. `920x430` (2x of above, common upload size)
3. No dimension filter (take whatever is available)

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera-unofficial-addons | `steam/extra/create-steam-launchers.sh` | Launcher template: SLR chain + env vars |
| batocera-unofficial-addons | `steam/extra/create-steam-launchers.sh` | `sgdb_get_image()`: dimension fallback |
| batocera-unofficial-addons | `steam/extra/create-steam-launchers2.sh` | Same fixes if maintained |

## Validation

- [x] Game launches with sound via SLR+Proton chain (eXceed 2nd - Vampire REX)
- [x] Controller axes correct (8BitDo Lite 2, no inversion)
- [x] No steamclient assertion dialog
- [ ] Game with 460x215 artwork still downloads correctly (no regression)
- [ ] Game with only 512x512 artwork gets artwork via fallback
- [ ] Game with no artwork at all doesn't error/crash the loop
- [ ] Official Steam games (e.g. Blaze of Storm) still launch correctly (no regression from SLR change)
- [ ] Clean exit back to ES after game close
- [ ] Documentation: non-steam-games folder convention (no nested folders between game-named dir and exe)
