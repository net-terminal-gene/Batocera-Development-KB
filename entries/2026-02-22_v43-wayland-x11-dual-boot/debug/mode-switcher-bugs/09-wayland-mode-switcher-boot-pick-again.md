# Bug: Wayland Mode Switcher Asks for CRT Boot Resolution Again — 2026-02-22 00:29 UTC

**Status:** UX bug identified, data integrity preserved  
**Symptom:** When switching HD->CRT, the Mode Switcher UI asks the user to pick the CRT Boot Resolution again, even though it was already saved during the CRT->HD switch.

## Root Cause

The Layer 2 fix in `02_hd_output_selection.sh` saves `video_mode.txt` with `769x576.50.00` (from `batocera-resolution currentMode`). When the UI loads saved configs during HD->CRT, it calls `get_boot_display_name("769x576.50.00")` to convert the mode ID back to a display name.

But `BOOT_MODE_IDS` (populated from `videomodes.conf`) contains `769x576.50.00060`. The exact string match fails:
```
Saved:       769x576.50.00       (from currentMode)
Lookup:      769x576.50.00060    (from videomodes.conf)
Result:      NO MATCH → empty display name → Boot field empty
```

## Log Evidence

```
[00:29:53]: Config check - HD: eDP-1, CRT: DP-1, Boot: 
[00:29:53]: Needs - HD: false, CRT: false, Boot: true, All configured: false
[00:29:53]: Boot resolution selection started
```

HD and CRT outputs are found. Boot is empty because the reverse lookup failed.

## Data Integrity

The `video_mode.txt` still contains the correct value:
```
global.videomode=769x576.50.00
```

The Layer 2 code preserves this file when NOT in CRT mode (HD->CRT direction):
```bash
if [ -s "${MODE_BACKUP_DIR}/crt_mode/video_settings/video_mode.txt" ]; then
    echo "Preserving existing CRT video_mode.txt from prior backup"
```

So even though the user is asked to re-pick, the saved value is preserved with the correct precision. **The wrapper will still work.**

## Also Noted: Verification False Failures

```
[00:24:14]: ERROR: es_systems_crt.cfg missing emulatorlauncher - RE-COPYING...
[00:27:07]: FINAL VERIFICATION FAILED: es_systems_crt.cfg is INCORRECT!
```

Both verification checks grep for literal "emulatorlauncher" but the command now uses `crt-launcher.sh`.

## Fix Needed

1. **Boot resolution lookup:** `get_boot_display_name()` in `02_hd_output_selection.sh` needs a prefix-match fallback so `769x576.50.00` matches `769x576.50.00060`
2. **Verification greps:** Update grep checks in `mode_switcher.sh` and `03_backup_restore.sh` to also accept `crt-launcher` instead of only `emulatorlauncher`
