# Debug — Add Non-Steam Game to ES App

## Entries

| File | Context |
|------|---------|
| [00-Pre-Add-Non-Steam.md](00-Pre-Add-Non-Steam.md) | Baseline state before running Add Non-Steam Games |
| [01-App-Is-Stuck.md](01-App-Is-Stuck.md) | App launched but stuck; no processes running at capture |
| [01-FIX-App-Launch.md](01-FIX-App-Launch.md) | Fix: yad instead of dialog, no xterm — app now shows GTK windows |
| [02-App-Launch-Stuck-On-Progress-Bar.md](02-App-Launch-Stuck-On-Progress-Bar.md) | Fix: Replace piped yad --progress with pulsate-in-background to avoid blocking |
| [03-Remove-Add-Non-Steam-Games-Entries.md](03-Remove-Add-Non-Steam-Games-Entries.md) | How to remove Add Non-Steam Games entries from ES > Steam (for another agent) |
| [04-OK-Button-Focus-Fix.md](04-OK-Button-Focus-Fix.md) | yad/evmapy focus unreliable; auto-pick workaround; target UX in design/UX-FLOW.md |
| [05-SSH-Log-Investigation.md](05-SSH-Log-Investigation.md) | SSH log inspection: es_launch_*, game_START_and_STOP, emulatorlauncher flow; Cancel exit flow completes but ES return unconfirmed |
| [06-Xrandr-Fix-No-Effect.md](06-Xrandr-Fix-No-Effect.md) | xrandr no effect; BUA/Mode Switcher fail; SNES works → sh vs libretro path in emulatorlauncher |
| [07-Exit-Non-Steam-Game-Hotkey-Start.md](07-Exit-Non-Steam-Game-Hotkey-Start.md) | Why Hotkey+Start may not exit; fallback SSH command; hardened .keys target |
| [08-Controller-Order-Evmapy-P1.md](08-Controller-Order-Evmapy-P1.md) | evmapy only listens to P1; Hotkey+Start must be on P1; Steam Deck disappearing after kill |

## Verification

```bash
# Check non-steam-games directory exists
ls -la /userdata/system/add-ons/steam/non-steam-games/

# Check game exe is accessible (Infinos2 has KeyConfig.exe + infinos_2.EXE for exe picker test)
ls -la /userdata/system/add-ons/steam/non-steam-games/*/

# Verify launcher runs script directly (no xterm)
cat /userdata/roms/steam/Add_Non-Steam_Games.sh

# Check Proton versions
ls /userdata/system/add-ons/steam/.local/share/Steam/steamapps/common/ | grep -i proton

# Check generated launchers
ls -la /userdata/roms/steam/*_*.sh

# Check compatdata prefix created
ls -la /userdata/system/add-ons/steam/.local/share/Steam/steamapps/compatdata/

# Check gamelist has entry
grep -A3 'non-steam' /userdata/roms/steam/gamelist.xml

# Check .keys file exists
ls -la /userdata/roms/steam/*_*.sh.keys

# Test prefix creation manually
STEAM_COMPAT_DATA_PATH=/tmp/test-prefix \
STEAM_COMPAT_CLIENT_INSTALL_PATH=/userdata/system/add-ons/steam/.local/share/Steam \
'/userdata/system/add-ons/steam/.local/share/Steam/steamapps/common/Proton - Experimental/proton' run wineboot -u
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| No `.sh` file generated | Script didn't find `.exe` in subdirectory |
| Game not in ES | gamelist.xml not updated, or ES not reloaded |
| "No such file" on launch | Launcher path doesn't match gamelist path |
| Proton error on first launch | `wineboot -u` failed; check disk space, Proton binary |
| Game launches then crashes | Proton compatibility issue with that specific game |
| Audio error (waveOut) | Game uses old Windows audio API; dismiss or switch to DirectSound |
| Can't exit game | `.keys` file missing or wrong path |
| Exe picker doesn't show | Folder has only one `.exe`; use Infinos2 (KeyConfig.exe + infinos_2.EXE) to test |
| Launcher fails silently | Check launcher has `HOME=/root` and `DISPLAY=:0.0`; script uses yad (no xterm) |
| Progress bar stuck | Use pulsate-in-background, not piped yad --progress |
| OK button doesn't respond | yad window lacks focus; use xdotool windowactivate (see 04-OK-Button-Focus-Fix.md) |

## Remove Non-Steam Games (Start Over)

See **[03-Remove-Add-Non-Steam-Games-Entries.md](03-Remove-Add-Non-Steam-Games-Entries.md)** for full instructions (designed for another agent/model).

## Restore ES When Screen Is Black or Controllers Don't Work

If Hotkey+Start didn't exit a game, or controllers are unresponsive after killing ES:

```bash
~/bin/ssh-batocera.sh "/userdata/system/add-ons/steam/extra/force-exit-non-steam-game.sh"
```

Uses ordered kills (evmapy first) + udev trigger to avoid Steam Deck disappearing. See [07](07-Exit-Non-Steam-Game-Hotkey-Start.md), [08](08-Controller-Order-Evmapy-P1.md).

## Deploy Workflow

Manual deploy without BUA Steam reinstall:

```bash
cd batocera-unofficial-addons/steam/extra
./deploy-add-non-steam-games.sh [batocera.local|IP]
```

Requires scp/ssh access (password or key). Uses `~/bin/ssh-batocera.sh` for verification.

**mergerfs:** Deploy script writes to `/userdata/roms/steam/`. If `.roms_base` exists, gamelist edits may need to target `/userdata/.roms_base/steam/gamelist.xml` to avoid overwriting the merged gamelist.
