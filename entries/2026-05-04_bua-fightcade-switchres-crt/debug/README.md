# Debug — Fightcade Switchres CRT Integration

## Verification

```bash
# Check switchres modeline calc
DISPLAY=:0.0 switchres 384 224 59.60 -c

# Check current display mode during game
DISPLAY=:0.0 xrandr

# Get ROM resolution from MAME
/usr/bin/mame/mame -listxml sfiii3nr1 | grep '<display '

# Kill FBNeo + Wine remotely
killall fcadefbneo.exe; sleep 1; killall -9 wine; killall -9 wineserver
```

## Test Log

### PoC v1 (2026-05-04 13:39 UTC-6)

- Script: switchres -s -l "wine fcadefbneo.exe sfiii3nr1 -a"
- Result: FBNeo opened in windowed mode (not fullscreen)
- Alt+Enter triggered FBNeo error: "Problem setting '512x224x22bpp (0Hz)' display mode"
- Root cause: `-a` flag makes FBNeo try ChangeDisplaySettings via Wine, resolution not available

### PoC v2 (2026-05-04 13:49 UTC-6)

- Script: Patch FBNeo config (bVidDX9WinFullscreen=1, bVidAutoSwitchFull=1), switchres -s -l "wine fcadefbneo.exe sfiii3nr1"
- Result: **SUCCESS** - SF3 Third Strike running fullscreen on CRT at 384x224@59.60Hz
- xrandr confirmed: `SR-1_384x224@59.60  59.60*`
- Resolution restored to 641x480@60 after killall

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| "Not a standard VGA resolution" error | FBNeo `-a` flag trying Wine ChangeDisplaySettings |
| FBNeo opens windowed, not fullscreen | `bVidAutoSwitchFull` not set to 1 |
| Black screen after switchres | Monitor can't sync to modeline; check switchres.ini monitor preset |
| Wine hangs on exit | Wineserver still running; need killall -9 wineserver |
| No display change | DISPLAY=:0.0 not exported; switchres needs X11 |
