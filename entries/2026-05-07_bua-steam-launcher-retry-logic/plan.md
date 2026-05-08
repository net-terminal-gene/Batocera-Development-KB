# BUA Steam: Launcher Retry Logic

## Agent/Model Scope

Opus 4.6 High + ssh-batocera for on-device testing

## Problem

The BUA Steam Launcher (`steam/extra/Launcher2`) fails to keep Steam running on first boot due to a two-stage failure:

1. **First launch:** `lbfix.sh` replaces `libcurl.so.4` (symlink to real file) while Steam is running, crashing it. Launcher detects window gone, runs `pkill -f steam`, exits to ES.
2. **Second launch:** The RunImage binary silently refuses to start (no dwarfs mount, no bwrap container, no error). Launcher is stuck in 240s wmctrl timeout, eventually exits.
3. **Third launch:** After manually killing stuck processes, Steam finally works.

Users must launch Steam 2-3 times before it stays up. This is unacceptable UX.

## Root Cause

1. `lbfix.sh` runs in parallel with Steam startup. It waits for `pinned_libs_64/libcurl.so.4` to appear as a symlink, then `rm -f` + `curl` replaces it. This yanks a loaded library from under a running process.
2. The Launcher's cleanup (`pkill -f steam`) after the crash leaves RunImage in a dirty state (stale lock files, partial `.local/share/Steam/` directory) that prevents the binary from re-mounting on subsequent invocations.
3. The Launcher has no retry logic. If Steam fails to appear, it exits.

## Solution

Modify `Launcher2` to handle the lbfix scenario gracefully:

**Option A (preferred):** Run `lbfix.sh` synchronously, THEN launch Steam. Since lbfix needs Steam's `pinned_libs_64/` to exist first, restructure so:
1. Launch Steam briefly (just long enough for pinned_libs to appear)
2. Let lbfix do its thing
3. Kill and restart Steam cleanly

**Option B:** Add retry logic to the Launcher. If Steam window doesn't appear within N seconds, kill all steam/dwarfs processes, clean up, and retry (max 2 retries).

**Option C:** Move the lbfix logic inline into the Launcher itself (eliminate lbfix.sh entirely). Check if libcurl is a symlink before launching Steam; if so, replace it, then launch.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| batocera-unofficial-addons | `steam/extra/Launcher2` | Add retry logic or restructure lbfix execution order |
| batocera-unofficial-addons | `steam/extra/lbfix.sh` | Possibly eliminate or restructure |

## Validation

- [ ] First launch of Steam from ES succeeds without returning to ES
- [ ] lbfix.sh replacement still happens (libcurl.so.4 is a real file, not symlink, after first run)
- [ ] No zombie processes or stuck Launcher after successful boot
- [ ] Second+ launches still work normally (lbfix self-deleted)
- [ ] Generator script runs correctly alongside new Launcher logic
