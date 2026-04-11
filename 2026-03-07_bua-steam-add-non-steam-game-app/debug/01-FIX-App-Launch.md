# 01 — FIX: App Launch (Nothing Showing)

## Problem

Add Non-Steam Games launched from ES > Steam but nothing appeared — no terminal, no window. App appeared to hang; user had to kill it.

## Root Cause

1. **xterm + dialog required a terminal** — `dialog` (ncurses) needs a TTY. When launched from emulatorlauncher, there was no terminal.
2. **xterm couldn't connect to X** — emulatorlauncher sets `HOME=/userdata/system/add-ons/steam` for Steam; xterm looks for `$HOME/.Xauthority` to authenticate with the X server. That path doesn't exist, so xterm failed to connect and never opened a window.
3. **Even with `HOME=/root`** — xterm still failed (possibly quoting issues in the launcher or other env problems).

## Solution That Worked

**Replace dialog with yad** — yad uses GTK dialogs, no terminal required. Works when launched directly from emulatorlauncher.

**Run script directly, no xterm** — Launcher invokes the script directly instead of wrapping it in xterm.

## Changes Applied

| File | Change |
|------|--------|
| `add-non-steam-game.sh` | Replaced all `dialog` calls with `yad` (--info, --progress --pulsate). Added `export DISPLAY` and `export HOME` at top. |
| `Add_Non-Steam_Games.sh` (launcher) | Runs `/userdata/system/add-ons/steam/extra/add-non-steam-game.sh` directly. Sets `HOME=/root` and `DISPLAY=:0.0`. No xterm. |
| `steam2.sh` | Updated launcher heredoc to match. |
| `deploy-add-non-steam-games.sh` | Updated launcher heredoc to match. |

## Launcher (Final)

```bash
#!/bin/bash
# Run directly — script uses yad (GTK), no terminal needed
export HOME=/root
export DISPLAY=:0.0
/userdata/system/add-ons/steam/extra/add-non-steam-game.sh
```

## Verification

- Launch Add Non-Steam Games from ES > Steam
- GTK windows appear (scanning, processing, complete)
- No terminal required; yad works with DISPLAY=:0.0
