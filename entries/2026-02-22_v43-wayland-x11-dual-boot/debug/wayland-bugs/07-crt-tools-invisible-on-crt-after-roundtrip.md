# Bug 07: CRT Tools Invisible on Physical CRT After HD→CRT Roundtrip

## Status: FIXED

## Symptom

After completing a full roundtrip (Phase 2 → CRT → HD Mode Switch → CRT Mode Switch), CRT tools
(Mode Switcher, Geometry, Grid Tool, ES Adjust) launched from EmulationStation were invisible on
the physical CRT display. The tools were visible via VNC, confirming they were running and rendering
to the X11 framebuffer — just not appearing on the hardware scanout.

The user saw: a screen flash, then ES's launch image (`hd_crt_switcher-image.png`) remained on
screen. The tool's dialog was only visible via VNC.

After a fresh Phase 2 install (before any roundtrip), the tools worked perfectly.

## Root Cause

`emulatorlauncher` (Batocera's Python-based game launcher) was triggering a video mode change
via `batocera-resolution setMode` every time a CRT tool was launched.

The mode change was triggered because of a **refresh rate string precision mismatch**:

- `batocera-resolution getCurrentMode` returned: `769x576.50.00`
- `global.videomode` in `batocera.conf` was set to: `769x576.50.00060`

These represent the same physical mode (769x576 at ~50Hz interlaced) but differ in string
representation. Since `emulatorlauncher` does a string comparison, it called
`batocera-resolution setMode 769x576.50.00060`, which invoked `switchres` to delete and
recreate the xrandr output mode mid-launch.

This modeset disrupted the display pipeline:
- ES's OpenGL-rendered launch image persisted on the hardware framebuffer
- The xterm window rendered underneath ES's surface
- VNC reads the X framebuffer directly, so it saw the xterm correctly

After a fresh Phase 2, the mode strings matched (switchres had just set the mode with that
exact precision), so no mode change was triggered and tools worked. After a roundtrip, X
initialized the mode from xorg.conf.d files rather than switchres, producing a differently
formatted mode string.

## Fix

In `03_backup_restore.sh` `backup_video_settings()`: when backing up the CRT video mode
before switching to HD, query `batocera-resolution getCurrentMode` for the actual mode string
instead of copying the value from `batocera.conf`. This ensures the backed-up `video_mode.txt`
contains the exact string the system will report on next boot, eliminating the precision
mismatch that triggers the spurious mode change.

```bash
# For CRT: use the actual current mode string from batocera-resolution
current_mode=$(batocera-resolution getCurrentMode 2>/dev/null)
echo "global.videomode=${current_mode}" > "${backup_dir}/video_mode.txt"
```

When `restore_video_settings("crt")` later writes this value back to `batocera.conf`, the
`global.videomode` will match `getCurrentMode` exactly, and `emulatorlauncher` will see
`wanted == current` — no mode change, no display disruption.

## Additional fix in boot-custom.sh

The `main()` function in the dual-boot `boot-custom.sh` was missing `copy_theme_assets`
in the CRT boot path. Added so CRT mode also gets theme assets copied to volatile `/usr/share/`.

## Files Modified

- `mode_switcher_modules/03_backup_restore.sh` — videomode sync in `backup_video_settings()`
  and `copy_theme_assets` call in boot-custom.sh CRT path

## Reverted changes (debugging residue removed)

- `Geometry_modeline/crt/*.sh` (all 4 launcher scripts) — removed `xdotool windowminimize`
  and `export DISPLAY` that were added during debugging; reverted to originals
- `Geometry_modeline/es_systems_crt.cfg` — briefly changed to `/bin/bash %ROM%` to bypass
  emulatorlauncher (fixed display but broke controller support); reverted to `emulatorlauncher`

## Impact on X11-only (non-dual-boot) builds

None. The videomode sync only activates for `mode="crt"` in `backup_video_settings()`.
In X11-only builds without the roundtrip, the mode string mismatch doesn't occur.

## Investigation timeline

1. Initially suspected xterm color contrast (`-bg black`) — ruled out
2. Suspected ES window stacking — xdotool minimize worked from SSH but not from ES-launched script
3. Identified missing `15-crt-monitor.conf` — fixed with unified `boot-custom.sh` but didn't
   resolve the tool visibility issue (the file IS needed but wasn't the cause of this specific bug)
4. Found `emulatorlauncher` mode change in logs — `CRT.videomode=default` didn't override due to
   Batocera's config inheritance treating "default" as "use parent value"
5. Bypassed `emulatorlauncher` with `/bin/bash %ROM%` — fixed display but broke controller (evmapy)
6. Attempted shGenerator.py boot-time patch — worked but is a hack (modifying system Python at boot)
7. Final fix: sync videomode string during CRT backup via `batocera-resolution getCurrentMode`
