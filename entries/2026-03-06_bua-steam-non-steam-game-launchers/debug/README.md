# Debug — BUA Steam Non-Steam Game Launchers

## Failure Log

**See [FAILURES.md](FAILURES.md)** — consolidated log of all failed launch attempts (steam://, -applaunch, two-phase, visibility, path, stuck state).

---

## Initial Inspection Results (2026-03-06)

| Check | Result |
|-------|--------|
| `shortcuts.vdf` exists? | **Yes** (after adding non-Steam game) — per-user path: `Steam/userdata/1080337349/config/shortcuts.vdf` |
| `.sh` launchers present? | Yes — 40+ games, format: `APPID_Name.sh` |
| `.steam` files present? | Yes — co-exist alongside `.sh` files, format: `steam://rungameid/APPID` |
| `.sh.keys` present? | Yes — padtokey JSON (hotkey+start → pkill steam) |
| `create-steam-launchers.sh`? | Present, 5039 bytes. Scans only `appmanifest_*.acf` |
| `Launcher`? | Present, 2214 bytes. Starts create-steam-launchers.sh in background |
| ES system extension? | `.steam` (from `es_systems.cfg`) |
| batocera.conf override? | `steam.emulator=sh`, `steam.core=sh` |
| `gamelist.xml`? | Present, 30KB. Entries for `.sh` files only |
| `_info.txt`? | Says: `ROM files extensions accepted: ".steam"` |

## Live Test Results (2026-03-06 / 2026-03-07)

### Test Game Setup

- **Game:** Maldita Castilla (from `Maldita Castilla.wsquashfs` in `/userdata/roms/windows/`)
- **Extraction:** `unsquashfs -d /userdata/system/non-steam-test/MalditaCastilla` — exe at `MalditaCastilla/Maldita Castilla.exe`
- **Steam add path:** Had to copy (not symlink) into `/userdata/system/add-ons/steam/MalditaCastilla` because Steam file browser couldn't navigate to `/userdata`; symlink showed as 47-byte file
- **Proton:** Proton Experimental set in Big Picture Mode properties

### shortcuts.vdf Parsing

- **Path:** `/userdata/system/add-ons/steam/.local/share/Steam/userdata/1080337349/config/shortcuts.vdf`
- **Shortcut ID:** 3755861458 (hex dump: `d2 25 d9 df` LE)
- **AppName:** Maldita Castilla.exe
- **Exe:** "/root/MalditaCastilla/Maldita Castilla.exe" (Steam's /root = steam addon dir)

### Visibility

| File | Content | ES shows? |
|------|---------|-----------|
| `Maldita Castilla.steam` | `steam://rungameid/3755861458` | No |
| `3755861458_Maldita_Castilla.sh` | bash launcher | Yes |

### Launch Behavior

- **steam://rungameid/3755861458:** Steam receives; Big Picture opens; game does not launch
- **-applaunch 3755861458:** Steam receives; Big Picture opens; game does not launch
- **Stuck state:** Launcher does `wait $STEAM_PID`; Steam process tree stays alive; ES blocks until `pkill -f steam`

### Process Tree (when stuck)

```
emulatorlauncher → mergerfs-pin-internal.sh → 3755861458_Maldita_Castilla.sh
  → steam -gamepadui -silent -applaunch 3755861458
    → dwarfs (mount) → bwrap → Run.sh → steam client + steamwebhelper
```

### Steam Console Log Evidence

```
[2026-03-07 09:14:52] Startup - Steam Client launched with: ... 'steam://rungameid/3755861458'
[2026-03-07 09:16:09] Startup - Steam Client launched with: ... '-applaunch' '3755861458'
```

### Kill Steam to Return to ES

```bash
pkill -f steam
```

### Test Launcher Script (3755861458_Maldita_Castilla.sh)

```bash
#!/bin/bash
export DISPLAY=:0.0
export XAUTHORITY=/var/run/xauth
export RIM_ALLOW_ROOT=1
export HOME=/userdata/system/add-ons/steam
ulimit -H -n 819200 && ulimit -S -n 819200
#------------------------------------------------
# Non-Steam Game Launcher
# Game: Maldita Castilla
# ShortcutID: 3755861458

STEAM_DIR="/userdata/system/add-ons/steam"
STEAM_LAUNCHER="${STEAM_DIR}/steam"

cd "$STEAM_DIR" || exit 1

# Try -applaunch (matches real game launcher format)
"$STEAM_LAUNCHER" -gamepadui -silent -applaunch 3755861458 &
STEAM_PID=$!

wait $STEAM_PID

pkill -f steam 2>/dev/null || true
pkill -f steamwebhelper 2>/dev/null || true
#------------------------------------------------
```

**Transfer method:** Base64 encode locally, SSH: `echo $B64 | base64 -d > /userdata/roms/steam/3755861458_Maldita_Castilla.sh` (avoids expect heredoc $ mangling)

## Verification Commands

```bash
# Check if shortcuts.vdf exists (re-check after adding non-Steam game)
ls -la /userdata/system/add-ons/steam/.local/share/Steam/config/shortcuts.vdf

# Dump readable strings from shortcuts.vdf
strings /userdata/system/add-ons/steam/.local/share/Steam/config/shortcuts.vdf

# List all files in steam roms (both .sh and .steam)
ls -la /userdata/roms/steam/

# Read a .steam file
cat /userdata/roms/steam/Balatro.steam

# Read a .sh launcher
cat /userdata/roms/steam/2379780_Balatro.sh

# Test steam:// protocol launch from CLI with non-Steam shortcut ID
/userdata/system/add-ons/steam/steam steam://rungameid/SHORTCUTID

# Reload ES game list after adding a manual .steam file
curl http://127.0.0.1:1234/reloadgames

# Check Python availability
which python3 && python3 --version

# Check if Python vdf module is available
python3 -c "import vdf; print('vdf available')" 2>&1

# Check what emulator ES uses for .steam files
grep -A 5 'steam' /userdata/system/batocera.conf | head -10

# Hex dump shortcuts.vdf (when it exists)
xxd /userdata/system/add-ons/steam/.local/share/Steam/config/shortcuts.vdf | head -100
```

## Next Steps (requires non-Steam game to be added)

1. Add a non-Steam game in Steam (via Big Picture → desktop mode → Add a Non-Steam Game)
2. Set Proton version for the game in Big Picture Mode properties
3. Re-check `shortcuts.vdf` — should now exist
4. Extract shortcut ID from `shortcuts.vdf` using `strings` or hex dump
5. Create a test `.steam` file: `echo "steam://rungameid/SHORTCUTID" > /userdata/roms/steam/TestGame.steam`
6. Reload ES: `curl http://127.0.0.1:1234/reloadgames`
7. Check if TestGame appears in ES Steam list
8. Try launching it

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| `shortcuts.vdf` does not exist | No non-Steam games added, or Steam hasn't been run after adding one |
| `strings` output empty or no game names | File may be empty or corrupted; re-add a non-Steam game and restart Steam |
| `.steam` file not appearing in ES | May need `curl http://127.0.0.1:1234/reloadgames` or ES restart. Also check if `steam.emulator=sh` override prevents `.steam` discovery |
| `steam://rungameid/ID` does nothing | Wrong shortcut ID, Steam not running, or protocol not supported in CLI mode |
| `steam://rungameid/ID` launches wrong game | Shortcut ID incorrect; verify against `shortcuts.vdf` raw data |
| Game launches but crashes immediately | Proton version not set; must be configured in Big Picture Mode first |
| `.steam` file ignored while `.sh` files work | `steam.emulator=sh` override may redirect ES to only process `.sh` files |
