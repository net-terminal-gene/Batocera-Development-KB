# Design — Non-Steam Games via Auto-Scraper

## Architecture

No new components. The existing `create-steam-launchers2.sh` loop gains a second scan phase.

```
┌─────────────────────────────────────────────────┐
│           create-steam-launchers2.sh            │
│                (5-second loop)                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  Phase 1: appmanifest_*.acf scan (existing)     │
│  ─────────────────────────────────────────────  │
│  • Read appid, name, installdir from ACF        │
│  • Generate .sh launcher (steam -applaunch)     │
│  • Download header image from Steam CDN         │
│  • Add gamelist.xml entry                       │
│                                                 │
│  Phase 2: shortcuts.vdf scan (new)              │
│  ─────────────────────────────────────────────  │
│  • Find shortcuts.vdf in userdata/*/config/     │
│  • Parse binary with inline Python              │
│  • Extract shortcut ID, AppName, Exe, StartDir  │
│  • Resolve /root/ → Steam addon dir (bwrap)     │
│  • Generate .sh launcher (proton run direct)    │
│  • Generate .keys (hotkey+start exit)           │
│  • Add gamelist.xml entry                       │
│                                                 │
└─────────────────────────────────────────────────┘
```

## Key difference: launcher type

| | Real Steam games (Phase 1) | Non-Steam games (Phase 2) |
|---|---|---|
| Launch method | `steam -gamepadui -silent -applaunch APPID` | `proton run /path/to/game.exe` |
| Requires Steam running | Yes | No |
| ID source | `appmanifest_*.acf` | `shortcuts.vdf` (binary) |
| Image | Steam CDN header | None (placeholder if available) |
| Exit handler | `pkill -f steam` | `pkill -f steam; pkill -f proton` |

## Prerequisites for non-Steam games

The user must have:
1. Added the game in Steam's UI ("Add a Non-Steam Game")
2. Set Proton compatibility in game properties
3. Launched the game once from Big Picture (creates `compatdata/` prefix)

Step 3 is required because the Proton direct launcher reuses the existing prefix — it does not create one. (The standalone app from `2026-03-07` session does create prefixes via `proton run wineboot -u`, but that approach is not used here.)
