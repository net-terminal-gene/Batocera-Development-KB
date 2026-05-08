# 04 — SteamGridDB Key Added, Games Unsquashed

## Date: 2026-05-07

## Context

Pre-launch setup complete. User added `steamgriddb.key`, both game archives unsquashed with bloat removed. Exe files intentionally left nested in `game/` subdirectory to test the new search term logic.

## State

### SteamGridDB Key
- `/userdata/system/add-ons/steam/steamgriddb.key` present (32 chars)

### Non-Steam Games (unsquashed, bloat removed)

```
non-steam-games/
├── eXceed 2nd Vampire REX/
│   └── game/              ← exe nested here (eXceed2nd-VR.exe)
├── eXceed 2nd Vampire REX.wsquashfs
├── eXceed 3rd Jade Penetrate Black Package/
│   └── game/              ← exe nested here
└── eXceed 3rd Jade Penetrate Black Package.wsquashfs
```

### What was removed (bloat)
- `dosdevices/`
- `drive_c/`
- `autorun.cmd`
- `system.reg`
- `user.reg`
- `userdef.reg`

## Test Points for Next Step

1. User launches Steam Big Picture from ES
2. Logs in, installs Proton Experimental from Library
3. Switches to Desktop mode
4. Adds both games as non-Steam shortcuts (pointing to exe inside `game/` subfolder)
5. Exits Steam, relaunches from ES
6. Verify: `create-steam-launchers.sh` generates launchers with correct search terms ("eXceed 2nd Vampire REX", "eXceed 3rd Jade Penetrate Black Package") despite nested exe
7. Verify: artwork downloads via dimension fallback
8. Verify: SLR+Proton Experimental launch chain in generated launchers
