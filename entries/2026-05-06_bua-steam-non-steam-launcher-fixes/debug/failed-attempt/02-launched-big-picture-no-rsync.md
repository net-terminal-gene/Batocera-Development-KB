# 02 — Launched Big Picture (No rsync, Upstream Script)

## Date: 2026-05-07

## Context

First launch of Steam Big Picture from ES after BUA Steam install. Using the UPSTREAM `create-steam-launchers.sh` (not our patched version). No rsync applied.

## Observed Behavior

- Steam launched successfully in gamepadui (Big Picture) mode
- `create-steam-launchers.sh` IS running (PID 19656)
- Steam is fully operational inside RunImage/bwrap container
- User has NOT logged in yet (steamid=0 in process args)

## Filesystem State

### `steamapps/common/`

Empty. No Proton, no SteamLinuxRuntime yet.

### `/userdata/roms/steam/`

Only `Steam_Big_Picture.sh` launcher exists (from BUA install). No shortcut launchers generated.

### Gamelist

Only BUA Installer and Steam Big Picture entries.

## Process Tree (Key Processes)

```
/bin/bash Launcher -gamepadui
  └── /bin/bash create-steam-launchers.sh        ← generator running
  └── steam -gamepadui
       └── dwarfs (mounts RunImage)
            └── bwrap (container)
                 └── steam -srt-logger-opened -gamepadui
                      └── steamwebhelper (multiple)
                      └── steam-runtime-launcher-service
```

## Notes

- The upstream `create-steam-launchers.sh` is running and looping without errors (no `set -e` crash)
- This confirms that Big Picture launches correctly with the upstream BUA script on a fresh install
- `steamapps/common/` is empty, confirming Proton/SLR must be installed manually by the user
- No `shortcuts.vdf` exists yet (user hasn't added non-Steam games)
- No `steamgriddb.key` present
