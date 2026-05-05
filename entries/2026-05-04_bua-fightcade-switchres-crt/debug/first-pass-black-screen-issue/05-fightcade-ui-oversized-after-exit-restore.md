# 05 — Fightcade UI oversized after Exit emulator (restore verification)

**Date:** 2026-05-04  
**Symptom:** After **Game > Exit emulator**, Fightcade UI is **very large**, not normal ~640×480 menu layout.

**Likely cause:** X was still on an **arcade width** (e.g. 384) while Electron drew the UI; **`batocera-resolution setMode "$PRE_MODE"`** could report success or fail quietly without restoring menu timing.

**Fix in wrapper:** Restore must match **exact** launch timing for any menu mode (576i, 240p, etc.). `restore_display_mode` retries **`batocera-resolution setMode "$PRE_MODE"`** until **`display_matches_snapshot`** passes: **`currentMode` matches `PRE_MODE`** **or** **`currentResolution` matches `PRE_RES`** (both captured at wrapper start). Last resort: **`xrandr`** derived **only** from **`PRE_MODE`** (parse like `batocera-resolution.xorg`: `WxH` before first dot, remainder as `--rate`). No fixed 641×480 / **`forceMode`**.

**Retest:** TEST GAME → Exit emulator → UI scale should match cold launch.
