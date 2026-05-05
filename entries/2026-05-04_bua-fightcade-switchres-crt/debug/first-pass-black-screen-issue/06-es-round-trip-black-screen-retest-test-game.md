# 06 — Black screen on Test Game after EmulationStation round-trip

**Date:** 2026-05-04  
**Status:** OPEN — needs SSH capture on repro

## Symptom

- **Works:** Launch Fightcade from Ports → TEST GAME → exit emulator → launch TEST GAME again **without** leaving Fightcade (repeat inside the same Fightcade session).
- **Fails:** Exit Fightcade back to **EmulationStation** → launch Fightcade from Ports again → **TEST GAME** → **black screen**. Recovery so far: **SSH** (e.g. `fightcade_display_recover.sh`, `xrandr`, or reboot).

## Repro (reported)

1. From ES: open Fightcade → TEST GAME → exit game (returns to Fightcade room). Repeat in-room if desired (works).
2. Quit Fightcade → return to ES.
3. Start Fightcade from Ports again.
4. TEST GAME → black raster; forced recovery via SSH.

## Hypotheses (not ranked)

1. **Second cold launch** uses a different **DISPLAY / X seat** or **HOME** path than the long-lived in-session path; wrapper `fightcade_pick_display` or env might not match what Electron/Wine expect on the second Ports launch.
2. **PRE_MODE / PRE_RES** snapshot at wrapper entry might differ after ES has run **batocera-resolution** or compositor refresh, so Switchres or restore timing interacts badly on the *first* game of the new session only.
3. **Wine / Fightcade process litter** (stuck `wineserver`, zombie `fcadefbneo`) after ES transition; first `fcade://` dispatch in the new session races Switchres.
4. **Electron / fc2-electron** second instance: window stack or GPU buffer not ready until extra delay (similar class to launch black fixed by **sleep 4** after `switchres -k`, but only on second app open).
5. **Switchres / modeline state** left in an edge state when Fightcade was closed from ES versus closed from room only (needs `xrandr` and `batocera-resolution currentMode` before and after step 3).

## Next capture (when reproducing)

Run over SSH **before** clicking TEST GAME on the **failing** second launch, and once on the **working** in-session relaunch for contrast:

```bash
export DISPLAY=:0.0   # or :1.0 if only X1 exists — check /tmp/.X11-unix/
batocera-resolution getDisplayMode
batocera-resolution currentMode
batocera-resolution currentResolution
xrandr | head -20
pgrep -af 'fcade|wine|fcadefbneo|electron|Fightcade' || true
```

After black (still SSH-able): same commands plus `xrandr | grep current`.

## Related

- Launch black mitigated by **~4s sleep** after `switchres … -k` before `fcade.sh` (see `design/README.md`).
- Do **not** use `/etc/init.d/S31emulationstation restart` from SSH (can spawn **:1** and break **:0**); see `fightcade_display_recover.sh` comment.
