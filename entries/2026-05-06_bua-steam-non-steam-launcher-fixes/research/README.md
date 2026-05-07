# Research — BUA Steam: Non-Steam Launcher Fixes

## Findings

### Steam's Internal Launch Chain (from compat_log.txt)

When Steam launches any game via Proton, it uses this prefix:

```
'/root/.local/share/Steam/steamapps/common/SteamLinuxRuntime_4'/_v2-entry-point --verb=run -- '/root/.local/share/Steam/steamapps/common/Proton - Experimental'/proton run
```

The `_v2-entry-point` script sets up a bubblewrap container providing:
- PulseAudio/PipeWire socket forwarding (audio)
- Proper library paths for 32-bit and 64-bit
- SDL/controller environment
- Filesystem isolation

The upstream `create-steam-launchers.sh` skips this entirely and calls `proton run` bare.

### Why direct Proton breaks audio

PipeWire is the audio server on Batocera (with PulseAudio compat layer):
- Server: `PulseAudio (on PipeWire 1.4.6)` at `/var/run/pulse/native`
- `pulseaudio --check` returns 1 (no standalone daemon), but `pactl info` works (PipeWire provides the socket)
- SteamLinuxRuntime's container bind-mounts the pulse socket, making audio available inside
- Bare Proton launch doesn't set up the socket mapping, so Wine/game can't find audio

### Why direct Proton breaks controllers

Without SteamLinuxRuntime:
- No Steam Input translation layer
- Raw gamepad events go directly to Wine/game
- The 8BitDo Lite 2 Y-axis appears inverted without SDL remapping
- SLR provides the proper SDL environment that maps axes correctly

### Steamclient Assertion (suppressible)

When Proton launches outside of a running Steam client, `C:\windows\system32\steam.exe` (Wine stub) tries to connect to Steam via lsteamclient. This fails with:

```
Assertion Failed!
File: ../src-lsteamclient/steamclient_main.c
Line: 375
Expression: "!status"
```

Suppressed by:
- `PROTON_NO_STEAM_OVERLAY=1` — disables overlay DLL injection (not sufficient alone)
- `WINEDLLOVERRIDES="lsteamclient=d;steam.exe=d"` — completely disables the DLLs in Wine

These are safe for non-Steam games which don't use Steam API features.

### Failed approaches for Steam-mediated launch

| Method | Result |
|--------|--------|
| `steam -applaunch $APPID` | "Game configuration unavailable" — shortcut IDs aren't real Steam AppIDs |
| `steam steam://rungameid/$APPID` (startup arg) | Only Big Picture opens, game doesn't launch |
| Two-phase: start Steam, then send `steam://rungameid/` | Same result — Big Picture only |
| Write to `steam.pipe` FIFO | Blocks indefinitely — RunImage inner process doesn't read from host pipe |

The RunImage container binary (393MB ELF) doesn't properly relay URL protocol commands to the inner Steam client for non-Steam shortcuts. Only official Steam AppIDs work with `-applaunch`.

### SteamGridDB API Dimensions

The `/api/v2/grids/game/{id}` endpoint accepts a `dimensions` query param. Common grid sizes:

- `460x215` — Steam library header (landscape, small)
- `920x430` — 2x Steam header (landscape, large)
- `600x900` — Portrait grid (Steam Big Picture style)
- `512x512` — Square (alternate style)

#### Test Case: eXceed 2nd - Vampire REX (SGDB ID: 1911)

- `?dimensions=460x215` → `"total": 0` (no results)
- No filter → `"total": 3` (512x512 and 600x900 available)

### Non-Steam Game Folder Convention (CRITICAL for artwork)

The launcher generator derives the SteamGridDB search term from `basename(StartDir)` in `shortcuts.vdf`:

```python
search_term = os.path.basename(startdir.rstrip('/\\')) or appname
```

**The folder containing the game exe IS the search term sent to SteamGridDB.**

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
