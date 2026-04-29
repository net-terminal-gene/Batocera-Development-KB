# Debug Stage X11-02 — CRT/X11 Mode: Full Attempt History + HideWindow=true Current State

**Date:** 2026-04-14
**Continues from:** `debug/x11/01-crt-x11-blank-screen-findings.md`
**Status:** HideWindow=true WORKS but has a CRT OSD flash side effect. Seeking smoother alternative.

---

## Summary of All Approaches Tried

### Attempt 1: xdotool windowraise watcher loop
**Strategy:** Spawn a background loop that calls `xdotool windowraise $XTERM_WID` every 300ms for the lifetime of xterm.

**Result:** FAILED. ES's SDL render loop re-raises its window faster than the watcher can respond. The watcher confirms xterm is raised via X11, but ES immediately re-asserts itself. The user sees flickering at best.

**Why it fails:** Openbox forces both ES and xterm into the same fullscreen Z-layer. Within that layer, `XRaiseWindow` is a race — whichever process calls it last wins. ES's SDL main loop calls it continuously as part of its normal rendering cycle.

---

### Attempt 2: xdotool windowminimize ES + windowactivate xterm
**Strategy:** After xterm opens, minimize ES via `xdotool windowminimize $ES_WID`, then activate xterm.

**Result:** FAILED. xdotool confirmed ES was in a minimized state (Iconic) and xterm had keyboard focus and was the "active window." But the user still saw only game art on the CRT.

**Why it fails:** ES uses SDL2 with an OpenGL/GLX rendering context. SDL's GLX SwapBuffers writes directly into the GPU's DRM scanout buffer. This is separate from X11's window management system. Even though X11 reports ES's window as minimized, ES's last rendered frame is already committed to the DRM primary plane. Minimizing an X11 window does not evict its content from the DRM scanout buffer. xterm's X11 rendering cannot override what's in the DRM buffer.

The brief "flash" the user saw (xterm appearing for an instant then going back to artwork) is ES calling `SDL_RestoreWindow()` internally when it detects its window received `SDL_WINDOWEVENT_MINIMIZED`. ES immediately un-minimizes itself.

---

### Attempt 3: SIGSTOP EmulationStation
**Strategy:** After minimizing ES, send `kill -STOP $ES_PID` to freeze its process so it cannot call SDL_RestoreWindow.

**Result:** FAILED. The user saw "Artwork" — the CRT showed ES's frozen last frame. SIGSTOP halts the process at the exact point it's at, which freezes the DRM scanout buffer at ES's last GLX SwapBuffers call. The buffer is locked in hardware displaying ES content. xterm's X11 output has nowhere to go.

The "flash" that was visible earlier was ES briefly releasing the DRM buffer during its own transition animation, not a true xterm appearance.

---

### Attempt 4: Remove artwork from gamelist.xml
**Strategy:** Remove `<image>`, `<marquee>`, and `<thumbnail>` entries for `mode_switcher.sh` from `/userdata/roms/crt/gamelist.xml`, so ES has no artwork to render during launch.

**Hypothesis:** Without artwork, ES skips the fullscreen expanding animation, leaving a neutral state where xterm can appear.

**Result:** FAILED on its own. No artwork visible — user sees nothing — but xterm also doesn't appear. ES's window (even without artwork content) still occupies the fullscreen Z-layer and covers xterm. The DRM scanout buffer still belongs to ES.

---

### Attempt 5: GameTransitionStyle=instant
**Strategy:** Add `<string name="GameTransitionStyle" value="instant" />` to `es_settings.cfg`. This is the setting used in the v42 branch R9 hardware workaround.

**Hypothesis:** "instant" skips the expanding artwork launch animation, allowing xterm to appear cleanly.

**Result:** FAILED. `GameTransitionStyle` controls UI navigation animations within EmulationStation (system wheel to game list, etc.). It does NOT affect the game-launch splash/transition. ES's window still blocks xterm regardless of this setting. When combined with no artwork, the user saw "no artwork, not the terminal" — a blank situation worse than before.

