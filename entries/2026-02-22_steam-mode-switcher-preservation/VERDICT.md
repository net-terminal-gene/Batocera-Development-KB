# VERDICT — Steam Mode Switcher Preservation

## Status: Superseded by BUA Approach

## Summary

We did not implement Mode Switcher preservation. Instead, we implemented a BUA boot-time ensure script (`ensure_steam_batocera_conf.sh`) that adds `steam.emulator=sh` and `steam.core=sh` when missing. See `2026-02-25_bua-steam-boot-ensure` and [PR #145](https://github.com/batocera-unofficial-addons/batocera-unofficial-addons/pull/145). The Mode Switcher design remains for possible future revisit.

## Root Causes

Same as described in plan/research: mode switcher full-file batocera.conf restore overwrites steam.* when target backup predates BUA Steam install.

## Changes Applied

None in Batocera-CRT-Script. Implementation in batocera-unofficial-addons.
