# Design — CRT Combo Mode Switch

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│  Boot Sequence                                          │
│                                                         │
│  S00bootcustom ─── boot-custom.sh                       │
│       │                 │                               │
│       │                 ├── (existing CRT tasks)         │
│       │                 └── crt_combo_listener.py &      │
│       │                          │                      │
│       ▼                          ▼                      │
│  S14labwc/X11          ┌──────────────────┐             │
│       │                │  Combo Listener   │             │
│       ▼                │  (persistent)     │             │
│  S31emulationstation   │                   │             │
│       │                │  poll() on evdev  │             │
│       ▼                │  devices          │             │
│  S90hotkeygen          │                   │             │
│       │                │  Detects 6-button │             │
│       ▼                │  chord held 2s    │             │
│  (system running)      └────────┬─────────┘             │
│                                 │                       │
│                                 ▼                       │
│                      mode_switch_headless.sh             │
│                          │                              │
│                          ├── detect_current_mode         │
│                          ├── backup_mode_files "crt"     │
│                          ├── restore_mode_files "hd"     │
│                          ├── sync                        │
│                          └── poweroff / reboot           │
└─────────────────────────────────────────────────────────┘
```

## Combo Listener Flow

```
START
  │
  ▼
Enumerate /dev/input/event* via pyudev
  │
  ▼
Register poll() on all devices with EV_KEY capability
  │
  ▼
Register udev monitor for hotplug (add/remove)
  │
  ▼
┌──────────── Main Loop ────────────┐
│                                    │
│  poll() with 200ms timeout         │
│       │                            │
│       ├── udev event? ──→ add/remove device from poll set
│       │                            │
│       ├── EV_KEY event?            │
│       │       │                    │
│       │       ├── value=1 (press): mark button as held for this device
│       │       │                    │
│       │       └── value=0 (release): mark button as released
│       │                            │
│       └── timeout (no event)       │
│               │                    │
│               ▼                    │
│  For each device: are all 6 target buttons held?
│       │                            │
│       ├── No ──→ reset that device's hold timer
│       │                            │
│       └── Yes ──→ has timer been running for ≥ 2s?
│               │                    │
│               ├── No ──→ continue (timer keeps counting)
│               │                    │
│               └── Yes ──→ TRIGGER! │
│                       │            │
│                       ▼            │
│               Play audio beep      │
│               or send FF_RUMBLE    │
│                       │            │
│                       ▼            │
│               Exec mode_switch_headless.sh
│               (system reboots, listener dies with it)
│                                    │
└────────────────────────────────────┘
```

## Target Buttons (evdev mapping)

The combo uses Batocera's logical trigger names. The actual evdev codes depend on the controller, but the listener needs to map from the controller's evdev capabilities to these logical buttons.

| Logical Button | evdev Typical | Notes |
|---------------|---------------|-------|
| SELECT | BTN_SELECT / BTN_BACK | Varies by controller |
| START | BTN_START / BTN_FORWARD | Varies by controller |
| L1 | BTN_TL | Left shoulder |
| R1 | BTN_TR | Right shoulder |
| L2 | BTN_TL2 or ABS_Z (axis) | May be analog trigger (axis) on some pads |
| R2 | BTN_TR2 or ABS_RZ (axis) | May be analog trigger (axis) on some pads |

### L2/R2 analog trigger problem

On Xbox-style controllers, L2/R2 are analog axes (`ABS_Z`/`ABS_RZ`), not buttons. The listener must handle both:
- **Digital triggers** (BTN_TL2/BTN_TR2): treat as button press/release
- **Analog triggers** (ABS_Z/ABS_RZ): treat as "pressed" when value exceeds a threshold (e.g. >50% of axis range)

## Headless Mode Switch Flow

```
mode_switch_headless.sh
  │
  ├── Source globals (SCRIPT_DIR, MODE_BACKUP_DIR, LOG_FILE, etc.)
  ├── Source 01_mode_detection.sh
  ├── Source 03_backup_restore.sh
  │
  ├── Guard: is /userdata mounted? (ls MODE_BACKUP_DIR)
  │     └── No → exit 1
  │
  ├── Guard: detect_current_mode == "crt"?
  │     └── No → exit 0 (already HD, no-op)
  │
  ├── Guard: HD backup exists? (hd_mode/ has batocera.conf or video_settings)
  │     └── No → exit 1 (nothing to restore)
  │
  ├── Log: "Combo mode switch triggered"
  ├── backup_mode_files "crt"
  ├── restore_mode_files "hd"
  ├── sync; sync
  │
  └── is_dualboot_system?
        ├── Yes → poweroff
        └── No  → reboot
```

## Feedback Mechanisms

### Audio beep (primary)

```bash
# Simple beep using ALSA (available early in boot)
aplay /usr/share/sounds/switch-confirm.wav 2>/dev/null &
# Or generate a tone via speaker-test if no wav file
speaker-test -t sine -f 1000 -l 1 -p 1 2>/dev/null &
```

### Controller rumble (secondary, if supported)

```python
# Via evdev force-feedback
import evdev
device.write(evdev.ecodes.EV_FF, effect_id, 1)
```

Not all controllers support FF_RUMBLE, so this is best-effort on top of audio.

## Safety Considerations

1. **No controller grab.** The listener reads events passively. ES, games, and hotkeygen all continue to receive input normally.
2. **CRT-only activation.** The headless script checks `detect_current_mode` and exits immediately if already in HD Mode.
3. **Filesystem readiness.** Won't attempt the switch if `/userdata` isn't mounted yet.
4. **Existing backup required.** Won't switch if there are no saved HD settings to restore.
5. **No CRT damage risk.** Switching from CRT → HD is safe for CRT monitors (the CRT would just lose signal). The dangerous direction (HD → CRT with a CRT plugged in while outputting high frequencies) is not triggered by this combo.
