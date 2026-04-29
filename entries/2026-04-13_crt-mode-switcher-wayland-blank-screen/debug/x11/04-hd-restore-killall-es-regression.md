# Debug X11-04 — HD Restore: `killall emulationstation` Broke Second CRT→HD Round-Trip

**Date:** 2026-04-16
**Relates to:** `03_backup_restore.sh` HD theme-asset block, `HideWindow` handling in CRT restore

## Symptom

After a full round-trip (CRT→HD→CRT), the second CRT→HD switch: user confirmed "System will reboot now..." then the mode switcher exited to EmulationStation with **no reboot**. Configs showed HD mode (gamelist hidden, `batocera.conf` HD-oriented) while the display stayed on CRT timing (X11, CRT resolution). Mixed state.

## Root Cause

`restore_mode_files` for HD mode copied CRT theme assets then ran:

```bash
killall emulationstation
sleep 2
```

**Intent:** Refresh ES so new theme icons appear immediately.

**Effect:** ES is the ancestor of the launch chain `ES → system() → emulatorlauncher → xterm → mode_switcher.sh`. Sending SIGTERM to ES can tear down or race the child tree. Worse, after CRT restore the user has **`HideWindow=true`**. The HD restore removes `HideWindow` from `es_settings.cfg` **before** `killall`. The restarted ES initializes with a full SDL window and reclaims the DRM scanout buffer. The xterm/dialog session is no longer visible or reliable; the script never reaches `FINAL PRE-REBOOT VERIFICATION` / `reboot`.

**Why first CRT→HD often "worked":** First switch had no HD backup of `es_settings.cfg`, so HideWindow behavior differed; race often still reached `reboot`. Second switch restored `es_settings.cfg` from HD backup and matched the HideWindow flip + killall pattern.

**v42 vs v43:** Same `killall` line exists on `crt-hd-mode-switcher` (v42). v43 ES + HideWindow management made the race reproducible.

## Fix

Remove `killall emulationstation` and the trailing `sleep 2` from the HD theme-asset path. Theme assets are already copied to `/userdata/themes/` and `/usr/share/`; the imminent **system reboot** loads them. No mid-restore ES restart.

**Shipped:** Batocera-CRT-Script branch `crt-hd-mode-switcher-v43`, commit `64b9a16` (with related mode-switcher fixes).

## Validation

- [x] CRT→HD→CRT→HD on PC (X11) and Steam Deck (Wayland + X11): reboot completes; no stuck mixed state
