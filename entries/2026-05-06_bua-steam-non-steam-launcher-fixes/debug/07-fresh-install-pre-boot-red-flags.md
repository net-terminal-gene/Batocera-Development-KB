# 07 — Fresh Install Pre-Boot: Patched Script Red Flags

## Date: 2026-05-07

## Context

Reviewing `steam/extra/create-steam-launchers2.sh` (the file we rsync as `create-steam-launchers.sh` on device) for red flags before the clean test run.

## RED FLAGS

### 1. `set -e` at line 2 will KILL the script on any non-zero exit

```bash
set -e
```

This is the **most dangerous line in the script**. The script runs in a continuous `while true` loop. With `set -e`:
- If `curl` fails (network blip, SGDB timeout) -> script dies
- If `python3` parsing fails -> script dies
- If `grep` finds no match (exit code 1) -> script dies
- If any subshell or pipeline returns non-zero -> script dies

The script has some `|| continue` and `|| true` guards, but not everywhere. For example:
- Line 66: `grep -m1 '"appid"' "$manifest"` — if manifest is malformed, grep returns 1, script dies
- Line 231: `python3 -c "..." "$term" 2>/dev/null) || return 1` — the `return 1` from `sgdb_search` inside the process substitution could cascade
- Line 456: `find "$STEAM_USERDATA" -name 'shortcuts.vdf'` — if STEAM_USERDATA doesn't exist, find returns 1

**Impact:** If the script dies, no new launchers get generated for the rest of the Steam session. User would need to restart Steam to get it running again.

**Previous test sessions:** The stdout log showed `Using Proton: Proton - Experimental` every 5 seconds, confirming the upstream script survived its loop. But the upstream also has `set -e` and includes `detect_proton()` which accesses paths that may not exist. The fact it survived suggests the guards are sufficient for the upstream flow. But **our changes introduce new failure points** (SLR path checks, SGDB cascading).

### 2. Non-Steam launcher `cd` will fail if StartDir doesn't exist (line 410)

```bash
cd "${local_start_dir}" || exit 1
```

This is in the **generated launcher** (the .sh file the user runs from ES). If the game's StartDir path doesn't exist on disk, the launcher exits immediately with no error message to the user.

**Impact:** Silent failure. User launches game from ES, it immediately returns to ES with no feedback.

### 3. SLR/Proton paths are hardcoded with no existence check (lines 392-393)

```bash
SLR_ENTRY="${STEAM_APPS}/common/SteamLinuxRuntime_4/_v2-entry-point"
PROTON_PATH="${STEAM_APPS}/common/Proton - Experimental/proton"
```

In the generated launcher, if Proton Experimental or SLR_4 aren't installed, the `"$SLR_ENTRY" --verb=run --` call will fail. With the generated script being a standalone bash script (no `set -e`), it would print an error but the user would just see the game fail to start.

**Impact:** Expected behavior per plan.md ("launchers generated unconditionally, fail if Proton missing"). But no user-friendly error message.

### 4. `PULSE_SERVER` path may be wrong inside bwrap container (line 400)

```bash
export PULSE_SERVER="unix:/var/run/pulse/native"
```

From the bwrap args we captured earlier, PulseAudio socket is bound to `/run/user/0/pulse` inside the container, NOT `/var/run/pulse/native`. However, the generated non-Steam launcher runs **outside** the bwrap container (directly on the host filesystem), so `/var/run/pulse/native` is the correct host path.

Wait — actually re-reading the launcher: it calls `"$SLR_ENTRY" --verb=run --` which IS the SteamLinuxRuntime container entry point. So the game runs INSIDE SLR's own container. SLR should handle audio routing internally.

**Verdict:** Probably fine. SLR has its own PipeWire/PulseAudio forwarding. The `PULSE_SERVER` env var may be redundant (SLR sets it up) but shouldn't hurt.

### 5. `pkill -f proton` in cleanup may be too aggressive (line 415)

```bash
pkill -f proton 2>/dev/null || true
pkill -f wineserver 2>/dev/null || true
```

`pkill -f proton` matches any process with "proton" in its command line. If multiple non-Steam games were somehow running (unlikely in ES), this would kill all of them. Also matches processes like "proton-bridge" (email client) if one existed.

**Impact:** Low risk in practice on a Batocera system. No other proton-related processes should exist.

### 6. The `while IFS='|' read` loop reads from process substitution that runs ONCE per loop iteration (lines 279-517)

Every 5 seconds, the script:
1. Iterates all `appmanifest_*.acf` files (official Steam games)
2. Then runs the full Python VDF parser on ALL `shortcuts.vdf` files

The Python parser re-reads and re-parses the binary VDF file every 5 seconds. This is fine for small files but could add latency with many shortcuts.

**Impact:** Negligible. shortcuts.vdf is typically small (a few KB even with dozens of games).

### 7. NO `set -e` guard in the generated launcher scripts

The generated non-Steam launcher (lines 335-418) does NOT have `set -e`. This means if `wineboot -u` fails during prefix init, execution continues to try launching the game anyway. Could cause confusing errors.

**Impact:** Low. Worst case: game fails to start with a Wine error instead of a clean "prefix not initialized" message.

## VERDICT: Probably OK for Testing

The biggest real risk is **#1 (set -e killing the generator loop)**. But since the upstream script also uses `set -e` and survives, and our changes are mostly in the generated launcher template (which doesn't use set -e), it should be fine for a test run.

If the script dies unexpectedly during testing, `set -e` is the first thing to investigate.

## Rsync Command (for reference)

```bash
rsync -avz /Users/mikey/batocera-unofficial-addons/steam/extra/create-steam-launchers2.sh root@batocera.local:/userdata/system/add-ons/steam/create-steam-launchers.sh
```
