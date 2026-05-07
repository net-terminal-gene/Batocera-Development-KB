# Research — BUA Steam: SteamGridDB Artwork Fallback

## Findings

### SteamGridDB API Dimensions

The `/api/v2/grids/game/{id}` endpoint accepts a `dimensions` query param. Common grid sizes on SGDB:

- `460x215` — Steam library header (landscape, small)
- `920x430` — 2x Steam header (landscape, large)
- `600x900` — Portrait grid (Steam Big Picture style)
- `512x512` — Square (alternate style)
- `342x482` — Smaller portrait

### Test Case: eXceed 2nd - Vampire REX (SGDB ID: 1911)

- `?dimensions=460x215` → `"total": 0` (no results)
- `?dimensions=920x430` → not tested yet
- No filter → `"total": 3` (512x512 and 600x900 available)

### Test Case: Blaze of Storm (AppID 3513070)

- `?dimensions=460x215` → presumably succeeds (artwork downloaded at install time)

### Non-Steam Game Folder Convention (CRITICAL for artwork)

The launcher generator (`create-steam-launchers.sh`) derives the SteamGridDB search term from `basename(StartDir)` in `shortcuts.vdf`:

```python
search_term = os.path.basename(startdir.rstrip('/\\')) or appname
```

**This means the folder containing the game exe IS the search term sent to SteamGridDB.**

#### Rule: No nested folders between game-named directory and exe

**WRONG (artwork breaks):**
```
non-steam-games/
└── eXceed 2nd Vampire REX/
    └── game/                  ← Steam sets StartDir to THIS
        └── eXceed2nd-VR.exe   ← search_term = "game" (useless)
```

**CORRECT (artwork works):**
```
non-steam-games/
└── eXceed 2nd Vampire REX/
    ├── eXceed2nd-VR.exe       ← search_term = "eXceed 2nd Vampire REX" (correct)
    ├── BGM/
    └── ...
```

#### After unsquashing a `.wsquashfs`:

1. Delete Wine prefix dead weight: `dosdevices/`, `drive_c/`, `*.reg`, `.update-timestamp`, `autorun.cmd`
2. If game files are in a subfolder (e.g. `game/`), move all contents up: `mv game/* . && rmdir game`
3. The exe must live directly inside a folder whose name matches the game title
4. When adding in Steam, the "Start In" will auto-fill to the game-named folder

#### Exceptions (games already in named folders):

Some wsquashfs archives (e.g. Ganryu 2) put files in `drive_c/Ganryu 2/Ganryu 2.exe`. For these:
- Delete everything except the game folder under `drive_c/`
- Move the game folder up to become the top-level directory
- Result: `Ganryu 2/Ganryu 2.exe` — StartDir = "Ganryu 2" (correct)

#### Why this matters:

- Steam auto-fills "Start In" to the directory containing the exe
- The script takes the last path component of "Start In" as the game name
- If that name is generic (`game`, `bin`, `app`), SteamGridDB lookup fails or returns wrong results
- Even if SteamGridDB finds the correct game, the launcher filename and gamelist entry will use the wrong name
