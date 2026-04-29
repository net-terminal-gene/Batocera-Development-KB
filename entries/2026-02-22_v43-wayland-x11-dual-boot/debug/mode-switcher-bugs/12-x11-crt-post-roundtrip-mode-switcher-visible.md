# X11 CRT Post-Roundtrip — Mode Switcher VISIBLE on CRT — 2026-02-22 00:38 UTC

**Context:** After HD→CRT roundtrip reboot. User confirms Mode Switcher is visible on the physical CRT screen.

**Result: SUCCESS — CRT tools display correctly after a full CRT→HD→CRT roundtrip.**

## emulatorlauncher Evidence

```
current video mode: 769x576.50.00
wanted video mode: 769x576.50.00
```

**No mismatch. No `changeMode()` call. Display pipeline untouched.**

## Call Chain

```
EmulationStation
  → crt-launcher.sh (wrapper — sync is no-op since values already match)
    → emulatorlauncher (sees matching modes, skips changeMode)
      → /bin/bash /userdata/roms/crt/mode_switcher.sh
        → xterm (visible on CRT)
          → mode_switcher.sh (dialog UI)
```

## Running Processes

- `crt-launcher.sh` — launched by ES with controller config
- `emulatorlauncher` — Python process, running
- `evmapy` — controller mapping daemon, running
- `mode_switcher.sh` — running in xterm
- `xterm` — visible on physical CRT

## Controller Support

`evmapy` is running with merged keys file:
```
files to merge: [mode_switcher.sh.keys, hotkeys.keys]
config file: /var/run/evmapy/event10.json
```

Controller should be functional in the dialog UI.

## batocera.conf (unchanged)

```
global.videomode=769x576.50.00
global.videooutput=DP-1
es.resolution=769x576.50.00
```

## Why It Works

1. Layer 2 fix preserved `video_mode.txt` with `769x576.50.00` during CRT→HD backup
2. CRT restore wrote `global.videomode=769x576.50.00` back to `batocera.conf`
3. `batocera-resolution currentMode` returns `769x576.50.00`
4. `emulatorlauncher` compares: `769x576.50.00` == `769x576.50.00` → match → no mode change
5. Display pipeline stays stable → xterm renders on CRT → Mode Switcher visible

## Remaining Known Issues (document only)

1. **Boot resolution re-ask (bug #09):** `get_boot_display_name()` exact-match fails on `769x576.50.00` vs `769x576.50.00060` — needs prefix-match fallback
2. **Verification false positives:** Grep checks for "emulatorlauncher" trigger on `crt-launcher.sh` — cosmetic log noise
3. **DISPLAY dependency (doc #11):** `crt-launcher.sh` doesn't explicitly set `DISPLAY=:0.0` — works via ES inheritance but should be hardened
