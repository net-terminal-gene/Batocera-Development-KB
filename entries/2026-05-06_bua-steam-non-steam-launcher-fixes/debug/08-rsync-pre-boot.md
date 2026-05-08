# 08 — Rsync Pre-Boot (Patched Script Deployed)

## Date: 2026-05-07

## Context

Fresh Batocera v43 reflash. BUA + Steam addon installed. Patched `create-steam-launchers2.sh` rsynced BEFORE first Steam launch.

## What Was Rsynced

- **Local:** `/Users/mikey/batocera-unofficial-addons/steam/extra/create-steam-launchers2.sh`
- **Remote:** `/userdata/system/add-ons/steam/create-steam-launchers.sh`
- **Size:** 20783 bytes (was 17930 upstream; increase is logging instrumentation)
- **Permissions:** `-rwxr-xr-x`

## Logging Added (not in upstream, debug-only)

Two log files will be created during testing:

### 1. `/userdata/system/logs/create-steam-launchers.log`

The generator script's own log. Captures:
- Script start with PID, all config paths
- **ERR trap**: if `set -e` kills the script, logs the exact line number and command
- Each loop iteration with count
- Number of appmanifest files processed
- Each shortcut found from `shortcuts.vdf`: appid, name, search term, exe, startdir
- Resolved paths for generated launchers
- Whether SLR and Proton exist at generation time
- Loop completion summary (shortcuts processed, new launchers created)

### 2. `/userdata/system/logs/non-steam-launch.log`

Written by the generated launcher scripts when a non-Steam game is launched from ES. Captures:
- Game name, AppID, timestamp
- All resolved paths (SLR, Proton, compat data, exe, working dir)
- **Pre-flight check**: SLR exists? Proton exists? (exits with clear error if not)
- Wine prefix initialization (logged with exit code)
- Game PID and exit code after wait
- cd failure (with log message instead of silent exit)

## How to Read Logs After Testing

```bash
# Generator log (runs while Steam is open)
ssh-batocera "cat /userdata/system/logs/create-steam-launchers.log"

# Game launch log (written when launching from ES)
ssh-batocera "cat /userdata/system/logs/non-steam-launch.log"

# If script died (set -e), look for FATAL:
ssh-batocera "grep FATAL /userdata/system/logs/create-steam-launchers.log"
```

## Device State

- Fresh v43 reflash
- BUA Steam addon installed (upstream Launcher, lbfix.sh present)
- Patched script deployed (20783 bytes, with logging)
- `/userdata/system/logs/` directory created
- Steam has NOT been launched yet
- No `steamgriddb.key`, no `non-steam-games/`, no Proton/SLR

## What Will Happen on First Boot

1. User launches Steam Big Picture from ES
2. Launcher starts `create-steam-launchers.sh` (our patched version with logging)
3. Launcher starts `lbfix.sh` (will crash Steam on first try, as documented in step 04)
4. Second launch should succeed (lbfix self-deleted)
5. Generator logs to `/userdata/system/logs/create-steam-launchers.log`

## Expected First-Launch Behavior

- `lbfix.sh` WILL crash Steam on first launch (known, unavoidable without modifying lbfix)
- Second launch: Steam stays up, generator runs, logs accumulate
- User logs in, installs Proton Experimental, adds non-Steam games
- Generator picks up `shortcuts.vdf` entries within 5 seconds
- Launchers generated in `/userdata/roms/steam/`

## Next Step

Launch Steam from ES. Expect first-launch crash from lbfix. Relaunch immediately.
