# VERDICT — v43 game saves layout + Steam ↔ ES

**Status:** **RESOLVED (upstream fix merged)**  
**Date:** 2026-05-04

## Summary

Session documented **v42 vs v43** `/userdata/saves` layout on **x86_64** (not Zen3) and traced **Steam games missing in EmulationStation on v43** to **`batocera-steam-update`** scanning only **`/userdata/saves/flatpak/data/Desktop/`** after upstream commit **`ab1a8b85f913d126162492c9b2aa468f6dfb3122`**, while Flatpak Steam on tested hosts wrote game **`*.desktop`** files under **`.var/app/com.valvesoftware.Steam/.local/share/applications/`**.

## Plan vs reality

| Plan | Outcome |
|------|---------|
| Path documentation | Done — **`research/v42-x86_64-snapshot.md`**, **`steam-es-batocera-steam-update-regression.md`** |
| v43 on-box re-check | Done — script lines + **`Desktop`** vs **`applications`** confirmed |
| Optional upstream issue | Superseded by **PR** |

## Root cause

**`steam_apps_dir`** narrowed to **`Desktop/`** only; **`find`** returned nothing when Steam kept writing under **`applications/`**.

## Upstream change

**PR [#15670](https://github.com/batocera-linux/batocera.linux/pull/15670)** — *batocera-steam-update: support both Desktop/ and .local/share/applications for game shortcuts* (author zognic). Scans **both** directories when present.

**Merged to `batocera-linux/batocera.linux` `master`:** 2026-05-04 (`mergedAt` 09:33 UTC). Merge commit **`b27ce08ab3833be9b8e5432d5882a6f66d0c1d2a`**.

## Hardware validation (contributor)

**v43 x86_64:** dual-path **`batocera-steam-update`** tested on device; new install **Animal Well** produced **`ANIMAL WELL.desktop`** under **`applications/`**, **`steam.log`** reported **`1 games added`**, ES showed the title.

## Files of record

- **`research/steam-es-batocera-steam-update-regression.md`**
- **`pr-status.md`**
