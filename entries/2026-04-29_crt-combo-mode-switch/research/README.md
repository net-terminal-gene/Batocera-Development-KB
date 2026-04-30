# Research — CRT Combo Mode Switch

## Findings

### Triggerhappy (`thd`) — Primary approach

Triggerhappy is Batocera's system-level input event daemon. It runs persistently from `S50triggerhappy`, reads all `/dev/input/event*` devices, and matches key combos against a config file.

**Why it fits:**

1. **Multi-key combo support.** Config format: `KEY1+KEY2+KEY3 EVENT COMMAND`. Supports up to 5 modifiers (6 total keys).
2. **`BTN_*` gamepad codes work.** Upstream Batocera handheld configs (GameForce Chi, ODROID GO, etc.) already use `BTN_TRIGGER_HAPPY*` combos:
   ```
   BTN_TRIGGER_HAPPY1+BTN_TRIGGER_HAPPY3   1   batocera-brightness - 5
   BTN_TRIGGER_HAPPY2+BTN_TRIGGER_HAPPY3   1   batocera-brightness + 5
   ```
3. **Already used by CRT Script.** The script deploys its own `multimedia_keys.conf` with combos like `KEY_F3+KEY_RIGHTALT 1 bash /usr/bin/emukill`.
4. **User override supported.** Batocera's `triggerhappy.service` checks for `/userdata/system/configs/multimedia_keys.conf` and uses it if present. CRT Script installs to this path.
5. **Persistent, no daemon management.** Triggerhappy is a system service. Nothing new to start or stop.

**Source:** `batocera.linux/package/batocera/core/batocera-triggerhappy/triggerhappy.service`, `batocera.linux/package/batocera/core/batocera-triggerhappy/conf/rk3326/multimedia_keys_GameForceChi.conf`, `Batocera-CRT-Script/extra/media_keys/multimedia_keys.conf`

**Limitations:**

- **No built-in hold timer.** Triggerhappy fires on press (`1`) or repeat (`2`). The 5-second hold is implemented in the called script (sleep before acting), not in triggerhappy itself.
- **`EV_KEY` only.** Cannot detect analog axis events (`EV_ABS`). If L2/R2 are analog-only on the target controller, triggerhappy won't see them.
- **Modifier order may matter.** The last key in the combo is the "primary" and triggers the event when pressed while all others are held. May need testing.

### Why hotkeygen cannot be used

hotkeygen (`S90hotkeygen`) is a persistent daemon. It supports shell commands via `common_context.conf`:

```json
{
  "screenshot": "batocera-screenshot",
  "volumeup": "batocera-audio setSystemVolume +5",
  "controlcenter": "batocera-controlcenter"
}
```

`default_mapping.conf` maps individual evdev key codes to action names. But:

1. **Single-button mapping only.** The event loop processes individual `EV_KEY` events. No chord detection. Each physical button maps to one action.
2. **No hold timer.** Actions fire immediately on press (key-type) or release (command-type).

Extending hotkeygen with chord support would require upstream `batocera.linux` changes.

**Source:** `batocera.linux/package/batocera/utils/hotkeygen/hotkeygen.py` lines 505-515 (event loop), lines 441-450 (action dispatch)

### Why evmapy cannot be used

evmapy is an **emulator-session-only tool**. Started/stopped by `emulatorlauncher.py` (configgen) each time a game launches:

```python
_evmapy_instance = evmapy(systemName, ...)
with _evmapy_instance:
    # game runs here
# evmapy stops when context exits
```

When the user is at the EmulationStation menu (or facing a black screen), evmapy is not running.

evmapy **does** support `"type": "exec"` for running shell commands and multi-button triggers (e.g. `["hotkey", "start"]`), so the config format would be capable. The problem is purely that it's not running at the system level.

**Source:** `batocera.linux/package/batocera/core/batocera-configgen/configgen/configgen/utils/evmapy.py`

### Batocera boot sequence (init order)

| Init Script | Purpose | Controller availability |
|---|---|---|
| `S00bootcustom` | Runs `/boot/boot-custom.sh` | Wired/built-in: YES. BT: NO |
| `S04populate` | Symlinks, dirs | - |
| `S14labwc` | Wayland compositor (HD mode) | - |
| `S31emulationstation` | Starts ES | - |
| `S32bluetooth` (approx) | Bluetooth daemon | BT controllers available after |
| `S50triggerhappy` | Input hotkeys (reads multimedia_keys.conf) | YES for wired/built-in |
| `S90hotkeygen` | Hotkey daemon | - |

Built-in handheld controls (Steam Deck, Retroid, AYN) are HID devices available at kernel level, before any init scripts run. USB-wired controllers are also available early. Bluetooth controllers require `bluetoothd`.

**Primary use case (handheld) uses built-in controls: available at `S50triggerhappy` time.**

### Triggerhappy user override mechanism

From `triggerhappy.service`:

```bash
# custom conf
if test -e "/userdata/system/configs/multimedia_keys.conf"
then
    CONFPATH=/userdata/system/configs/multimedia_keys.conf
fi
DAEMON_ARGS="--daemon --triggers ${CONFPATH} ... /dev/input/event*"
```

CRT Script already installs a custom `multimedia_keys.conf` to this path. The new combo line just gets appended to the existing file.

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

Modules needed: `01_mode_detection.sh` (for `detect_current_mode`, `is_dualboot_system`) and `03_backup_restore.sh` (for `backup_mode_files`, `restore_mode_files`). Module `02_hd_output_selection.sh` is NOT needed (interactive output picker, HD output already saved). Module `04_user_interface.sh` is NOT needed (dialog UI).

### L2/R2 as analog axes

On Xbox-style and many modern controllers, L2/R2 are analog triggers reported as `ABS_Z`/`ABS_RZ` (axis events), not `BTN_TL2`/`BTN_TR2` (button events).

**Impact on triggerhappy approach:** Triggerhappy only handles `EV_KEY` events. If L2/R2 are analog-only, triggerhappy won't detect them. Options:
- Use different buttons in the combo
- Fall back to Python listener (backup approach handles `EV_ABS`)

**Mitigation:** Handheld built-in controls (the primary use case) typically report digital button events for all buttons including triggers. This is primarily a concern for external Xbox-style pads.

### Existing boot-custom.sh usage by CRT Script

`03_backup_restore.sh` writes `boot-custom.sh` content during mode switches:
- **HD mode (single-boot):** copies CRT theme assets from `/boot` to `/usr/share/` on boot
- **HD mode (dual-boot):** unified script that auto-detects HD vs CRT boot and runs appropriate tasks
- **CRT mode:** generates `/etc/X11/xorg.conf.d/15-crt-monitor.conf` before X starts

The triggerhappy approach does **not** require any changes to `boot-custom.sh` (unlike the Python backup approach which would need to launch a daemon from boot-custom).

---

## Backup Research: Python evdev Availability

Both `evdev` and `pyudev` are available in the Batocera image (used by hotkeygen and batocera-hotkeys). No additional dependencies needed if the Python listener is used.

### L2/R2 Handling (Python backup)

The Python listener can handle both:
- Watch `EV_KEY` for `BTN_TL2`/`BTN_TR2` (digital)
- Watch `EV_ABS` for `ABS_Z`/`ABS_RZ` and treat as "pressed" when value exceeds ~50% of axis range

This is the main advantage of the Python approach over triggerhappy for controllers with analog-only triggers.
