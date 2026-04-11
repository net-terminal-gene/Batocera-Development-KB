# Design — BUA Steam Non-Steam Game Launchers

## Architecture

### Current System: Two Parallel Launcher Formats

The live system uses **two formats** side by side:

**`.steam` files (upstream Batocera format):**
```
ES scans /userdata/roms/steam/ for .steam files (per es_systems.cfg)
    ↓
Each .steam file contains: steam://rungameid/APPID
    ↓
ES passes .steam file to emulatorlauncher (configgen)
    ↓
configgen reads the URL, launches Steam with the game
```

**`.sh` files (BUA format via batocera.conf override):**
```
create-steam-launchers.sh runs in background loop (every 5s)
    ↓
Scans steamapps/appmanifest_*.acf for installed games
    ↓
Creates /userdata/roms/steam/APPID_Name.sh + .sh.keys + gamelist.xml entry
    ↓
batocera.conf: steam.emulator=sh, steam.core=sh → overrides ES to use .sh
    ↓
User selects game → .sh runs directly (steam -gamepadui -silent -applaunch APPID)
```

### Non-Steam Game Flow (current — broken)

```
User adds non-Steam game in Steam ("Add a Non-Steam Game")
    ↓
Steam writes entry to shortcuts.vdf (binary, not appmanifest)
    ↓
create-steam-launchers.sh only scans appmanifest_*.acf → skips it
    ↓
No .sh or .steam file created → ES never sees the game
    ↓
Game is ONLY accessible inside Steam Big Picture Mode
```

### Proposed: Non-Steam Games via `.steam` Files

The simplest path — `.steam` files already use `steam://rungameid/` URLs:

```
User adds non-Steam game in Steam
    ↓
Steam creates/updates shortcuts.vdf
    ↓
Script (new or extended create-steam-launchers.sh):
  1. Reads shortcuts.vdf (binary VDF)
  2. For each entry: extracts AppName + appid (shortcut ID)
  3. Creates: /userdata/roms/steam/GameName.steam
     containing: steam://rungameid/SHORTCUTID
    ↓
ES discovers .steam file (matches es_systems.cfg extension)
    ↓
emulatorlauncher handles the steam:// URL → Steam launches the game
```

### Alternative: Non-Steam Games via `.sh` Files

If `.steam` doesn't work with the `sh` emulator override:

```
Script creates: /userdata/roms/steam/SHORTCUTID_GameName.sh
    ↓
Uses same template as real games but with steam://rungameid/SHORTCUTID
    ↓
.sh runs directly due to steam.emulator=sh override
```

## Key Components (from live system)

| Component | Location | Role |
|-----------|----------|------|
| `Launcher` | `/userdata/system/add-ons/steam/Launcher` | Main entry: sets env, starts create-steam-launchers.sh, launches Steam, monitors via wmctrl |
| `create-steam-launchers.sh` | `/userdata/system/add-ons/steam/create-steam-launchers.sh` | Background loop: scans appmanifest ACFs, creates .sh + .sh.keys + gamelist.xml |
| `lbfix.sh` | `/userdata/system/add-ons/steam/lbfix.sh` | Lib fix script (started by Launcher) |
| `appmanifest_*.acf` | `/userdata/system/add-ons/steam/.local/share/Steam/steamapps/` | Per-game metadata for real Steam games |
| `shortcuts.vdf` | `/userdata/system/add-ons/steam/.local/share/Steam/config/shortcuts.vdf` | Binary file for non-Steam games (does not exist until user adds one) |
| `es_systems.cfg` | `/usr/share/emulationstation/es_systems.cfg` | Defines `.steam` as the accepted extension |
| `batocera.conf` | `/userdata/system/batocera.conf` | `steam.emulator=sh` / `steam.core=sh` override |

## shortcuts.vdf Format

[Inference] Binary VDF (Valve Data Format). Structure per entry:

| Field | Type | Description |
|-------|------|-------------|
| `appid` | uint32 | Shortcut ID (locally generated, high bits set) |
| `AppName` | null-terminated string | Display name |
| `Exe` | null-terminated string | Path to executable (quoted) |
| `StartDir` | null-terminated string | Working directory |
| `icon` | null-terminated string | Path to icon (optional) |
| `LaunchOptions` | null-terminated string | Command-line args |
| `IsHidden` | uint32 | 0 or 1 |
| `AllowDesktopConfig` | uint32 | 0 or 1 |
| `AllowOverlay` | uint32 | 0 or 1 |
| `tags` | sub-object | Category tags |

## Live Test Findings (2026-03-06 / 2026-03-07)

### shortcuts.vdf

- **Path:** `Steam/userdata/<STEAM_USER_ID>/config/shortcuts.vdf` (per-user)
- **Parsing:** Binary VDF; `xxd` used to extract shortcut ID (3755861458) from hex

### Visibility

- **`.steam` file:** Does NOT appear in ES when `steam.emulator=sh` is set
- **`.sh` file:** DOES appear in ES

### Launch

- **steam://rungameid/3755861458:** Steam receives; Big Picture opens; game does not launch
- **-applaunch 3755861458:** Same result
- **Launcher blocking:** `wait $STEAM_PID` never returns because Steam process tree stays alive; user must `pkill -f steam` to return to ES

### Steam File Browser Path Quirk

Steam's "Add a Non-Steam Game" dialog uses `HOME=/userdata/system/add-ons/steam`. Cannot browse to `/userdata` from root. Symlinks show as files (47 bytes), not folders. Must copy game directory into Steam's HOME.

## Open Questions (Updated After Live Test)

1. ~~`shortcuts.vdf` not yet present~~ — Resolved
2. **Why doesn't the game launch?** — Both `steam://rungameid/` and `-applaunch` are received; Big Picture opens; exe does not start. Path? Proton? Shortcut ID handling?
3. **`.steam` vs `.sh`** — Resolved: only `.sh` works with current override
4. **Launcher exit condition** — Need alternative to `wait $STEAM_PID` (e.g. wait for game process, or don't wait)
5. **Can `shortcuts.vdf` be parsed in bash?** — `xxd` works for manual extraction; automation may need Python vdf
