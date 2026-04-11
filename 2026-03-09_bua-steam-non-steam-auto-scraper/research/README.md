# Research — Non-Steam Games via Auto-Scraper

## Findings

### Production vs local branch

The production `create-steam-launchers2.sh` on main ([source](https://github.com/batocera-unofficial-addons/batocera-unofficial-addons/blob/main/steam/extra/create-steam-launchers2.sh)) has no `shortcuts.vdf` support. It only scans `appmanifest_*.acf`.

The local branch (`fix-fightcade-libcups`) already has the full non-Steam extension (lines 179-309) — developed and validated in `2026-03-06_bua-steam-non-steam-game-launchers`.

### Non-Steam shortcut IDs

- Stored as 32-bit unsigned int in `shortcuts.vdf` (binary, `\x02appid\x00` + 4 bytes LE)
- Not deterministic — Valve changed ID generation ([steam-for-linux#9463](https://github.com/ValveSoftware/steam-for-linux/issues/9463)), IDs can change when re-adding the same game
- The shortcut ID must match the `compatdata/` folder name for Proton direct launch to work

### Steam CLI does not launch non-Steam games

Exhaustively tested in `2026-03-06` session (9 failed approaches documented in `debug/FAILURES.md`):
- `steam -applaunch SHORTCUTID` — Big Picture opens, game never starts
- `steam://rungameid/SHORTCUTID` — same result
- Signed/unsigned variants, two-phase launch, xdg-open — all fail
- Reference: [ValveSoftware/steam-for-linux#9194](https://github.com/ValveSoftware/steam-for-linux/issues/9194)

### Proton direct launch (the working approach)

```bash
export STEAM_COMPAT_DATA_PATH="$STEAM_APPS/compatdata/SHORTCUTID"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM_DIR/.local/share/Steam"
export STEAM_COMPAT_APP_ID=SHORTCUTID
"$STEAM_APPS/common/Proton - Experimental/proton" run "/path/to/game.exe"
```

No Steam client needed. Game runs with existing prefix.

### BUA maintainer feedback

Maintainer suggested extending the auto-scraper rather than building a separate app. Key points:
- "All you're really telling it to do is look within another directory too"
- Can push live updates to the script (downloaded fresh when BUA opens)
- Asked whether non-Steam games use an app ID for CLI launch — answer is: they have one, but CLI launch doesn't work; Proton direct is required

### Standalone app assessment

The `add-non-steam-game.sh` app from `2026-03-07` eliminates all Steam UI interaction but:
- Has an unresolved Steam Deck controller bug
- Hasn't been tested with BUA's install flow
- Adds maintenance burden (separate script, artwork, gamelist entry, .keys file)
- The auto-scraper approach covers the common case with zero new user-facing components
