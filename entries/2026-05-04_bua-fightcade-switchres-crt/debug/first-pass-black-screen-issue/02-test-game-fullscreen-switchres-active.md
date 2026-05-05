# 02 — TEST GAME: fullscreen, Switchres path active

**Date:** 2026-05-04  
**Host:** Batocera CRT (`batocera.local`) after remote deploy of `switchres_fightcade_wrap.sh` + Ports `Fightcade.sh` patch  
**Purpose:** Confirm wrapper + `xdg-open` chain in real use.

## Steps (user)

1. Fully exit Fightcade, launch again from Ports (refresh `~/bin/xdg-open` from updated port script).  
2. Join SFIII room.  
3. **TEST GAME**.

## Result

- Game **went to fullscreen automatically** (no manual toggle needed).  
- **Inference:** `fightcade_should_use_switchres` passed, `switchres … -s -k` + Wine ini patch + `fcade.sh` path is functioning for this title.

## Optional hard proof (next session)

While still in game, from SSH:

```bash
export DISPLAY=:0.0
xrandr | grep -E 'current|SR-|384x224'
```

Expect `current` or mode line matching the ROM (e.g. 384×224) or an `SR-` name.

## Notes

- Deploy on device: `/userdata/system/add-ons/fightcade/extra/switchres_fightcade_wrap.sh`, `bin/xdg-open` → wrapper, `/userdata/roms/ports/Fightcade.sh` heredoc points at wrapper so restarts do not revert.
