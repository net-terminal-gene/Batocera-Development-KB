# X11 Mode Switcher First Boot — 2026-02-22 00:22-00:23 UTC

**Purpose:** State after launching Mode Switcher from CRT tools on first CRT boot (before any roundtrip). Confirms baseline behavior.

## System State

| Item | Value |
|------|-------|
| Uptime | 2 minutes |
| Kernel | 6.18.9 (X11 CRT) |
| Boot image | `BOOT_IMAGE=/crt/linux` |
| Current mode | `769x576.50.00` |

## batocera.conf Video Entries

```
es.resolution=769x576.50.00000
global.videooutput2=none
```

`global.videomode` still NOT set.

## Emulatorlauncher Log — Key Lines

```
'videomode': 'default'                          <-- No global.videomode set, falls back to 'default'
minTomaxResolution                              <-- Takes default path, no changeMode()
video mode before minmax: 769x576.50.00
current video mode: 769x576.50.00
wanted video mode: default                      <-- 'default' != specific mode, so NO changeMode triggered
resolution: 769x576
```

**No `setVideoMode` or `changeMode` calls.** Emulatorlauncher correctly skipped mode changes because `videomode=default`.

## evmapy / Controller

```
files to merge: mode_switcher.sh.keys, hotkeys.keys
config file: /var/run/evmapy/event14.json
```

Controller mapping set up correctly via evmapy.

## stderr

Only `evmapy: no process found` (normal — clearing previous evmapy before starting new one).

## Assessment

First boot CRT tools launch works correctly:
- `videomode=default` -> no mode change -> display stays stable
- evmapy controller support active
- Mode Switcher displayed on CRT screen (user is running it now for CRT->HD switch)

This confirms the bug only manifests AFTER a roundtrip when `global.videomode` gets set by `restore_video_settings()`.
