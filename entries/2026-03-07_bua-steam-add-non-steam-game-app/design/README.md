# Design — Add Non-Steam Game to ES App

## Architecture

### App Identity

- **ES location:** Steam system (alongside Steam Big Picture, installed games)
- **Filename:** `Add_Non-Steam_Games.sh` in `/userdata/roms/steam/`
- **gamelist entry:** `<game>` with name "Add Non-Steam Games" and a custom image
- **Installed by:** `steam2.sh` (BUA Steam installer) — same way `Steam_Big_Picture.sh` is added
- **Trigger:** User selects "Add Non-Steam Games" from the ES Steam list and launches it

### User Experience Flow (Target UX)

**Cancel = exit to ES at every step. OK = proceed.**

```
1. OPEN APP
   User launches Add Non-Steam Games from ES > Steam.

2. INITIAL SCREEN
   ┌─────────────────────────────────────────────┐
   │         Add Non-Steam Games                 │
   │                                             │
   │  [Message / placeholder]                    │
   │                                             │
   │              [ Cancel ]                     │  ← Cancel available immediately. No OK yet.
   └─────────────────────────────────────────────┘

3. SCAN RESULTS
   App scans non-steam-games/ and lists directories with .exe files.
   ┌─────────────────────────────────────────────┐
   │         Add Non-Steam Games                 │
   │                                             │
   │  Found directories with .exe files:       │
   │    • Infinos2                               │
   │    • TestTwoExes                             │
   │                                             │
   │         [ Cancel ]  [ OK ]                   │  ← OK appears here. Proceed or Cancel→ES.
   └─────────────────────────────────────────────┘

4. EXE PICKER (per directory)
   For EACH directory, show which .exe to use. Even if only 1 exe.
   ┌─────────────────────────────────────────────┐
   │         Add Non-Steam Games                 │
   │                                             │
   │  Infinos2 — choose .exe:                    │
   │    ○ KeyConfig.exe                          │
   │    ● infinos_2.EXE                          │
   │                                             │
   │         [ Cancel ]  [ OK ]                   │  ← Cancel→ES. OK→next directory.
   └─────────────────────────────────────────────┘
   Repeat for TestTwoExes, etc.

5. FINAL CONFIRMATION
   ┌─────────────────────────────────────────────┐
   │         Add Non-Steam Games                 │
   │                                             │
   │  Add these games to your ES Steam library?  │
   │    • Infinos2 (infinos_2.EXE)               │
   │    • TestTwoExes (Game.exe)                 │
   │                                             │
   │         [ Cancel ]  [ OK ]                   │  ← Cancel→ES. OK→add games, update gamelist,
   └─────────────────────────────────────────────┘    automatically return to ES.
```

**Implementation gap:** yad + evmapy does not reliably deliver controller input to dialogs (ES keeps focus). Pygame-based UI (like BUA) or xdotool focus fix required for Cancel/OK to work.

### Why No Steam Interaction

Proton direct launch requires only:
- `STEAM_COMPAT_DATA_PATH` → points to compatdata prefix
- `STEAM_COMPAT_CLIENT_INSTALL_PATH` → Steam install path
- `proton run game.exe` → runs the game

Steam's `shortcuts.vdf`, `config.vdf`, `CompatToolMapping` are all unnecessary. Validated in `2026-03-06_bua-steam-non-steam-game-launchers`.

### Directory Layout

