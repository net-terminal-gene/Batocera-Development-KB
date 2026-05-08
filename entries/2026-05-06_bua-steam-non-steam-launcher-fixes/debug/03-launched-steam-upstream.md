# 03 — Launched Steam Big Picture (Upstream Script, No Patch)

## Date: 2026-05-07

## Context

First launch of Steam Big Picture from ES. Running the **upstream** `create-steam-launchers.sh` (17930 bytes). No rsync of patched script yet.

## Observed Behavior

- Steam launched successfully in gamepadui (Big Picture) mode
- `create-steam-launchers.sh` IS running (PID 11967)
- Controller detected: Nintendo Pro Controller (event16)
- Steam running inside RunImage/bwrap container (dwarfs mount at `/tmp/.mount_steamremp*`)
- `es_launch_stderr.log` clean (only `evmapy: no process found`, harmless)

## Process Tree (key processes)

```
emulatorlauncher -system steam -rom Steam_Big_Picture.sh
  └── /bin/bash Steam_Big_Picture.sh
       └── /bin/bash Launcher -gamepadui
            ├── create-steam-launchers.sh (PID 11967, running/looping)
            ├── lbfix.sh
            └── steam -gamepadui (RunImage binary)
                 └── dwarfs (FUSE mount, cachesize=1536M)
                      └── bwrap (container, HOME=/root = /userdata/system/add-ons/steam)
                           └── steam -srt-logger-opened -gamepadui (PID 12406, 100% CPU = loading)
                                └── steam -child-update-ui
```

## Filesystem State

- `steamapps/common/` does NOT exist yet (no Proton, no SLR_4)
- No `non-steam-games/` directory
- No shortcut launchers in `/userdata/roms/steam/` (only `Steam_Big_Picture.sh`)
- No `shortcuts.vdf` (user hasn't added any non-Steam games)
- No `steamgriddb.key`

## Notes

- Steam is actively loading (PID 12406 at 100% CPU = initial UI startup)
- The bwrap container maps `/userdata/system/add-ons/steam` as `HOME=/root`
- PipeWire socket bound into container at `/run/user/0/pipewire-0`
- PulseAudio socket bound at `/run/user/0/pulse`
- This confirms audio routing infrastructure IS available inside the container

## Next Step

User will log in, install Proton Experimental, add non-Steam games, then we rsync the patched script.
