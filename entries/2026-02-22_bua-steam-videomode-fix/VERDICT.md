# VERDICT — BUA Steam Per-Game VIDEO MODE Fix

## Status: FIXED (batocera-unofficial-addons)

## Summary

Per-game VIDEO MODE for BUA Steam games was not applied because configgen looked up settings under `ports["rom"]` instead of `steam["rom"]`, and used the Flatpak steam generator instead of the sh generator. Fix applied in `batocera-unofficial-addons` branch `fix-steam-videomode` (commit 40f8317).

## Root Causes

1. **`es_systems_steam.cfg`** used `-system ports -systemname ports` → configgen read `ports["game.sh"]`, not `steam["game.sh"]`
2. **Emulator** was `steam` (Flatpak) instead of `sh` → ran batocera-steam without steam.emulator=sh
3. **Duplicate videomode** in `es_features_steam.cfg` → double VIDEO MODE in EmulationStation

## Changes Applied

| File | Change |
|------|--------|
| `steam/extra/es_systems_steam.cfg` | -system steam, sh emulator |
| `steam/extra/es_features_steam.cfg` | Removed videomode from features |
| `steam/steam.sh` | Add steam.emulator=sh, steam.core=sh on install |
| `steam/steam2.sh` | Add steam.emulator=sh, steam.core=sh on install (same as steam.sh) |
| `steam/extra/ensure_steam_batocera_conf.sh` | Boot-time ensure: add steam.emulator=sh, steam.core=sh if missing (for HD/CRT mode switcher) |
| `steam/steam.sh`, `steam/steam2.sh` | Download ensure script, add to custom.sh at install |

## Boot-Time Ensure (Mode-Switcher Compatibility)

When batocera.conf is restored from a mode backup (e.g. HD↔CRT) that predates Steam install, steam.* is wiped. `ensure_steam_batocera_conf.sh` runs at boot via custom.sh and adds steam.emulator=sh, steam.core=sh if missing. Per-game videomode stays in each mode's backup (HD: 1920x1080, CRT: 854x480)—no re-apply from source.

## Note: steam.sh vs steam2.sh

`steam.sh` is the old build (multi-part AppImage). `steam2.sh` is the latest build (single AppImage, overlay migration). Both require the batocera.conf write logic for videomode. Same distinction: Launcher/Launcher2, create-steam-launchers.sh/create-steam-launchers2.sh.
