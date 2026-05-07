# BUA Steam: SteamGridDB Artwork Fallback

## Agent/Model Scope

Composer + ssh-batocera for on-device testing

## Problem

`create-steam-launchers.sh` (the Steam addon's launcher generator) requests SteamGridDB artwork at exactly one dimension (`460x215`). If no image exists at that size, the download silently fails and no artwork appears in EmulationStation. Many games only have artwork at other dimensions (512x512, 600x900, 920x430, etc.).

## Root Cause

The `sgdb_get_image()` function hardcodes `?dimensions=460x215&limit=1` in the API request. No fallback to other dimensions or to the unfiltered grid endpoint.

## Solution

Modify `sgdb_get_image()` to attempt multiple dimensions in priority order, falling back to any available grid if none of the preferred sizes exist. Proposed cascade:

1. `460x215` (current, matches Steam library header ratio)
2. `920x430` (2x of above, common upload size)
3. No dimension filter (take whatever is available)

Alternatively, remove the dimension filter entirely and let EmulationStation handle scaling.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera-unofficial-addons | `steam/extra/create-steam-launchers2.sh` | `sgdb_get_image()` fallback logic |
| batocera-unofficial-addons | `steam/extra/create-steam-launchers.sh` | Legacy version (same fix if maintained) |

## Validation

- [ ] Game with 460x215 artwork still downloads correctly (no regression)
- [ ] Game with only 512x512 artwork (e.g. eXceed 2nd - Vampire REX) gets artwork
- [ ] Game with only 600x900 artwork gets artwork
- [ ] Game with no artwork at all doesn't error/crash the loop
- [ ] Artwork appears correctly in EmulationStation gamelist
- [ ] Documentation: non-steam-games folder convention is documented (no nested folders between game-named dir and exe)