```
/userdata/system/add-ons/steam/
├── non-steam-games/              ← USER PUTS GAMES HERE
│   ├── MalditaCastilla/
│   │   └── Maldita Castilla.exe
│   ├── AnotherGame/
│   │   └── Game.exe
│   │   └── data/
│   └── ...
├── .local/share/Steam/
│   └── steamapps/
│       ├── common/
│       │   ├── Proton - Experimental/proton
│       │   └── Proton 10.0/proton
│       └── compatdata/
│           ├── <shortcut_id>/    ← CREATED ON FIRST LAUNCH
│           │   └── pfx/         ← Wine prefix
│           └── ...
└── ...

/userdata/roms/steam/             ← GENERATED FILES
├── Add_Non-Steam_Games.sh        ← THIS APP (installed by steam2.sh)
├── Add_Non-Steam_Games.sh.keys   ← padtokey (hotkey+start to exit app)
├── <shortcut_id>_GameName.sh     ← generated game launchers
├── <shortcut_id>_GameName.sh.keys
├── images/
│   ├── add-non-steam-games.jpg   ← app image
│   ├── add-non-steam-games-marquee.png
│   └── add-non-steam-games-thumb.png
└── gamelist.xml
```

### Launcher: xterm Wrapper (Controller/Keyboard)

When launched from ES, a plain `bash script.sh` may not receive keyboard or controller input. Batocera-CRT-Script's mode_switcher uses an xterm wrapper:

```bash
DISPLAY=:0.0 xterm -fs 15 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0 /path/to/script.sh"
```

This gives the script a proper terminal/display context so `dialog` receives input. Add Non-Steam Games uses the same pattern.

### dialog Usage

Batocera ships `dialog` v1.3 at `/usr/bin/dialog`. Existing BUA apps use it for `--msgbox`, `--menu`, `--yesno`.

This app uses:
- `dialog --infobox` — scanning message (no button, auto-dismisses)
- `dialog --msgbox` — detected games list (user sees what will be processed)
- **Exe auto-pick** (no dialog) — when folder has multiple `.exe` files: exclude KeyConfig/Setup/etc., prefer name match
- `dialog --gauge` — progress bar during processing
- `dialog --msgbox` — completion summary with results

### Proton Auto-Detection

```
1. List steamapps/common/Proton*/proton
2. Extract version numbers (e.g. "10.0", "9.0", "Experimental")
3. Sort: versioned numerically descending
4. Pick newest versioned; fall back to Experimental if none
```

### Shortcut ID Generation

Stable hash so re-running produces the same ID:

```
ID = CRC32(exe_absolute_path) | 0x80000000
```

High bit set to stay in non-Steam ID range (>2B), matching Steam's convention.

### Launcher Template (Proton Direct, Prefix-on-First-Launch)

```bash
#!/bin/bash
export DISPLAY=:0.0
export RIM_ALLOW_ROOT=1
export HOME=/userdata/system/add-ons/steam
ulimit -H -n 819200 && ulimit -S -n 819200

STEAM_DIR="/userdata/system/add-ons/steam"
STEAM_APPS="${STEAM_DIR}/.local/share/Steam/steamapps"
COMPAT_DATA="${STEAM_APPS}/compatdata/SHORTCUTID"
export STEAM_COMPAT_DATA_PATH="$COMPAT_DATA"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="${STEAM_DIR}/.local/share/Steam"
PROTON_PATH="${STEAM_APPS}/common/PROTON_NAME/proton"

# Create prefix on first launch
if [ ! -d "$COMPAT_DATA/pfx" ]; then
  mkdir -p "$COMPAT_DATA"
  "$PROTON_PATH" run wineboot -u
fi

cd "START_DIR" || exit 1
"$PROTON_PATH" run "EXE_PATH" &
PID=$!
wait $PID

pkill -f steam 2>/dev/null || true
pkill -f proton 2>/dev/null || true
```

### Installation (steam2.sh integration)

`steam2.sh` already creates `Steam_Big_Picture.sh` and adds it to gamelist.xml. The same pattern adds this app:

1. Download `add-non-steam-game.sh` to `/userdata/system/add-ons/steam/extra/` (the actual logic)
2. Create `/userdata/roms/steam/Add_Non-Steam_Games.sh` (xterm wrapper that runs the logic script — same pattern as Batocera-CRT-Script mode_switcher, ensures keyboard and controller work with dialog)
3. Create `.keys` file for hotkey exit
4. Add `<game>` entry to gamelist.xml
5. Download app icon to `/userdata/roms/steam/images/`
