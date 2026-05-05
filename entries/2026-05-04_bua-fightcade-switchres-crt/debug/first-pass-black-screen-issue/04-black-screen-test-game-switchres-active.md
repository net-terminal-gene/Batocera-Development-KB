# 04 — TEST GAME: black screen (Switchres mode active, FBNeo running)

**Date:** 2026-05-04  
**Symptom:** User ran TEST GAME; **black screen** on CRT.

## SSH snapshot (game running / stuck black)

| Check | Result |
|-------|--------|
| `xrandr` Screen line | `current 384 x 224` |
| Switchres log (fightcade.log) | Mode `384x224@59.599491`, duplicate mode warning from xrandr (benign) |
| Processes | `switchres_fightcade_wrap.sh`, `fcadefbneo.exe`, Wine, `fc2-electron` present |
| `fcadefbneo.ini` | `nVidHorWidth/Height` 384×224, `bVidDX9WinFullscreen 1`, `bVidAutoSwitchFull 1` |

**Inference:** Output timing is in arcade mode; black may be **sync settle**, **Wine draw delay**, or **stacking** (Electron vs game), not “Switchres did nothing.”

## Mitigation in wrapper

- **`sleep 2`** after `switchres … -s -k` and **before** `fcade.sh` so X11/CRT can stabilize before Wine starts drawing.

## Recovery if stuck (SSH)

Back to menu resolution without hard reboot:

```bash
export DISPLAY=:0.0
batocera-resolution setMode "641x480.59.98"
```

(Use your menu string from [01](01-open-ui-only-post-install.md) if it differs.)

Exit game: `killall fcadefbneo.exe` (last resort; wrapper restore may still run when process exits).

## Status

Retest after wrapper redeploy with **sleep 2** post-switchres.
