# 09 — First Launch (lbfix Crash, Expected)

## Date: 2026-05-07

## Context

First launch of Steam Big Picture from ES with the patched (instrumented) script deployed.

## Result: Same as before — lbfix.sh crashed Steam

- Generator started successfully (PID 14804)
- Logging working: 6 clean loop iterations in 25 seconds
- No `FATAL` or errors in `create-steam-launchers.log`
- `lbfix.sh` replaced libcurl symlink, crashed Steam
- Launcher detected window close, killed generator, exited to ES
- Zombie processes remain: `[steam] <defunct>` (PID 17063)

## Log Output (clean)

```
[2026-05-08 06:09:18] === Script started (PID 14804) ===
[2026-05-08 06:09:18] STEAM_APPS=...steamapps
[2026-05-08 06:09:18] STEAM_USERDATA=...userdata
[2026-05-08 06:09:18] SGDB_KEY_FILE=...steamgriddb.key (exists: no)
[2026-05-08 06:09:18] SGDB_API_KEY set: no
[2026-05-08 06:09:18] --- Loop iteration 1 ---
[2026-05-08 06:09:18]   Manifests processed: 0
[2026-05-08 06:09:18]   shortcuts.vdf files found: 0
[2026-05-08 06:09:18]   Shortcuts processed: 0 | New launchers created: false
[2026-05-08 06:09:18] --- Loop 1 complete ---
... (loops 2-6 identical, clean) ...
[2026-05-08 06:09:43] --- Loop 6 complete ---
```

## Confirmed

- Patched script runs without errors
- Logging is functional and capturing all expected data
- `set -e` did NOT kill the script (no FATAL trap fired)
- lbfix crash is the only issue (known, first-launch-only)

## Next Step

Relaunch Steam from ES. lbfix.sh is gone (self-deleted), so Steam should stay up.
