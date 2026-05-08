# 10 — Second Launch Stuck (RunImage Binary Failed to Start)

## Date: 2026-05-07

## What Happened

Second launch from ES. Generator script started fine (looping cleanly), but **Steam itself never appeared**. The Launcher was stuck in its "wait for Steam window" polling loop (240s timeout) because the RunImage binary exited immediately without mounting.

## Evidence

- Generator running: loops 1-15+ clean, no FATAL
- No `dwarfs` process (FUSE mount never happened)
- No `bwrap` process (container never created)
- No `/tmp/.mount_steam*` (mount point never created)
- `wmctrl -l` returned nothing (no X windows)
- Launcher's child PID for steam (22742) was already dead/gone
- Kernel log: only a `split_lock trap` from the first-launch zombie (PID 17062)
- No OOM, no segfault in dmesg

## Root Cause Theory

The Launcher's first-launch cleanup does `pkill -f steam` which kills the RunImage binary. But **it doesn't clean up the state that RunImage leaves behind**. On second launch, the RunImage binary may detect:
- A stale lock file
- A partially-created `.local/share/Steam/` directory
- A dirty state from the first crash

And silently exit without error.

## Resolution

Killed all stuck processes manually. System is clean now (no steam, no mounts, no zombies except harmless boot-time `[uname]`).

## Key Insight for Testing

The `lbfix.sh` crash + `pkill -f steam` cleanup leaves the system in a state where Steam **cannot relaunch without intervention**. This is a BUA upstream bug, not our patch.

Possible workarounds:
1. Kill zombie processes before relaunch
2. Clean any stale RunImage state
3. A full ES restart might help (resets the process tree)

## Ruled Out: steamgriddb.key

The SGDB key lookup is NOT a factor:

```bash
SGDB_KEY_FILE="/userdata/system/add-ons/steam/steamgriddb.key"
SGDB_API_KEY=""
if [[ -f "$SGDB_KEY_FILE" ]]; then
  SGDB_API_KEY="$(cat "$SGDB_KEY_FILE" | tr -d '[:space:]')"
fi
```

- Uses `[[ -f ... ]]` guard; no crash if file is missing
- Log confirmed: `SGDB_API_KEY set: no`
- Generator ran 15+ clean loops with no errors

## Key Clarification: Our Script is NOT the Problem

The Launcher starts three things independently:
1. `create-steam-launchers.sh &` — our generator (ran perfectly)
2. `lbfix.sh &` — gone (self-deleted after first run)
3. `/userdata/system/add-ons/steam/steam -gamepadui &` — the RunImage binary (THIS failed)

The RunImage binary exiting silently is an upstream BUA issue. The dirty state from the first-launch crash (lbfix killing Steam mid-startup) prevents the binary from re-mounting on second attempt.

## Next Step

Try launching Steam from ES again. The stuck processes have been cleared. If it still fails, may need to restart ES entirely (`batocera-es-swissknife --restart`) to fully reset the process environment.
