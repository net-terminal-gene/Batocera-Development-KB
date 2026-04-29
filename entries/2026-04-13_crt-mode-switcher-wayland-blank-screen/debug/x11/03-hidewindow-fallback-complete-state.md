# Debug Stage X11-03 — HideWindow=true Fallback: Complete State Record

**Date:** 2026-04-14
**Continues from:** `debug/x11/02-crt-x11-hidewindow-approach.md`
**Status:** FUNCTIONAL but not ideal. Works as a fallback. Causes CRT OSD flash on every script launch. Superseded by videomode precision mismatch fix (see `research/02-videomode-precision-mismatch.md`).

---

## What HideWindow=true Does

When `HideWindow=true` is set in `es_settings.cfg`, EmulationStation's `FileData::launchGame` calls `window->deinit(true)` before executing the game command. This:
1. Calls `Renderer::deinit()`, which calls `SDL_DestroyWindow()`
2. SDL releases the DRM primary plane (ES's frozen splash frame is gone)
3. `process.window` is set to NULL, so `renderSplashScreen()` is never called
4. xterm launches with full ownership of the display
5. After xterm exits, ES calls `window->init()` to reinitialize its SDL window

**Result:** Terminal is visible and interactive. All 6 prior approaches that failed (see `02`) are bypassed because ES no longer holds the DRM buffer.

**Side effect:** The CRT shows an OSD flash (brief sync loss) on launch and exit. See Root Cause Analysis below.

---

## Root Cause of OSD Flash — CORRECTED

**Previous hypothesis (from 02):** SDL calls `XF86VidModeSwitchToMode` when destroying the fullscreen window, causing a mode restore that the CRT interprets as a sync disruption.

**Corrected finding:** The flash is caused by `emulatorlauncher` calling `changeMode()` due to a **videomode precision mismatch** between `batocera.conf` and the actual current mode:

```
batocera.conf:    global.videomode=769x576.50.00060
currentMode:      769x576.50.00
```

`emulatorlauncher` reads the config value, compares against `batocera-resolution currentMode`, finds a string mismatch, and calls `changeMode()`. This triggers a real resolution switch on entry and a restore on exit, producing two OSD flashes per launch.

**Evidence:** When `emulatorlauncher` was bypassed entirely (`/bin/bash %ROM%` in `es_systems_crt.cfg`), HideWindow=true still released the DRM plane BUT there was **zero OSD flash**. Terminal appeared smoothly. Only difference: no emulatorlauncher in the chain.

**Why the mismatch exists:** `crt-launcher.sh` has a fix for this precision mismatch, but it is gated behind a dual-boot check:
```bash
if [ -f "/boot/crt/linux" ] && [ -f "/boot/crt/initrd-crt.gz" ]; then
```
On single-boot CRT systems, these files do not exist. The sync is skipped. The mismatch persists.

Full analysis in `research/02-videomode-precision-mismatch.md`.

---

## Changes Applied (Fallback State)

### 1. `es_settings.cfg` injection — `03_backup_restore.sh`

**CRT mode restore** (lines 1323-1338): Ensures `HideWindow=true` is present.

```bash
local _es_cfg="/userdata/system/configs/emulationstation/es_settings.cfg"
mkdir -p "/userdata/system/configs/emulationstation"
if [ -f "$_es_cfg" ]; then
    if grep -q 'name="HideWindow"' "$_es_cfg" 2>/dev/null; then
        sed -i 's/<bool name="HideWindow" value="[^"]*"/<bool name="HideWindow" value="true"/' "$_es_cfg"
    else
        sed -i 's|</config>|\t<bool name="HideWindow" value="true" />\n</config>|' "$_es_cfg"
    fi
else
    printf '<?xml version="1.0"?>\n<config>\n\t<bool name="HideWindow" value="true" />\n</config>\n' > "$_es_cfg"
fi
```

**HD mode restore** (lines 1171-1179): Removes `HideWindow` entirely.

```bash
local _es_cfg="/userdata/system/configs/emulationstation/es_settings.cfg"
if [ -f "$_es_cfg" ] && grep -q 'name="HideWindow"' "$_es_cfg" 2>/dev/null; then
    sed -i '/<bool name="HideWindow"/d' "$_es_cfg"
fi
```

### 2. Shim cleanup — `crt/mode_switcher.sh`

All xdotool watcher code removed. Shim comments updated to document HideWindow approach. xterm runs directly in foreground with no background watcher. Wayland labwc rule injection logic preserved (unrelated, already working).

### 3. Device state

- `es_settings.cfg`: `<bool name="HideWindow" value="true" />`
- `es_systems_crt.cfg`: restored to `crt-launcher.sh ... emulatorlauncher` command (not `/bin/bash %ROM%`)

---

## How to Revert

If the smooth fix (removing dual-boot gate from `crt-launcher.sh`) works, this HideWindow injection is still correct to keep. HideWindow=true is needed regardless to release the DRM plane. The OSD flash goes away when the videomode mismatch is fixed.

If this fallback must be fully reverted:

1. Remove HideWindow injection blocks from `03_backup_restore.sh` (CRT restore + HD restore)
2. Remove or set `<bool name="HideWindow" value="false" />` in `es_settings.cfg` on device
3. Restart ES
4. **X11 blank-screen problem returns** — xterm hidden behind ES's DRM frame

Previous shim code (windowraise watcher, windowminimize attempts) is preserved in git history on the `crt-hd-mode-switcher-v43` branch.

---

## Key Insight

HideWindow=true is still necessary — it is the only way to release ES's DRM plane for xterm to appear. The OSD flash is a separate issue caused by `emulatorlauncher`'s videomode management, not by SDL or HideWindow itself. Fixing the videomode mismatch eliminates the flash while keeping HideWindow=true for DRM release.
