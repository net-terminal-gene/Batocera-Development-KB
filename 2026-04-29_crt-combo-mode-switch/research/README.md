# Research — CRT Combo Mode Switch

## Findings

### Why evmapy cannot be used

evmapy is an **emulator-session-only tool**. It is started/stopped by `emulatorlauncher.py` (configgen) each time a game launches, via:

```python
# emulatorlauncher.py
_evmapy_instance = evmapy(systemName, ...)
with _evmapy_instance:
    # game runs here
# evmapy stops when context exits
```

When the user is at the EmulationStation menu (or facing a black screen), evmapy is not running. The `.keys` file next to `mode_switcher.sh` (`mode_switcher.sh.keys`) only drives dialog navigation when the switcher is launched as a "game" from ES.

evmapy **does** support `"type": "exec"` for running shell commands and multi-button triggers (e.g. `["hotkey", "start"]`), so the config format would be capable. The problem is purely that it's not running at the system level.

**Source:** `batocera.linux/package/batocera/core/batocera-configgen/configgen/configgen/utils/evmapy.py` and `emulatorlauncher.py`

### Why hotkeygen cannot be used (as-is)

hotkeygen (`S90hotkeygen`) is a persistent daemon that runs at all times. It supports shell commands via `common_context.conf`:

```json
{
  "screenshot": "batocera-screenshot",
  "volumeup": "batocera-audio setSystemVolume +5",
  "controlcenter": "batocera-controlcenter"
}
```

And `default_mapping.conf` maps individual evdev key codes to action names. But:

1. **Single-button mapping only.** The event loop processes individual `EV_KEY` events. There is no chord detection. Each physical button maps to one action.
2. **No hold timer.** Actions fire immediately on press (key-type) or release (command-type).

Extending hotkeygen with chord support would require upstream batocera.linux changes.

**Source:** `batocera.linux/package/batocera/utils/hotkeygen/hotkeygen.py` lines 505-515 (event loop), lines 441-450 (action dispatch)

### Available Python libraries in Batocera

Both `evdev` and `pyudev` are available in the Batocera image (used by hotkeygen and batocera-hotkeys). No additional dependencies needed for a combo listener.

### Batocera boot sequence (init order)

| Init Script | Purpose | Controller availability |
|---|---|---|
| `S00bootcustom` | Runs `/boot/boot-custom.sh` | Wired/built-in: YES. BT: NO |
| `S04populate` | Symlinks, dirs | - |
| `S14labwc` | Wayland compositor (HD mode) | - |
| `S31emulationstation` | Starts ES | - |
| `S32bluetooth` (approx) | Bluetooth daemon | BT controllers available after |
| `S90hotkeygen` | Hotkey daemon | - |

Built-in handheld controls (Steam Deck, Retroid, AYN) are HID devices available at kernel level, before any init scripts run. USB-wired controllers are also available early. Bluetooth controllers require `bluetoothd`.

**Primary use case (handheld) uses built-in controls: available at `S00bootcustom` time.**

### Mode switcher module dependencies

The headless script needs these globals set before sourcing modules:

```bash
SCRIPT_DIR="/userdata/system/Batocera-CRT-Script"
MODE_BACKUP_DIR="/userdata/Batocera-CRT-Script-Backup/mode_backups"
CRT_BACKUP_DIR="/userdata/Batocera-CRT-Script-Backup/BACKUP"
CRT_BACKUP_CHECK="${CRT_BACKUP_DIR%/*}/backup.file"
LOG_FILE="/userdata/system/logs/BUILD_15KHz_Batocera.log"
PYTHON_VERSION=$(python3 --version 2>/dev/null | cut -d' ' -f2 | cut -d'.' -f1,2 || echo "3.12")
PYTHON_PATH="/usr/lib/python${PYTHON_VERSION}/site-packages/configgen"
```

And optionally `CRT_ROMS` (for tools in roms folder).

Modules needed: `01_mode_detection.sh` (for `detect_current_mode`, `is_dualboot_system`) and `03_backup_restore.sh` (for `backup_mode_files`, `restore_mode_files`). Module `02_hd_output_selection.sh` is NOT needed (interactive output picker, HD output already saved). Module `04_user_interface.sh` is NOT needed (dialog UI).

### L2/R2 as analog axes

On Xbox-style and many modern controllers, L2/R2 are analog triggers reported as `ABS_Z`/`ABS_RZ` (axis events), not `BTN_TL2`/`BTN_TR2` (button events). The combo listener must handle both:

- Watch `EV_KEY` for `BTN_TL2`/`BTN_TR2` (digital)
- Watch `EV_ABS` for `ABS_Z`/`ABS_RZ` and treat as "pressed" when value exceeds ~50% of axis range

### Existing boot-custom.sh usage by CRT Script

`03_backup_restore.sh` already writes `boot-custom.sh` content during mode switches:
- **HD mode (single-boot):** copies CRT theme assets from `/boot` to `/usr/share/` on boot
- **HD mode (dual-boot):** unified script that auto-detects HD vs CRT boot and runs appropriate tasks
- **CRT mode:** generates `/etc/X11/xorg.conf.d/15-crt-monitor.conf` before X starts

The combo listener launch would need to be appended to (or called from) whichever `boot-custom.sh` variant is active. Alternatively, the installer could place a separate init script (e.g. in `/userdata/system/scripts/` or as an `S01` hook).
