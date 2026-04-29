# Research: v42 vs v43 ES Launch Behavior — Why xterm Is Blocked in CRT/X11 Mode

**Date:** 2026-04-14

---

## Key Finding

Device is running **stock v43 beta ES** (build 2026/04/01, md5 `3cea32ab...`). None of ZFEbHVUE's custom multiscreen ES binaries are installed. The repo has custom binaries at `UsrBin_configs/emulationstation-standalone-v43_ZFEbHVUE-MultiScreen` but the device's `/usr/bin/emulationstation` does not match any of them.

---

## v42 vs v43 Branch Differences

### Shim (`crt/mode_switcher.sh`)

**Identical.** Both branches have the same 2-line shim:
```bash
#!/bin/bash
DISPLAY=:0.0 xterm -fs 15 -maximized -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 -e bash -c "DISPLAY=:0.0  /userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher.sh"
```

The shim is not the source of the difference.

### es_systems_crt.cfg `<command>` tag

| Branch | Command |
|--------|---------|
| v42 (`crt-hd-mode-switcher`) | `emulatorlauncher %CONTROLLERSCONFIG% -system %SYSTEM% -rom %ROM% ...` |
| v43 (`crt-hd-mode-switcher-v43`) | `/userdata/system/Batocera-CRT-Script/Geometry_modeline/crt-launcher.sh %CONTROLLERSCONFIG% -system %SYSTEM% -rom %ROM% ...` |

`crt-launcher.sh` syncs `global.videomode` precision then does `exec emulatorlauncher "$@"`. Same launch path; just a wrapper. Added 2026-02-21 in the dual-boot commit.

### gamelist.xml

**Identical.** Both have artwork (`image`, `marquee`, `thumbnail`) for `mode_switcher.sh`.

### ES binary

v42 branch ships a custom multiscreen ES binary (`emulationstation-standalone-v42_ZFEbHVUE-MultiScreen`). v43 branch also ships one (`emulationstation-standalone-v43_ZFEbHVUE-MultiScreen`, last updated 2026-03-17). **Neither is deployed on the device.** Device runs stock v43 beta.

---

## What Changed Around April 3 (When It Broke)

The v43 branch merged upstream/main on **2026-03-28** (commit `cbdcc04`). This brought in:

| Date | Commit | Change |
|------|--------|--------|
| 2026-03-17 | `430e417` | **Updated `emulationstation-standalone-v43_ZFEbHVUE-MultiScreen`** (49 ins, 28 del) |
| 2026-03-17 | `4f68c28` | **Updated `emulatorlauncher.py_v43_ZFEbHVUE`** (146 ins, 137 del) |
| 2026-03-14 | `6206b11` | Restored missing `setMode_CVT` helper functions (batocera-resolution) |

But since the custom ES binary isn't deployed, the ES binary change is irrelevant to this device.

The more likely cause: the Batocera v43 beta image was updated. Device shows `43 2026/04/01 18:32` — an April 1 build. If the user reflashed or the image auto-updated, the stock ES binary changed between the "pre-April 3 it worked" point and now.

---

## ES Launch Flow (from batocera-emulationstation source, master branch)

### FileData::launchGame (es-app/src/FileData.cpp, line 689)

```
1. AudioManager::deinit()
2. VolumeControl::deinit()
3. hideWindow = Settings::getBool("HideWindow")    ← reads es_settings.cfg
4. window->deinit(hideWindow)                       ← KEY CALL
5. ProcessStartInfo process(command)
6. process.window = hideWindow ? NULL : window       ← controls splash
7. exitCode = process.run()                          ← blocks here
8. (post-game: reinit, restore audio, etc.)
```

### Window::deinit(bool deinitRenderer) (es-core/src/Window.cpp, line 188)

```
- Hide all GUI elements
- if (deinitRenderer) InputManager::deinit()
- TextureResource::clearQueue()
- ResourceManager::unloadAll()
- if (deinitRenderer) Renderer::deinit()   ← DESTROYS SDL window + GL context
```

**deinit(false)** — `HideWindow=false` (default):
- Unloads resources but **Renderer stays alive**
- SDL window still exists, GL context still holds DRM scanout plane
- ES frozen last frame persists on display

