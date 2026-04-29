# Research: Steam Compatibility Across HD and CRT Modes

## Problem

BUA (Batocera Unofficial Addons) Steam requires `steam.emulator=sh` and `steam.core=sh` in `batocera.conf` to run .sh launchers through the sh generator (which supports per-game videomode). When users switch between HD and CRT modes via the Mode Switcher, Steam config can be lost and games fail to launch with:

```
error: app/com.valvesoftware.Steam/x86_64/master not installed
```

## Root Cause: batocera.conf Wholesale Replace

The mode switcher (`03_backup_restore.sh`) uses a **full-file replace** strategy for `batocera.conf`:

- **backup_mode_files()** — Copies entire `/userdata/system/batocera.conf` to `{mode}_mode/userdata_configs/batocera.conf`
- **restore_mode_files()** — Replaces live `batocera.conf` with `cp -a` from the target mode's backup

When switching **CRT → HD**, the HD backup's batocera.conf is restored. If the HD backup was taken **before** BUA Steam was installed, it has no `steam.emulator` or `steam.core` lines. The restore overwrites the live file → steam config is wiped.

Same logic for **HD → CRT**: restoring CRT backup overwrites; if CRT backup predates BUA Steam install, steam.* disappears.

## What Gets Preserved Today

The mode switcher already preserves **VNC settings** across mode switches:
1. Extract `global.vnc.*` from source mode's backup (or current batocera.conf)
2. After batocera.conf restore, re-apply those lines via sed/append

Steam settings are **not** in this preserve list.

## Steam Keys That Must Survive Mode Switch

| Key pattern | Purpose |
|-------------|---------|
| `steam.emulator=sh` | Use sh generator for .sh launchers |
| `steam.core=sh` | Same |
| `steam["*.sh"].videomode=*` | Per-game VIDEO MODE (e.g. 854x480 for Crystal Breaker on CRT) |

## BUA Steam File Locations (Not Touched by Mode Switcher)

| File | Location | Mode switcher |
|------|----------|---------------|
| es_systems_steam.cfg | /userdata/system/configs/emulationstation/ | Not backed up/restored — persists |
| es_features_steam.cfg | /userdata/system/configs/emulationstation/ | Not backed up/restored — persists |

These files are installed by BUA Steam and live in userdata. The mode switcher only backs up `es_settings.cfg` and `es_systems_crt.cfg`. Steam ES configs persist; only batocera.conf steam.* keys are at risk.

## Dual-Boot and Wayland Context

With v43 Wayland/X11 dual-boot:
- **HD Mode** — Wayland kernel, userdata shared. Steam runs via BUA Launcher (no Flatpak). Needs steam.emulator=sh.
- **CRT Mode** — X11 kernel, same userdata. Steam runs same way. Per-game videomode applies to CRT resolutions.

Both modes share `/userdata`; only batocera.conf is swapped per mode. Steam settings must survive that swap.
