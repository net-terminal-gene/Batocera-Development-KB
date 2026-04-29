# VERDICT — BUA Steam Boot-Time Ensure

## Status: PR Open

## Summary

Implemented boot-time ensure script in BUA that adds `steam.emulator=sh` and `steam.core=sh` only when missing. Fixes Steam launch failure after Batocera system updates or other batocera.conf overwrites. Especially relevant on Steam Deck.

## Root Causes

1. System updates and other batocera.conf overwrites can remove steam.* entries
2. Without steam.emulator=sh and steam.core=sh, configgen falls back to Flatpak steam generator
3. BUA Steam (non-Flatpak) fails → games show "app not installed"

## Changes Applied

| File | Change |
|------|--------|
| steam/extra/ensure_steam_batocera_conf.sh | New: boot script, append steam.* when absent |
| steam/steam.sh | Download ensure script, register in custom.sh |
| steam/steam2.sh | Same |

## PR

[PR #145](https://github.com/batocera-unofficial-addons/batocera-unofficial-addons/pull/145) — batocera-unofficial-addons