**deinit(true)** — `HideWindow=true`:
- Calls `Renderer::deinit()` → SDL_DestroyWindow → releases DRM plane
- Display is free for xterm
- **Side effect:** SDL calls `XF86VidModeSwitchToMode` on window destroy, causing CRT sync disruption (OSD flash)

### ProcessStartInfo::run() (es-core/src/utils/Platform.cpp)

Linux path:
```
1. if (window != nullptr) window->renderSplashScreen()  ← ONCE
2. system(command)                                        ← blocking, no refresh
```

When `HideWindow=false`: `window` is passed → splash rendered once → frame persists in GL buffer → `system()` blocks → that one frame is what the user sees for the entire game duration.

When `HideWindow=true`: `window` is NULL → no splash → `system()` runs on a clean display.

### setCustomSplashScreen (Window.cpp, line 943)

```cpp
if (Settings::getInstance()->getBool("HideWindow"))
    return;  // skip splash entirely when HideWindow is true
```

---

## Why v42 Worked (Hypothesis)

Two possible explanations. Testing needed to confirm which:

### Hypothesis A: v42 Stock ES Had Different Rendering Behavior
Batocera v42 ES may not have used GLX direct rendering for its launch splash — or may have used software rendering that didn't lock the DRM scanout buffer. v43 ES received major rendering changes (texture async loading, VRAM management overhaul — commits from fabricecaruso in March 2026). These changes may have moved ES to a more aggressive DRM usage.

### Hypothesis B: Device Previously Had Custom ES Binary
If the user previously ran CRT Script installer which deploys `emulationstation-standalone-v42_ZFEbHVUE-MultiScreen`, that custom binary may handle the launch splash differently (or not render one at all). After reflashing to v43 beta, the custom binary was replaced by stock ES. The v43 custom binary was never installed because the CRT Script installer may not have been re-run after the reflash.

---

## HideWindow=true as Current Fix

**Works:** xterm appears cleanly.
**Side effect:** CRT OSD flash — `Renderer::deinit()` triggers SDL `XF86VidModeSwitchToMode` which causes a brief sync disruption on the CRT.

The OSD flash happens because:
1. ES deinit → SDL destroys fullscreen window → restores saved X11 mode → sync blip
2. xterm launches (stable)
3. When xterm exits: ES reinit → SDL creates new fullscreen window → sets mode again → second sync blip

---

## Alternative Approaches to Investigate

### 1. Deploy ZFEbHVUE's Custom ES Binary
If the custom multiscreen ES does not render a launch splash (or handles it differently), deploying it may fix the issue without HideWindow. Need to verify.

### 2. Use emulatorlauncher's Pipe-Based Launch (Not system())
emulatorlauncher.py on v43 was updated with major changes (146 ins, 137 del). If the Python launcher uses `subprocess.Popen` with stdout/stderr pipes instead of ES's internal `system()` call, ES may handle the display differently. Need to check if `crt-launcher.sh → emulatorlauncher → shGenerator → /bin/bash rom.sh` follows a code path that avoids the splash altogether.

### 3. ES Game Script Hook
ES fires `game-start` / `game-end` scripting events. Could a script in `/userdata/system/scripts/game-start/` hide or kill the splash? Unlikely — the splash is already rendered before scripts fire.

### 4. Bypass emulatorlauncher Entirely
Instead of `es_systems_crt.cfg` using `emulatorlauncher`, use a direct `<command>` that runs the shim directly:
```xml
<command>/userdata/system/Batocera-CRT-Script/Geometry_modeline/crt/mode_switcher.sh</command>
```
This may change how ES handles the launch (no `ProcessStartInfo`, just raw `system()` call with no window pointer). Needs testing.

### 5. Partial Renderer Deinit
Theoretically: tell SDL to release its fullscreen mode without destroying the window, avoiding the mode restore that causes OSD flash. Not possible from script layer — would require ES patch or SDL environment variable.

---

## Open Questions

1. Was the custom ES binary previously deployed on this device? (`/boot/boot/overlay` may have contained it)
2. Does the v42 stock ES binary (from an actual v42 image) exhibit the same splash blocking behavior?
3. Does the ZFEbHVUE custom v43 ES binary handle launches differently?
4. Does bypassing `emulatorlauncher` in `es_systems_crt.cfg` avoid the splash?
