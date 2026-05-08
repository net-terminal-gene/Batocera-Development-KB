# 00 — Fresh Install v43 Steam (Factory State)

## Date: 2026-05-07

## Context

Starting from a completely fresh Batocera v43 image (no BUA addon installed yet) to establish baseline behavior and test the non-Steam launcher fixes end-to-end as a new user would experience them.

## Factory State (`/userdata/roms/steam/`)

```
Steam.steam       ← native Steam launcher placeholder (built into Batocera)
_info.txt
gamelist.xml
images/
```

- `/userdata/system/add-ons/steam/` does NOT exist (no BUA addon)
- Batocera v43 ships with a basic Steam entry in ES natively

## Key Findings

1. **Proton Experimental and SteamLinuxRuntime_4 are NOT present on a fresh install.** They only appear after the user manually installs Proton Experimental from Steam's Library (SLR_4 comes as an automatic dependency).

2. **`steam://install/<APPID>` does NOT work** as an auto-install mechanism on Batocera. The RunImage container spawns a new Steam instance which conflicts with the running one, pops dialog boxes, and crashes with "An error occurred while installing AppId 3513920."

3. **The `create-steam-launchers.sh` script must NOT gate on Proton/SLR existence.** If it skips non-Steam launcher generation when deps are missing, the user has no way to discover the issue. Instead, launchers should be generated unconditionally; they will simply fail to launch games until Proton is installed.

## Decision

- Removed all `ensure_proton_deps` logic from `create-steam-launchers2.sh`
- User must manually install Proton Experimental from Steam Library (one-time setup)
- This is acceptable because users already need to enter Steam Desktop mode to add non-Steam games, and can install Proton from the same Library view

## Test Flow (what a new user does)

1. Install BUA Steam addon from BUA UI
2. Launch Steam Big Picture from ES
3. Switch to Desktop mode
4. Install Proton Experimental from Library (free)
5. Add non-Steam games as shortcuts
6. Exit Steam, relaunch from ES
7. `create-steam-launchers.sh` generates launchers on next cycle
8. Update gamelist in ES - games appear
