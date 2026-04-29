# 01 — App Is Stuck

Add Non-Steam Games launched from ES but appears stuck. Captured via `~/bin/ssh-batocera.sh`.

## Current State (at capture)

| Check | Result |
|-------|--------|
| add-non-steam-game processes | **None** (not running) |
| xterm processes | **None** |
| dialog processes | **None** |
| Steam launchers count | 53 (unchanged from 00-Pre-Add-Non-Steam) |
| non-steam-games/ | Infinos2, TestTwoExes, Infinos 2.wsquashfs (unchanged) |
| New non-Steam launchers | **None** (no CRC32-style IDs) |

## Interpretation

App is **not currently running**. Either:
1. It exited (crash or user killed it)
2. It was stuck when user reported, then exited before capture
3. It never fully started

## Likely Stuck Points

1. **Exe picker (dialog --menu)** — Script shows a menu for Infinos2 (KeyConfig.exe vs infinos_2.EXE) and TestTwoExes (Game.exe vs Launcher.exe). If controller/keyboard input isn't reaching the xterm, user is stuck at first picker with no way to select.

2. **xterm/DISPLAY** — If DISPLAY=:0.0 isn't valid or xterm can't open, script may hang or fail silently.

3. **First dialog (scanning)** — Unlikely; that's an infobox that auto-dismisses after sleep 1.

## Recommended Checks

```bash
# Verify xterm and dialog work headless
DISPLAY=:0.0 timeout 2 xterm -e echo ok

# Run script with debug (will need display)
DISPLAY=:0.0 bash -x /userdata/system/add-ons/steam/extra/add-non-steam-game.sh 2>&1 | head -50
```

## Fix Applied

**Fix 1:** Replaced interactive `dialog --menu` exe picker with **auto-pick heuristic**.

**Fix 2:** Replaced all blocking `dialog --msgbox` with `dialog --infobox` + sleep. Controller input was not reaching xterm; the "Found N games, Press OK to continue" and "Complete!" msgboxes were blocking. Now fully non-interactive.
