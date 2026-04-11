# Change 01: create-steam-launchers2.sh — Non-Steam Games via Proton Direct Launch

## Status: DEPLOYED TO REMOTE BATOCERA

## File

**Path:** `batocera-unofficial-addons/steam/extra/create-steam-launchers2.sh`

## What Was Changed

1. **ROMS_ROOT detection** — Pin Steam files to `/userdata/.roms_base` when mergerfs is used (matches mergerfs code-changes).
2. **STEAM_DIR, PROTON_NAME** — Added variables for Steam addon path and default Proton.
3. **Non-Steam shortcuts loop** — After the appmanifest loop, scan `shortcuts.vdf` and generate `.sh` launchers using **Proton direct launch** (bypasses Steam).

## Why Proton Direct Launch

Steam's `steam://rungameid/` and `-applaunch` do not work for non-Steam shortcut IDs (see [FAILURES.md](../debug/FAILURES.md)). The game never starts; Big Picture opens and the launcher blocks. Proton direct launch runs the exe via `proton run` with `STEAM_COMPAT_DATA_PATH` and `STEAM_COMPAT_CLIENT_INSTALL_PATH`, bypassing Steam entirely.

## Non-Steam Launcher Template

```bash
export STEAM_COMPAT_DATA_PATH="${STEAM_APPS}/compatdata/SHORTCUTID"
export STEAM_COMPAT_CLIENT_INSTALL_PATH
"$PROTON_PATH" run "$EXE_PATH" &
wait $PROTON_PID
pkill -f steam ...
```

## shortcuts.vdf Parser

Inline Python (stdlib only, no vdf module) parses the binary format:
- Finds `\x02appid\x00` then 4 bytes LE = shortcut ID
- Finds `\x01AppName\x00`, `\x01Exe\x00`, `StartDir\x00` for name, exe path, start dir
- Resolves `/root/` to Steam addon dir

## Output

- `SHORTCUTID_GameName.sh` — Proton launcher
- `.sh.keys` — padtokey (hotkey+start → pkill steam)
- `gamelist.xml` entry

## Validation

- Shortcut ID from `shortcuts.vdf` must match compatdata folder. Compatdata is created when the game is first launched from Big Picture. If shortcut ID changes (e.g. re-add game), compatdata folder name may differ.
