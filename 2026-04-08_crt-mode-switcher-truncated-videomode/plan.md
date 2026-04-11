# Mode Switcher: Truncated global.videomode — ES Shows "Auto"

## Agent/Model Scope

Composer + ssh-batocera for live system verification.

## Problem

After the mode switcher saves CRT settings, `global.videomode` in `batocera.conf` contains a truncated mode ID (e.g. `769x576.50.00`) that doesn't match any entry in `batocera-resolution listModes` (which expects `769x576.50.00060`). ES can't find a match, so it displays "Auto" in System Settings > Video Mode.

## Root Cause

The mode switcher's save logic in `02_hd_output_selection.sh` (lines 805–830) has a priority chain for writing `video_mode.txt`:

1. **Priority 1 (line 808):** If in CRT mode, use `batocera-resolution currentMode` — returns **empty** in X11/CRT mode (DRM/Wayland tool).
2. **Priority 2 (line 811):** Use `$boot_mode_id` from `get_boot_mode_id()` — resolves correctly to `769x576.50.00060`.
3. **Priority 3 (line 821):** If an existing `video_mode.txt` backup exists, **preserve it** instead of overwriting.

On the first mode switch from CRT→HD, Priority 1 fails (empty). Priority 2 would write the correct full-precision ID, but Priority 3 kicks in — the backup file already exists from `03_backup_restore.sh` line 261, which captured the truncated `global.videomode` value from `batocera.conf`. The stale `769x576.50.00` is preserved.

**Log evidence:**
```
Converting boot mode - input: 'Boot_576i 1.0:0:0 15KHz 50Hz', output: '769x576.50.00060'
Preserving existing CRT video_mode.txt from prior backup
```

## Solution

Remove the "preserve existing backup" guard on line 821. When `$boot_mode_id` is resolved (full precision from `videomodes.conf`), always write it — don't blindly preserve a potentially stale value.

```bash
# Current (broken):
elif [ -n "$boot_mode_id" ]; then
    if [ -s "${MODE_BACKUP_DIR}/crt_mode/video_settings/video_mode.txt" ]; then
        echo "Preserving existing CRT video_mode.txt from prior backup"
    else
        echo "global.videomode=$boot_mode_id" > "video_mode.txt"
    fi

# Fixed:
elif [ -n "$boot_mode_id" ]; then
    echo "global.videomode=$boot_mode_id" > "video_mode.txt"
```

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `Geometry_modeline/mode_switcher_modules/02_hd_output_selection.sh` (~line 821) | Remove "preserve existing" guard, always write resolved `$boot_mode_id` |

## Validation

- [ ] Verify `global.videomode` in `batocera.conf` matches full-precision mode ID from `batocera-resolution listModes`
- [ ] Verify ES UI > System Settings > Video Mode shows correct boot resolution (not "Auto")
- [ ] Verify mode switcher log shows correct mode ID being written (no "Preserving existing" message)
