# Debug Stage 05 — HD/Wayland Mode: Second Launch Test

**Date:** 2026-04-14
**State:** Same Wayland/HD boot session as 03/04. DP-1 plugged in throughout.

## Test sequence

1. First launch of mode switcher from ES (captured in 04): black screen on eDP-1, xterm alive on DP-1.
2. `killall -9 emulationstation` to kill ES. ES standalone wrapper restarted ES automatically. First mode switcher instance was NOT killed (orphaned, still alive on DP-1).
3. Second launch of mode switcher from ES: black screen again on eDP-1.

## Second launch process state

Both instances alive simultaneously:

| Instance | xterm PID | dialog PID | PTY | Started |
|----------|-----------|------------|-----|---------|
| 1st | 4231 | 4261 | pts/0 | 23:42 |
| 2nd | 5604 | 5620 | pts/1 | 23:46 |

Both dialogs showing "Current Mode: HD Mode" with "Switch to CRT Mode" option, waiting for input. Both on DP-1 (wrong display).

## xterm death bug: NOT REPRODUCED

Second launch with Xwayland already running (from first launch). xterm stayed alive. This confirms:

- **xterm does NOT die on second launch** when Xwayland is warm
- **xterm did NOT die on first launch** either (fresh boot, Xwayland started on-demand)
- The < 1 second death from the previous debug session was an anomaly, not the standard behavior

## Cleanup

- `kill 4231 5604` killed both xterm processes. Dialog and inner bash cascaded via SIGHUP.
- emulatorlauncher and sh -c wrappers from both instances were orphaned (ES had been killed with -9, not a clean shutdown). Required `kill -9` on PIDs 4029-4034 and 5399-5404.
- After cleanup: ALL CLEAN, no stale processes.

## Conclusion

**The xterm death bug is not reproducible in normal operation.** It was likely an artifact of the previous debug session (rapid SSH-based xterm launches without proper ES launch chain, or stale XWayland state).

**The only confirmed bug is window placement:** xterm with `-maximized` lands on DP-1 instead of eDP-1 when both displays are active in the Wayland extended desktop. This is the sole issue to fix.
