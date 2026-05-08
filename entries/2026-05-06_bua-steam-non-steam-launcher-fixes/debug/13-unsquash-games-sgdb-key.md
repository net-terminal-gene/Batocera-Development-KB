# 13 — Unsquash Non-Steam Games + SGDB Key

## Date: 2026-05-07

## Context

While Steam is running in Desktop mode, unsquashed both game archives and confirmed SGDB key is in place.

## Games Unsquashed

### eXceed 2nd Vampire REX

- **Exe:** `/userdata/system/add-ons/steam/non-steam-games/eXceed 2nd Vampire REX/game/eXceed2nd-VR.exe`
- Contains full Wine prefix (drive_c/, dosdevices/, etc.) from squashfs
- Game exe is nested under `game/` subdirectory

### eXceed 3rd Jade Penetrate Black Package

- **Exe:** `/userdata/system/add-ons/steam/non-steam-games/eXceed 3rd Jade Penetrate Black Package/game/eXceed3rd-BR.exe`
- Also has `LAUNCHER.exe` and `LAUNCHER_x64.exe` in `game/` (use the actual game exe, not launchers)
- Same structure: full Wine prefix + game in `game/` subdirectory

## SteamGridDB Key

- **File:** `/userdata/system/add-ons/steam/steamgriddb.key`
- **Key:** present (32 chars)
- Already existed on device (persisted from previous session or pre-staged)

## Directory Structure

```
non-steam-games/
├── eXceed 2nd Vampire REX/
│   ├── game/
│   │   └── eXceed2nd-VR.exe          ← TARGET
│   ├── drive_c/                       (full Wine prefix from squashfs)
│   ├── dosdevices/
│   └── ...
├── eXceed 2nd Vampire REX.wsquashfs
├── eXceed 3rd Jade Penetrate Black Package/
│   ├── game/
│   │   ├── eXceed3rd-BR.exe          ← TARGET
│   │   ├── LAUNCHER.exe
│   │   └── LAUNCHER_x64.exe
│   ├── drive_c/
│   ├── dosdevices/
│   └── ...
└── eXceed 3rd Jade Penetrate Black Package.wsquashfs
```

## Note: drive_c Bloat Left In Place

Unlike the failed attempt (which stripped drive_c/ etc.), we're leaving the full Wine prefix intact this time. Our SLR+Proton launcher creates its OWN compatdata/pfx, so the existing drive_c in the game directory should be ignored by Proton. If it causes issues, we can strip later.

## Adding Games in Steam

When adding as non-Steam shortcuts in Steam Desktop mode, point to:
1. **eXceed 2nd:** Browse to `/root/non-steam-games/eXceed 2nd Vampire REX/game/eXceed2nd-VR.exe`
2. **eXceed 3rd:** Browse to `/root/non-steam-games/eXceed 3rd Jade Penetrate Black Package/game/eXceed3rd-BR.exe`

(Paths use `/root/` because Steam sees HOME as `/root` inside bwrap container, which maps to `/userdata/system/add-ons/steam/`)

## Next Step

User adds both games as non-Steam shortcuts in Steam Desktop mode. Generator should pick up shortcuts.vdf within 5 seconds.