**Note on v42 branch comparison:** The v42 branch `crt-hd-mode-switcher` has an identical gamelist.xml (with artwork) and uses the same ES `sh` emulator launcher. The difference is likely in the Batocera v42 ES binary itself — v42 ES may not have the same aggressive DRM rendering path for its launch animation. The v42 → v43 ES update changed rendering behavior that the CRT Script did not account for.

---

### Attempt 6 (CURRENT): HideWindow=true
**Strategy:** Add `<bool name="HideWindow" value="true" />` to `es_settings.cfg`.

**Mechanism (from batocera-emulationstation source, `FileData::launchGame` + `Platform.cpp`):**
- When `HideWindow=true`, ES calls `window->deinit(true)` before the game command runs
- `deinit(true)` fully destroys ES's SDL window and GL context, releasing the DRM primary plane
- `process.window = NULL` is set, so `renderSplashScreen()` is never called — zero splash
- ES calls `system(command)` — the command runs in a clean display environment
- xterm launches with full ownership of the display
- After the command exits, ES calls `window->init()` to reinitialize

**Result:** WORKS. Terminal appears cleanly. Dialog is visible and interactive. xterm owns the display for the full duration.

**Side effect — CRT OSD flash:**
When ES calls `deinit(true)`, SDL destroys its fullscreen window and calls `XF86VidModeSwitchToMode` to restore the previous X11 video mode (the mode saved before SDL created its fullscreen window). This causes a brief sync disruption on the CRT:
1. ES deinit: CRT detects sync change → OSD pops
2. xterm runs (stable, no mode change)
3. ES reinit: SDL sets the mode back → second sync disruption → OSD again

This "mode restore on window destroy" is standard SDL2/XF86VidMode behavior and cannot be suppressed from the script layer without patching SDL or ES.

**Current deployed state:**
- `es_settings.cfg` on device: `<bool name="HideWindow" value="true" />`
- `03_backup_restore.sh`: injects `HideWindow=true` on CRT mode restore, removes it on HD mode restore
- `crt/mode_switcher.sh` shim: cleaned of all xdotool code; xterm runs directly in foreground

---

## Fallback Reference (if HideWindow=true must be reverted)

To revert to HideWindow=false:
1. Set `<bool name="HideWindow" value="false" />` in `/userdata/system/configs/emulationstation/es_settings.cfg`
2. Restart ES (`batocera-es-swissknife --restart`)
3. Remove the HideWindow injection blocks from `03_backup_restore.sh`
4. The x11 blank-screen problem returns — xterm blocked by ES's DRM frame

Previous shim code (windowminimize approach, Attempt 2) is preserved in git history on `crt-hd-mode-switcher-v43` branch for reference.

---

## Root Cause (Confirmed)

In Batocera v43, EmulationStation uses SDL2/OpenGL with GLX double-buffering. `eglSwapBuffers` / `glXSwapBuffers` writes ES's frames directly into the GPU's DRM scanout buffer via the X Present extension. This write is at the hardware level — below X11 window management. No amount of X11 window manipulation (raise, minimize, layer changes, focus) can displace a committed DRM scanout frame.

The only reliable solutions are:
- **HideWindow=true**: ES releases the DRM plane before xterm starts (works, OSD flash side effect)
- **Direct framebuffer approach**: xterm or an alternative terminal runs at the DRM/KMS level, bypassing X11 entirely (untested)
- **Patching ES**: Suppress the splash per-system or per-ROM (not feasible for external script)
- **Alternative display strategy**: Something that doesn't require ES to relinquish the display

---

## Open Question

Is there a way to get xterm (or any terminal) visible on the CRT without ES releasing its DRM plane and without causing a sync disruption?

Candidates to investigate:
- A lightweight DRM/KMS terminal (`kmscon`, `fbterm`) that can overlay the DRM buffer without ES releasing it
- X11 compositing (enabling a compositor like picom under Openbox) that could place xterm above ES's GL output
- ES `gameStart` / `gameStop` script hooks as an alternative launch path that avoids the splash entirely
- Modifying the CRT system launch command in `es_systems_crt.cfg` to trigger a different ES code path

**Awaiting direction before implementing any new approach.**
