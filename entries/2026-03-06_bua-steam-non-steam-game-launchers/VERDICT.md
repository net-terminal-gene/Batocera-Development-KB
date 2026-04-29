# VERDICT — BUA Steam Non-Steam Game Launchers

## Status: VERIFIED WORKING

## Result

Non-Steam games (added via "Add a Non-Steam Game" in Steam) can now be launched from EmulationStation without entering Big Picture Mode. The fix uses **Proton direct launch** — running the game exe via `proton run` with the correct compat env vars — bypassing Steam's CLI entirely.

## What Failed

Steam's own CLI mechanisms do not work for non-Steam shortcut IDs:

- `steam -applaunch SHORTCUTID` — Steam receives it; Big Picture opens; game never starts
- `steam steam://rungameid/SHORTCUTID` — Same result
- `xdg-open steam://rungameid/SHORTCUTID` — Same result
- Signed / negative shortcut IDs — Same result

See [debug/FAILURES.md](debug/FAILURES.md) for the full log of 9 failed approaches.

## What Works

**Proton direct launch:**

```bash
export STEAM_COMPAT_DATA_PATH="$STEAM_APPS/compatdata/SHORTCUTID"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM_DIR/.local/share/Steam"
export STEAM_COMPAT_APP_ID=SHORTCUTID
"$STEAM_APPS/common/Proton - Experimental/proton" run "/path/to/game.exe"
```

The game runs under Proton with the same prefix Steam created when the user first ran it from Big Picture. No Steam client process is needed.

## Key Discovery: Shortcut ID vs AppID

The `appid` field in `shortcuts.vdf` (read via `\x02appid\x00` + 4 bytes LE) does **not** match what we originally extracted from the hex dump. Initial manual extraction produced 3755861458; the Python parser correctly returned 3755550162 — which matches the actual `compatdata/` folder. The parser output is the one to use.

## Changes Applied

| File | Change |
|------|--------|
| `batocera-unofficial-addons/steam/extra/create-steam-launchers2.sh` | ROMS_ROOT detection + non-Steam shortcuts.vdf scan + Proton launcher generation |
| Remote: `create-steam-launchers.sh` | Same changes deployed live |
| Remote: `3755550162_Maldita_Castilla.sh` | Proton direct launcher for test game |
| Remote: `*.sh.keys` | Padtokey: hotkey+start → `pkill -f steam; pkill -f proton` |

## Prerequisites for Non-Steam Games

1. Game must be added to Steam via "Add a Non-Steam Game" (creates `shortcuts.vdf` entry)
2. Proton version must be set in game properties (Big Picture → Properties → Compatibility)
3. Game must be launched once from Big Picture to create the `compatdata/` prefix
4. `create-steam-launchers.sh` must run to generate the `.sh` launcher (happens automatically in background loop)

## Known Issues

- **waveOut audio error** — Some games using old Windows audio API show "device already in use". Fix: switch to DirectSound in game settings, or dismiss the dialog.
- **Proton version hardcoded** — Launcher defaults to "Proton - Experimental". If user has a different Proton version, launcher needs manual edit.
- **No game image in ES** — Non-Steam games have no Steam CDN header image. Placeholder or manual image needed.

## Root Causes (Original Problem)

1. `create-steam-launchers.sh` only reads `appmanifest_*.acf` files (real Steam games)
2. Non-Steam games are stored in `shortcuts.vdf` (binary format) with synthetic shortcut IDs
3. Steam CLI (`-applaunch`, `steam://rungameid/`) does not launch non-Steam shortcuts from command line
