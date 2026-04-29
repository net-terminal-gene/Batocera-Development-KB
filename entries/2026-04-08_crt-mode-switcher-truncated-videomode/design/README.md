# Design — Mode Switcher Truncated global.videomode

## Save Logic Flow (02_hd_output_selection.sh:805–830)

```
save_crt_video_mode():
  ├─ [1] batocera-resolution currentMode → EMPTY (X11 mode, tool is DRM-only)
  ├─ [2] get_boot_mode_id() → "769x576.50.00060" (correct, full-precision)
  └─ [3] video_mode.txt already exists? → YES → PRESERVE (stale "769x576.50.00")
                                                   ↑
                                          Written by 03_backup_restore.sh
                                          which captured from batocera.conf
                                          (which had the truncated value)
```

## Fix Design

Replace the "preserve if exists" logic with unconditional write when a better value is available:

```
if in CRT mode AND batocera-resolution currentMode works:
    use synced mode (existing behavior, unchanged)
elif boot_mode_id is resolved (full precision from videomodes.conf):
    ALWAYS write it (remove the "preserve existing" guard)
else:
    use working_boot as-is (fallback, unchanged)
```

This ensures the full-precision mode ID from `videomodes.conf` (e.g. `769x576.50.00060`) is always written, rather than preserving a potentially stale backup.

## Interaction with crt-launcher.sh

`crt-launcher.sh` syncs `global.videomode` with `batocera-resolution currentMode` before each emulator launch (to prevent `emulatorlauncher` from triggering `changeMode()`). This sync works correctly when `currentMode` returns a value — but `currentMode` is empty in X11 mode. The mode switcher fix ensures the backup file has the correct full-precision value, which `restore_video_settings()` then writes to `batocera.conf`.
