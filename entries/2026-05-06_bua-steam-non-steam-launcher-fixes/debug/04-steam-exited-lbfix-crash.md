# 04 — Steam Exited Unexpectedly (lbfix.sh Killed It)

## Date: 2026-05-07

## What Happened

Steam Big Picture launched, ran for ~36 seconds, then exited back to ES without user input.

## Root Cause: `lbfix.sh` libcurl replacement crashed Steam

The `Launcher` script runs `lbfix.sh` in the background. Here's what `lbfix.sh` does:

1. Waits for `pinned_libs_64/libcurl.so.4` symlink to appear
2. Detects it's a symlink
3. **Deletes it** (`rm -f`)
4. Downloads a replacement `libcurl.so.4` from GitHub
5. Self-deletes (`rm -- "$0"`)

The problem: replacing libcurl **while Steam is running** caused Steam to crash. The Launcher saw "Steam window closed" via `wmctrl` and cleaned up, returning to ES.

## Timeline (from es_launch_stdout.log)

```
05:40:43  Steam launched, launcher generator started (PID 11967)
05:40:43  lbfix.sh started, waiting for libcurl symlink
05:40:43-05:41:08  create-steam-launchers.sh scanning every 5s (no games found)
05:41:??  Steam window detected by Launcher (wmctrl found "Steam")
05:41:??  lbfix.sh found libcurl.so.4 symlink
05:41:??  [SYMLINK DETECTED] Replacing with CURL_OPENSSL_4 safe version...
05:41:??  [DONE] replacement complete (1164000 bytes)
05:41:??  Steam crashed (libcurl yanked from under it)
05:41:19  Launcher: "Steam window closed" -> kills launcher generator -> exits
05:41:19  emulatorlauncher: "Emulator terminated by signal (Terminated: 15)"
```

## Key Evidence

- `lbfix.sh` self-deleted after running (no longer on filesystem)
- Steam still has zombie processes: `[steam] <defunct>` (PIDs 14163, 15195)
- One Steam process still alive (PID 14162) but orphaned

## The `lbfix.sh` Script (from repo)

```bash
TARGET="...steam-runtime/pinned_libs_64/libcurl.so.4"
URL="https://github.com/.../steam/extra/libcurl.so.4"

# Wait for symlink to appear
while [[ ! -L "$TARGET" && ! -f "$TARGET" ]]; do sleep 2; done

if [[ -L "$TARGET" ]]; then
    rm -f "$TARGET"
    curl -L -o "$TARGET" "$URL"
fi

rm -- "$0"   # self-delete
```

## The `Launcher` Script Logic

1. Starts `create-steam-launchers.sh` in background
2. Starts `lbfix.sh` in background
3. Launches Steam RunImage binary
4. Waits for Steam window via `wmctrl -l | grep -qi "Steam"` (240s timeout)
5. Once found, polls every 2s until window disappears
6. On disappear: kills launcher generator, `pkill -f steam`, calls `curl http://127.0.0.1:1234/reloadgames`

## Questions

1. Is this a known issue with the upstream BUA Steam addon? (lbfix crashing Steam on first launch)
2. Does Steam survive on second launch? (libcurl already replaced, lbfix.sh already deleted)
3. Should we re-install BUA Steam addon to get `lbfix.sh` back, or just relaunch?

## Next Step

Try relaunching Steam from ES. Since `lbfix.sh` deleted itself and the real `libcurl.so.4` is now in place, it shouldn't interfere on second launch.
