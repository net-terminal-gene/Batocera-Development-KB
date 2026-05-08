# 01 — Installed BUA Steam (Pre-Launch)

## Date: 2026-05-07

## Context

BUA Steam addon installed from BUA UI. Steam has NOT been launched yet. Capturing state before first launch.

## Filesystem State

### `/userdata/system/add-ons/steam/`

```
Launcher                    ← ES launch wrapper (starts Steam + create-steam-launchers.sh)
create-steam-launchers.sh   ← launcher generator (upstream version, -rwxr-xr-x, 17930 bytes)
extra/                      ← helper scripts directory
lbfix.sh                    ← library fix script
steam                       ← RunImage Steam binary
```

- `steamapps/common/` does NOT exist yet (no Steam runtime downloaded)
- `non-steam-games/` does NOT exist yet
- `.local/share/Steam/` not yet populated (first launch hasn't happened)

### `/userdata/roms/steam/`

```
Steam.steam                 ← native Batocera Steam placeholder (from factory)
Steam_Big_Picture.sh        ← BUA-added launcher script
Steam_Big_Picture.sh.keys   ← padtokey profile (hotkey+start kills Steam)
_info.txt                   ← factory info file
gamelist.xml                ← updated by BUA installer
images/                     ← artwork directory
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

## Notes

- `create-steam-launchers.sh` is the UPSTREAM version (17930 bytes), not our patched version (17479 bytes)
- Permissions are correct (`-rwxr-xr-x`) because `steam2.sh` runs `chmod +x` during install
- No `steamgriddb.key` present (user hasn't configured one yet)
- No `non-steam-games/` directory (user hasn't added any games yet)
- The script that BUA downloaded is from `main` branch (unpatched)
