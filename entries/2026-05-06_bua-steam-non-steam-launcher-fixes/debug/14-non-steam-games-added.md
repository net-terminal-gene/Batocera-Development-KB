# 14 — Non-Steam Games Added, Exited to ES

## Date: 2026-05-07

## Context

User added both games as non-Steam shortcuts in Steam Desktop mode, then exited Steam back to ES.

## Result: Launchers Generated Successfully

The generator detected both shortcuts within 5 seconds:

```
Shortcut[1]: appid=3955098073 name='eXceed2nd-VR.exe' search='eXceed 2nd Vampire REX'
  exe='/root/non-steam-games/eXceed 2nd Vampire REX/game/eXceed2nd-VR.exe'
  startdir='/root/non-steam-games/eXceed 2nd Vampire REX/game/'

Shortcut[2]: appid=2902144888 name='eXceed3rd-BR.exe' search='eXceed 3rd Jade Penetrate Black Package'
  exe='/root/non-steam-games/eXceed 3rd Jade Penetrate Black Package/game/eXceed3rd-BR.exe'
  startdir='/root/non-steam-games/eXceed 3rd Jade Penetrate Black Package/game/'
```

## Generated Files

```
/userdata/roms/steam/shortcut_3955098073_eXceed_2nd_Vampire_REX.sh
/userdata/roms/steam/shortcut_3955098073_eXceed_2nd_Vampire_REX.sh.keys
/userdata/roms/steam/shortcut_2902144888_eXceed_3rd_Jade_Penetrate_Black_Package.sh
/userdata/roms/steam/shortcut_2902144888_eXceed_3rd_Jade_Penetrate_Black_Package.sh.keys
```

## Launcher Content Verified

- SLR_ENTRY and PROTON_PATH correctly set
- Pre-flight checks for SLR/Proton existence (with error messages)
- All env vars present: STEAM_COMPAT_DATA_PATH, STEAM_COMPAT_APP_ID, SteamAppId, SteamGameId, PULSE_SERVER, PROTON_NO_STEAM_OVERLAY, WINEDLLOVERRIDES
- Wine prefix init via SLR
- Game launch via `"$SLR_ENTRY" --verb=run -- "$PROTON_PATH" run EXE`
- Launch logging to `/userdata/system/logs/non-steam-launch.log`
- SLR exists: YES, Proton exists: YES (at generation time)

## Gamelist Updated

Both games added to gamelist.xml with correct paths. Also shows Proton Experimental and SLR 4.0 as official Steam "games" (from manifests).

## Search Term Logic Working

The generator correctly derived search terms from the `non-steam-games/` directory:
- `eXceed 2nd Vampire REX` (from folder name, not exe name)
- `eXceed 3rd Jade Penetrate Black Package` (from folder name, not exe name)

## No Artwork Downloaded

SGDB artwork was NOT fetched because the `steamgriddb.key` file was added AFTER the script started. The key is read once at startup, not per-loop. Artwork will download on next Steam launch (when script restarts).

## Next Step

Update gamelist in ES (or restart ES), then launch one of the games to test the SLR+Proton chain.
