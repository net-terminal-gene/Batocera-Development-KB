# Debug — Non-Steam Games via Auto-Scraper

## Verification

```bash
# Check if shortcuts.vdf exists on the Batocera system
find /userdata/system/add-ons/steam/.local/share/Steam/userdata -name "shortcuts.vdf" 2>/dev/null

# Verify the auto-scraper is running (should be in background while Steam is open)
ps aux | grep create-steam-launchers

# Check if non-Steam launchers were generated
ls -la /userdata/roms/steam/*_*.sh | grep -v "^[0-9]*_"  # shortcut IDs are large numbers

# Verify gamelist entries for non-Steam games
grep "Non-Steam\|non-steam\|NonSteam" /userdata/roms/steam/gamelist.xml

# Check compatdata prefix exists for a shortcut ID
ls /userdata/system/add-ons/steam/.local/share/Steam/steamapps/compatdata/
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Non-Steam game not appearing in ES | `shortcuts.vdf` not found, or game not added in Steam yet |
| Game appears but launch does nothing | `compatdata/` prefix missing — user must launch once from Big Picture first |
| Game launches but no controller | Steam Deck SDL mapping not set; check `SDL_GAMECONTROLLERCONFIG` in launcher |
| "proton: command not found" | Proton not installed — user must install a Proton version in Steam |
| Wrong shortcut ID / prefix mismatch | Shortcut ID changed (re-added game) — delete old launcher, re-scan |
