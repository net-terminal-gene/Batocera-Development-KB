# Bug 01: CRT Tools Invisible After HD/CRT Roundtrip

**Status:** Root cause confirmed, fix identified  
**Date:** 2026-02-21  
**Symptom:** CRT tools (Mode Switcher, Geometry, etc.) visible on VNC but invisible on physical CRT after completing a CRT->HD->CRT roundtrip.

## Root Cause

Two compounding issues:

### Issue A: Wrong `batocera-resolution` CLI command name

All scripts used `batocera-resolution getCurrentMode` — **this command does not exist**.
The correct command is `batocera-resolution currentMode`.

```
$ batocera-resolution getCurrentMode
error: invalid command getCurrentMode

$ batocera-resolution currentMode
769x576.50.00
```

The valid commands listed by `batocera-resolution`:
```
/usr/bin/batocera-resolution listModes
/usr/bin/batocera-resolution setMode <MODE>
/usr/bin/batocera-resolution currentMode          <-- CORRECT
/usr/bin/batocera-resolution currentResolution
/usr/bin/batocera-resolution listOutputs
/usr/bin/batocera-resolution currentOutput
/usr/bin/batocera-resolution setOutput <output>
/usr/bin/batocera-resolution minTomaxResolution
/usr/bin/batocera-resolution minTomaxResolution-secure
/usr/bin/batocera-resolution setDPI
/usr/bin/batocera-resolution forceMode <horizontal>x<vertical>:<refresh>
/usr/bin/batocera-resolution setRotation (0|1|2|3)
/usr/bin/batocera-resolution getRotation
/usr/bin/batocera-resolution getDisplayMode
/usr/bin/batocera-resolution getDisplayComp
/usr/bin/batocera-resolution refreshRate
```

**Note:** The Python emulatorlauncher uses `videoMode.getCurrentMode()` as a **method** on a Python object. The CLI tool uses `currentMode` (no "get" prefix). This naming discrepancy caused the confusion.

### Issue B: Video mode string precision mismatch

- `videomodes.conf` stores: `769x576.50.00060`
- `batocera-resolution currentMode` reports: `769x576.50.00`
- `global.videomode` in `batocera.conf` gets set to: `769x576.50.00060` (from videomodes.conf via `02_hd_output_selection.sh`)

When emulatorlauncher launches a CRT tool:
1. Reads `global.videomode=769x576.50.00060` from batocera.conf
2. Queries current mode: `769x576.50.00`
3. Sees mismatch -> calls `changeMode(769x576.50.00060)`
4. This disrupts the CRT display pipeline

## Evidence from System Logs

### es_launch_stdout.log (2026-02-21 23:53:54)
```
current video mode: 769x576.50.00
wanted video mode: 769x576.50.00060
setVideoMode(769x576.50.00060): ['batocera-resolution', 'setMode', '769x576.50.00060']
```

### es_launch_stderr.log
```
ERROR (videoMode.py:186):checkModeExists invalid video mode 769x576.50.00
```
(This error occurs when emulatorlauncher tries to restore the original mode after the tool exits)

## System State at Time of Investigation

```
Dual-boot:       YES (/boot/crt/linux exists)
currentMode:     769x576.50.00
global.videomode: 769x576.50.00060  (MISMATCH)
es.resolution:   769x576.50.00060  (MISMATCH)
15-crt-monitor.conf: Present and correct
crt-launcher.sh: Present and executable (rwxr-xr-x)
es_systems_crt.cfg: Points to crt-launcher.sh (correct)
```

## Affected Files (all use wrong `getCurrentMode`)

1. `Geometry_modeline/crt-launcher.sh` — wrapper script (primary fix)
2. `Geometry_modeline/mode_switcher_modules/02_hd_output_selection.sh` — backup precision fix
3. `Geometry_modeline/mode_switcher_modules/03_backup_restore.sh` — backup fallback

## Fix

Replace `getCurrentMode` with `currentMode` in all three files. The fix approach (wrapper + backup precision) is correct — only the CLI command name was wrong.
