# Debug — BUA Steam: SteamGridDB Artwork Fallback

## Verification

```bash
# Check if artwork was downloaded for a shortcut
ls /userdata/roms/steam/images/

# Test SGDB API directly for a game
curl -sf -H "Authorization: Bearer $(cat /userdata/system/add-ons/steam/steamgriddb.key)" \
  "https://www.steamgriddb.com/api/v2/grids/game/1911?limit=1"

# Check gamelist for image tag
grep -A2 'eXceed' /userdata/roms/steam/gamelist.xml
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| No artwork in ES for non-Steam game | SGDB has no 460x215 image; fallback not implemented |
| Game name shows as folder name (e.g. "GAME") | StartDir basename is generic; user needs meaningful folder name |
| Launcher not created | shortcuts.vdf not written yet (Steam needs restart/close) |
| Old broken launcher keeps returning | Old shortcut still in shortcuts.vdf; must remove from Steam |
