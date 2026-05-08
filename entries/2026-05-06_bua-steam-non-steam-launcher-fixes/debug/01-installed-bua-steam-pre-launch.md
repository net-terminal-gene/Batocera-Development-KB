# 01 — Installed BUA + Steam Addon (Pre-Launch)

## Date: 2026-05-07

## Context

BUA Steam addon installed from BUA UI. Steam has NOT been launched yet.

## Device State

### `/userdata/system/add-ons/steam/`

```
Launcher                    (4656 bytes) — ES launch wrapper
create-steam-launchers.sh   (17930 bytes) — UPSTREAM version (not patched)
extra/
  ensure_steam_batocera_conf.sh  (740 bytes)
  icon.png                       (140735 bytes)
lbfix.sh                    (732 bytes)
steam                       (392MB) — RunImage Steam binary
```

- `.local/share/Steam/` does NOT exist (first launch hasn't happened)
- No `steamgriddb.key`
- No `non-steam-games/`

### `/userdata/roms/steam/`

```
Steam.steam                 (24 bytes) — native Batocera placeholder
Steam_Big_Picture.sh        (65 bytes) — BUA launcher: calls `/userdata/system/add-ons/steam/Launcher "-gamepadui"`
Steam_Big_Picture.sh.keys   (534 bytes) — padtokey profile
_info.txt                   (370 bytes) — factory info
gamelist.xml                (422 bytes)
images/                     — artwork dir
```

### `gamelist.xml`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<gameList>
  <game>
    <path>./bua.sh</path>
    <name>Batocera Unofficial Add-Ons Installer</name>
    <image>./images/BatoceraUnofficialAddons.png</image>
    <marquee>./images/BatoceraUnofficialAddons_Wheel.png</marquee>
  </game>
  <game>
    <path>./Steam_Big_Picture.sh</path>
    <name>Steam Big Picture</name>
    <image>./images/steamlogo.jpg</image>
  </game>
</gameList>
```

## Key Observations

- `create-steam-launchers.sh` is 17930 bytes = **upstream (unpatched)**. Our patch is 17479 bytes.
- `extra/` only has `ensure_steam_batocera_conf.sh` and `icon.png` (no `create-steam-launchers2.sh` in extra on device, that's a repo-only path)
- The addon deploys `steam/extra/create-steam-launchers2.sh` AS `create-steam-launchers.sh` at the addon root during install
- No Steam runtime dirs exist yet (Proton, SLR_4, steamapps/common all absent until first launch + manual install)

## Next Step

User will tell me when to rsync the patched script, or launch Big Picture first to establish baseline.
