# Fightcade Flatpak — HD Video Settings Reference

## Agent/Model Scope

Claude Opus (Cursor) + `ssh-batocera.sh` for on-device evidence. Steam Deck HD (labwc/Wayland) is the primary target; CRT switchres path noted for contrast.

## Problem

Two intertwined goals:

1. **Reference:** Document exactly what the Fightcade Flatpak does to make its four bundled Windows emulators (snes9x, FBNeo, ggpofba, flycast) render correctly on HD / LCD / Steam Deck displays, and why each setting exists.
2. **Bug:** SNES (snes9x) controller remaps made in Test Mode did not persist. In-session they worked; after SELECT+Start back to lobby and re-entering the game, the controller reverted to keyboard defaults.

## Root Cause

`hd/patch-hd-video.sh` forced `[Config] Lock = TRUE` in the snes9x config. snes9x documents this key in its own `fcadesnes9x.default.conf`:

> `Lock = FALSE  # if true, prevents Snes9x from editing this configuration file (or making it read-only while it is running)`

With `Lock = TRUE`, snes9x never writes the config on exit, so any in-session remap is discarded and the next launch re-reads the locked file (keyboard defaults `Joypad1:A=V`, `Start=Space`, ...).

The active config snes9x reads is a symlink into the writable app-data dir:
`.../emulator/snes9x/fcadesnes9x.conf -> /var/data/config/snes9x/fcadesnes9x.conf`
(= `data/.var/app/com.fightcade.Fightcade/data/config/snes9x/fcadesnes9x.conf`), which is the same file the installer patches.

## Solution

1. Stop forcing `Lock = TRUE`. Set `Lock = FALSE` in `hd/patch-hd-video.sh` (also repairs older installs) and in the shipped preset `hd/presets/fcadesnes9x.conf`.
2. Trim `patch-hd-video.sh` to only the panel-specific values, since the preset files already ship every other correct setting (aspect, vsync, windowed-menu-off, arcade-res-off, window position). Kept: resolution + fullscreen + vsync per emulator; plus the `Lock=FALSE` repair for snes9x. `ggpofba` patch unchanged (it has no preset).

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera-fightcade-flatpak | `hd/patch-hd-video.sh` | `Lock` forced FALSE not TRUE; trimmed fbneo (15→5 seds) and snes9x (11→5 seds) to panel-specific values only |
| batocera-fightcade-flatpak | `hd/presets/fcadesnes9x.conf` | `[Config] Lock` TRUE → FALSE (with explanatory comment) |

## Validation

- [x] Root cause confirmed via `default.conf` comment + live config inspection (SSH)
- [x] CRT switchres path confirmed independent of `Lock` (uses `.bak.switchres`/`.bak.menu` cp+restore)
- [x] `bash -n hd/patch-hd-video.sh` passes
- [x] Live device `data/config/snes9x/fcadesnes9x.conf` set to `Lock=FALSE`
- [ ] Hardware end-to-end: remap SNES controller in Test Mode → SELECT+Start → re-enter → bindings persist (requires physical controller input)
- [ ] Fresh reinstall on Deck + PC from branch to confirm HD defaults still apply after trim
