# Design — CRT Combo Mode Switch

## Architecture (Primary: Triggerhappy)

```
┌──────────────────────────────────────────────────────────────┐
│  Boot Sequence                                               │
│                                                              │
│  S00bootcustom ─── boot-custom.sh                            │
│       │                 │                                    │
│       │                 └── (existing CRT tasks only)        │
│       ▼                                                      │
│  S14labwc/X11                                                │
│       │                                                      │
│       ▼                                                      │
│  S31emulationstation                                         │
│       │                                                      │
│       ▼                                                      │
│  S50triggerhappy ──→ reads multimedia_keys.conf              │
│       │                    │                                 │
│       │    ┌───────────────┘                                 │
│       │    ▼                                                 │
│       │    BTN_SELECT+BTN_START+BTN_TL+BTN_TR+BTN_TL2+BTN_TR2
│       │         │                                            │
│       │         ▼                                            │
│       │    /usr/bin/crt-mode-switch-combo                    │
│       │         │                                            │
│       │         ├── sleep 5 (hold/safety window)             │
│       │         ├── audio beep                               │
│       │         ├── detect_current_mode == "crt"?            │
│       │         ├── HD backup exists?                        │
│       │         ├── backup_mode_files "crt"                  │
│       │         ├── restore_mode_files "hd"                  │
│       │         ├── sync                                     │
│       │         └── poweroff / reboot                        │
│       ▼                                                      │
│  S90hotkeygen                                                │
│       │                                                      │
│       ▼                                                      │
│  (system running)                                            │
└──────────────────────────────────────────────────────────────┘
```

### Key differences from backup approach

- **No new daemon.** Triggerhappy is already running at `S50`.
- **No boot-custom.sh changes.** Nothing new to launch on boot.
- **Pure shell.** The combo handler is a bash script, matching the rest of the CRT Script.
- **Existing pattern.** Identical to how `esrestart`, `xrestart`, `emukill` are triggered.

## Combo Handler Flow (`crt-mode-switch-combo`)

```
/usr/bin/crt-mode-switch-combo
  │
  ├── sleep 5
  │     (provides accidental-trigger protection;
  │      6-button chord itself is already near-impossible
  │      to hit accidentally)
  │
  ├── Audio beep (speaker-test or aplay)
  │
  ├── Source globals (SCRIPT_DIR, MODE_BACKUP_DIR, LOG_FILE, etc.)
  ├── Source 01_mode_detection.sh
  ├── Source 03_backup_restore.sh
  │
  ├── Guard: detect_current_mode == "crt"?
  │     └── No → exit 0 (already HD, no-op)
  │
  ├── Guard: HD backup exists? (hd_mode/ has batocera.conf)
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

## Target Buttons (evdev mapping)

| Logical Button | Triggerhappy Code | Notes |
|---------------|-------------------|-------|
| SELECT | BTN_SELECT | Some controllers use BTN_BACK |
| START | BTN_START | Some controllers use BTN_FORWARD |
| L1 | BTN_TL | Left shoulder |
| R1 | BTN_TR | Right shoulder |
| L2 | BTN_TL2 | Left trigger (digital) |
| R2 | BTN_TR2 | Right trigger (digital) |

### L2/R2 concern

Triggerhappy handles `EV_KEY` events. If a controller reports L2/R2 as `ABS_Z`/`ABS_RZ` (analog axes only, no digital `BTN_TL2`/`BTN_TR2`), triggerhappy won't see them. In that case, either:
- Swap L2/R2 for different buttons in the combo, or
- Fall back to the Python listener (backup approach)

Handheld built-in controls typically use digital buttons, so this is primarily a concern for external Xbox-style pads.

## Multimedia Keys Config Entry

Added to `extra/media_keys/multimedia_keys.conf`:

```
BTN_SELECT+BTN_START+BTN_TL+BTN_TR+BTN_TL2+BTN_TR2  1  /usr/bin/crt-mode-switch-combo
```

Format: `KEY_CODES  EVENT_VALUE  COMMAND`
- `1` = trigger on key-down (press event)
- Modifiers joined with `+`
- Triggerhappy supports up to 5 modifiers (6 total keys)

## Feedback Mechanism

```bash
speaker-test -t sine -f 1000 -l 1 -p 1 2>/dev/null &
```

Simple 1kHz tone via ALSA. Available early in boot. No display needed.

## Safety Considerations

1. **6-button chord.** Near-impossible accidental activation. No game uses all 6 simultaneously.
2. **5-second sleep.** Additional protection even if the chord is somehow hit.
3. **CRT-only activation.** Script checks `detect_current_mode` and exits if already HD.
4. **Filesystem readiness.** Won't attempt the switch if `/userdata` isn't mounted.
5. **Existing backup required.** Won't switch if there are no saved HD settings.
6. **No controller grab.** Triggerhappy reads events without grabbing. ES and games still receive input.
7. **No CRT damage risk.** CRT → HD is safe (CRT just loses signal). The dangerous direction (HD → CRT outputting wrong frequency) is not triggered.

---

## Backup Design: Python evdev Combo Listener

If the triggerhappy approach doesn't work on the target hardware (see L2/R2 concern above), here is the previously designed Python-based approach.

### Architecture (Backup)

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
│       ▼                │  chord held 5s    │             │
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

### Combo Listener Flow (Backup)

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
│       └── Yes ──→ has timer been running for ≥ 5s?
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

### Target Buttons — evdev mapping (Backup)

| Logical Button | evdev Typical | Notes |
|---------------|---------------|-------|
| SELECT | BTN_SELECT / BTN_BACK | Varies by controller |
| START | BTN_START / BTN_FORWARD | Varies by controller |
| L1 | BTN_TL | Left shoulder |
| R1 | BTN_TR | Right shoulder |
| L2 | BTN_TL2 or ABS_Z (axis) | May be analog trigger |
| R2 | BTN_TR2 or ABS_RZ (axis) | May be analog trigger |

### L2/R2 Analog Trigger Handling (Backup)

On Xbox-style controllers, L2/R2 are analog axes (`ABS_Z`/`ABS_RZ`), not buttons. The Python listener handles both:
- **Digital triggers** (BTN_TL2/BTN_TR2): treat as button press/release
- **Analog triggers** (ABS_Z/ABS_RZ): treat as "pressed" when value exceeds ~50% of axis range

### Controller Rumble Feedback (Backup)

```python
import evdev
device.write(evdev.ecodes.EV_FF, effect_id, 1)
```

Not all controllers support FF_RUMBLE, so this is best-effort on top of audio.
