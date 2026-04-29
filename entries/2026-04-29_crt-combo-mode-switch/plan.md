# CRT Combo Mode Switch (Controller Combo to Switch CRT → HD)

## Problem

When a handheld running CRT Mode is powered on without a CRT display attached (e.g. traveling, forgot to switch to HD Mode before leaving), the user gets a **permanent black screen**. The 15kHz CRT output cannot drive the handheld's built-in LCD. There is no way to switch to HD Mode without SSH access or plugging into a CRT.

This is a dead end for non-technical users and a frustration for everyone.

## User Journey

### The problem scenario

1. User has a handheld (Steam Deck, Retroid, AYN, etc.) with CRT Script installed
2. At home, they use CRT Mode with a CRT display
3. They need to leave (train, trip, couch) and forget to switch to HD Mode first
4. They power on the handheld away from home
5. **Black screen.** The system boots into CRT Mode, outputs 15kHz, the LCD shows nothing
6. Currently: the device is a brick until they get back to a CRT or SSH in

### The solution scenario

1. Same setup: handheld powers on, black screen (CRT Mode, no CRT attached)
2. User holds **SELECT + START + L1 + L2 + R1 + R2** for 2 seconds
3. Audio beep or controller vibration confirms the combo was detected
4. System automatically switches to HD Mode using previously saved HD settings
5. System reboots (or powers off for dual-boot)
6. Device boots into HD Mode, LCD works, user can play

### Key UX details

- **No timing required.** The combo listener runs as a persistent background daemon from early boot. The user can press the combo at any point: during boot, at the ES menu, or minutes after boot. If pressed too early (BIOS/bootloader), nothing happens; just try again.
- **2-second hold requirement.** All 6 buttons must be held simultaneously for at least 2 seconds before triggering. This prevents accidental activation and gives the user confidence that the system registered their intent.
- **Blind-friendly.** The user has no screen. Feedback comes through audio (beep) or haptics (controller rumble) to confirm "switching now."
- **No-op safety.** If the system is already in HD Mode, the combo does nothing. If HD settings have never been saved (no prior mode switch), the combo does nothing (or beeps an error pattern).
- **Does not interfere with gameplay.** The 6-button combo is essentially impossible to hit during normal use. No game or menu maps all 6 of these buttons simultaneously.

## Root Cause

No mechanism exists to switch modes without a display. The mode switcher (`mode_switcher.sh`) is a dialog-based interactive tool that requires a visible terminal.

## Solution

Two new components:

### 1. Combo listener daemon (`crt_combo_listener.py`)

- Python script using `evdev` + `pyudev` (both already in Batocera image)
- Runs as a persistent background daemon from early boot (`S00bootcustom` / `boot-custom.sh` or a dedicated init script)
- Passively reads (no grab) all controller evdev devices
- Tracks button state per device; when all 6 target buttons are held for 2 continuous seconds, triggers the switch
- Provides audio/haptic feedback on activation
- Near-zero CPU when idle (blocks on `poll()`)
- Exits cleanly on SIGTERM

### 2. Headless mode switch script (`mode_switch_headless.sh`)

- Non-interactive shell script that performs CRT → HD switch
- Sources the existing mode switcher modules (`01_mode_detection.sh`, `03_backup_restore.sh`)
- Sets the same globals as `mode_switcher.sh`
- Flow:
  1. Check `/userdata` is mounted (safety: don't run during early filesystem init)
  2. `detect_current_mode` must return `"crt"` (no-op otherwise)
  3. Check HD settings backup exists (`mode_backups/hd_mode/`)
  4. `backup_mode_files "crt"`
  5. `restore_mode_files "hd"`
  6. `sync`
  7. `poweroff` (dual-boot) or `reboot` (single-boot) via `is_dualboot_system`

### Integration

- The combo listener is deployed by the CRT Script installer alongside other CRT tools
- Started via `boot-custom.sh` (already used by CRT Script for early-boot tasks) with `&` to background
- Only active when CRT Script is installed (the listener script lives in the CRT Script tree)

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `Geometry_modeline/crt_combo_listener.py` | New: combo listener daemon |
| Batocera-CRT-Script | `Geometry_modeline/mode_switch_headless.sh` | New: non-interactive CRT→HD switch |
| Batocera-CRT-Script | `Geometry_modeline/mode_switcher_modules/03_backup_restore.sh` | Possibly: extract shared setup into a sourceable preamble (or just duplicate globals in headless script) |
| Batocera-CRT-Script | `Batocera_ALLINONE/Batocera-CRT-Script*.sh` | Modified: deploy new files during install |
| Boot partition | `/boot/boot-custom.sh` | Modified: start combo listener daemon in background |

## Validation

- [ ] Combo listener starts at boot and survives full boot sequence
- [ ] Combo correctly detected on wired/built-in controller with 2-second hold
- [ ] No false triggers during normal ES navigation or gameplay
- [ ] Headless mode switch correctly restores HD settings from backup
- [ ] System reboots into working HD Mode after combo trigger
- [ ] No-op when already in HD Mode
- [ ] No-op when HD settings backup doesn't exist
- [ ] Combo listener does not grab controller (ES/games still get input)
- [ ] Audio/haptic feedback works on at least one test device
- [ ] Listener handles controller connect/disconnect (USB hot-plug, Bluetooth)
