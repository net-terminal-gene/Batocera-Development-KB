# 03 — Exit emulator: display not restored to ES/menu resolution after windowed play

**Date:** 2026-05-04  
**Host:** Batocera CRT, Fightcade + SFIII TEST GAME, deployed Switchres wrapper  

## What happened

1. TEST GAME running with Switchres path (fullscreen into native arcade timing).  
2. User **double-clicked the mouse** to leave fullscreen (**windowed** mode).  
3. User chose **`Game > Exit emulator`** from the menu.  
4. **Bug:** Fightcade UI did **not** return to the **same native resolution** as when Fightcade was first launched (ES/menu CRT mode, e.g. 641×480-style timing expected).

## Expected (design)

Wrapper saves `PRE_MODE=$(batocera-resolution currentMode)` before `switchres … -s -k`, waits on emulator PIDs, then **`batocera-resolution setMode "$PRE_MODE"`** after exit.

## Hypotheses (for follow-up)

1. **Restore ran against wrong or empty `PRE_MODE`** (e.g. capture failure over SSH session variance).  
2. **`wait_for_emulators` exited early** while `fcade`/Wine still held the desktop, or exited late after something else changed mode.  
3. **Windowed toggle** altered Wine/X11 state so **`setMode`** did not visually match pre-launch.  
4. **Fightcade Electron UI** stayed up at the switched resolution; restore applies to X mode but ES “feel” differs until another mode change.

## Next captures (when reproducing)

SSH **after** exit to Fightcade room, paste:

```bash
export DISPLAY=:0.0
batocera-resolution currentMode
batocera-resolution currentResolution
xrandr | grep -E 'current|DP-|SR-|641|384'
```

Compare to values saved at Fightcade cold launch (menu baseline).

## Status

**FIX APPLIED (retest needed)** — wrapper updated:

1. **`PRE_MODE` captured before** Wine ini patch or `switchres` (true menu baseline).  
2. **3 s settle** after emulator processes disappear before restore.  
3. **`batocera-resolution setMode` retried** up to 8 times (1 s apart) after Wine/windowed teardown.

Deployed on device: regenerate `switchres_fightcade_wrap.sh` from template on `batocera.local`.

Re-run: exit Fightcade → launch → TEST GAME → double-click windowed → **Exit emulator** → confirm UI timing matches launch.
