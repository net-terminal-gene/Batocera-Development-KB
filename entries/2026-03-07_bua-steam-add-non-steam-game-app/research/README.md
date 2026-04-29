# Research — Add Non-Steam Game to ES App

## Findings

### From Prior Session (2026-03-06_bua-steam-non-steam-game-launchers)

- **Steam CLI does not work for non-Steam shortcuts** — `steam://rungameid/`, `-applaunch` both fail. 9 attempts documented in `../2026-03-06_bua-steam-non-steam-game-launchers/debug/FAILURES.md`.
- **Proton direct launch works** — `proton run exe` with `STEAM_COMPAT_DATA_PATH` + `STEAM_COMPAT_CLIENT_INSTALL_PATH`. Verified working 2026-03-07.
- **No Steam interaction needed** — `shortcuts.vdf`, `config.vdf`, `CompatToolMapping` are all unnecessary for Proton direct launch.
- **ES visibility** — Only `.sh` files appear when `steam.emulator=sh` in `batocera.conf`. `.steam` files are ignored.

### Live System State (2026-03-07)

#### Proton Versions Installed

| Proton | Path | `proton` binary |
|--------|------|----------------|
| Proton - Experimental | `steamapps/common/Proton - Experimental/proton` | 92KB, present |
| Proton 10.0 | `steamapps/common/Proton 10.0/proton` | 88KB, present |

#### CompatToolMapping (config.vdf)

Only one entry — the manually-added non-Steam game:

```
"CompatToolMapping"
{
    "3755550162"
    {
        "name"  "proton_experimental"
    }
}
```

Real Steam games do not appear here (they use Steam's default compat handling). This confirms `CompatToolMapping` is only needed for Steam's own shortcut system, not for Proton direct launch.

#### compatdata Prefix Structure

```
compatdata/3755550162/
├── config_info      ← Proton version info
├── pfx/             ← Wine prefix (C: drive)
├── pfx.lock
├── tracked_files
└── version
```

`config_info` first line: `10.1000-200` (Proton version stamp).

#### Prefix Creation

`proton run wineboot -u` creates the prefix. This is what Steam does internally when a game runs under Proton for the first time. It initializes the Wine prefix (registry, C: drive structure, DLL overrides).

### mergerfs Considerations

- `/userdata/system/add-ons/steam/` is on the internal drive (not mergerfs-managed)
- `/userdata/roms/steam/` is under mergerfs — use `.roms_base` detection (already in `add-non-steam-game.sh`, `create-steam-launchers2.sh`)
- Non-steam game files in `non-steam-games/` are safe from mergerfs scattering

### BATO-PARROT wsquashfs → non-steam-games

Games in `/userdata/roms/windows/*.wsquashfs` can be extracted for Add Non-Steam Games:

```bash
# Example: Infinos 2
rm -rf /userdata/system/add-ons/steam/non-steam-games/Infinos2
cp "/userdata/roms/windows/Infinos 2.wsquashfs" /userdata/system/add-ons/steam/non-steam-games/
cd /userdata/system/add-ons/steam/non-steam-games
find . -maxdepth 1 -name "Infinos 2*" -exec unsquashfs -f -d Infinos2 {} \;
```

Result: `Infinos2/` with KeyConfig.exe + infinos_2.EXE — exe picker lets user choose main game.

### Why mode_switcher (CRT) Works — Adopt Same Behavior for Steam

**crt-launcher.sh** only does videomode sync for dual-boot CRT systems, then `exec emulatorlauncher "$@"`. Both CRT and Steam use the same emulatorlauncher; the difference is `-system crt` vs `-system steam`.

**Controller input** comes from evmapy, which merges keys from:
1. Per-rom: `{rom}.keys` (e.g. `mode_switcher.sh.keys`, `Add_Non-Steam_Games.sh.keys`)
2. System: `steam.keys` or `crt.keys` (in EVMAPY or /usr/share/evmapy)
3. Emulator: `sh.keys`
4. hotkeys.keys

**mode_switcher** works because CRT Script provides `mode_switcher.sh.keys` with d-pad → KEY_UP/DOWN/LEFT/RIGHT, start/b → KEY_ENTER, a/select → KEY_ESC. evmapy injects these into the focused window (xterm/dialog).

**Add Non-Steam Games** must provide the same mappings in `Add_Non-Steam_Games.sh.keys` so controller input works when launched from ES > Steam — without requiring CRT Tools. The app stays in Steam only.

### Why Steam Deck Controller Works in Official Steam Games but Not Non-Steam (Proton Direct)

**Official Steam games**: Launched via `steam -applaunch <appid>`. Steam runs, **Steam Input** runs. Steam Input creates a virtual Xbox controller that the game receives. The game always sees a standard Xbox controller. Works.

**Non-Steam (Proton direct)**: Launched via `proton run exe`. We bypass Steam entirely. No Steam Input. The game sees raw input devices. Two factors:

1. **evmapy** grabs the controller (for Hotkey+Start). evmapy creates a virtual device and passes through unmapped input. The game may pick the wrong device (grabbed physical vs evmapy virtual) or SDL may not recognize evmapy's device as a gamepad.
2. **SDL / Steam Deck**: [SDL issue #14410](https://github.com/libsdl-org/SDL/issues/14410), [#11579](https://github.com/libsdl-org/SDL/issues/11579) — older Proton/Wine + SDL can filter out Steam Deck input. Proton Experimental has fixes. `SDL_GAMECONTROLLERCONFIG` may be ignored when Steam Input is disabled.

**Steam CLI does not work for non-Steam shortcuts** (see FAILURES.md) — so we cannot launch through Steam to get Steam Input.

**Things to try**: Proton Experimental, SDL_GAMECONTROLLERCONFIG in launcher, evmapy pass-through investigation.

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

