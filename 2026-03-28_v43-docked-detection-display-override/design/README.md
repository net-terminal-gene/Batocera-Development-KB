# Design — v43 Docked Detection Display Override

## Flow: How Docked Detection Works (Broken Behavior)

```
Cable plugged in
    ↓
GPU reads EDID from display
    ↓
DRM raises hotplug event
    ↓
udev rule (80-switch-screen.rules) fires batocera-switch-screen-checker-delayed
    ↓
batocera-switch-screen-checker runs _detect_docked_output()
    │
    ├── Read global.videooutput / videooutput2 / videooutput3 → KNOWN_OUTPUTS
    ├── batocera-resolution listOutputs → all connected outputs
    ├── Any connected output NOT in KNOWN_OUTPUTS?
    │       YES → write to /var/run/batocera-docked
    │       NO  → remove /var/run/batocera-docked
    ↓
curl http://localhost:1234/quit  → ES restarts
    ↓
emulationstation-standalone reads /var/run/batocera-docked
    │
    ├── DOCKED_OUTPUT set?
    │       YES → batocera-resolution setOutput <DOCKED_OUTPUT>
    │             settings_output2 = ""
    │             settings_output3 = ""
    │       NO  → use settings from batocera.conf normally
    ↓
Primary configured output BLANK, docked output active
```

## Flow: Fixed Behavior

```
_detect_docked_output()
    │
    ├── Read global.videooutput / videooutput2 / videooutput3 → KNOWN_OUTPUTS
    │
    ├── KNOWN_OUTPUTS non-empty?
    │       YES → log "Skipping docked detection"
    │             rm -f /var/run/batocera-docked
    │             return 0   ← EXIT EARLY, nothing changes
    │
    ├── KNOWN_OUTPUTS empty? (device never configured)
    │       Use status file as baseline
    │       Compare connected outputs → flag unknowns as docked
    │       (genuine handheld dock use case)
```

## Key Components

| Component | Path | Role |
|-----------|------|------|
| udev rule | `/etc/udev/rules.d/80-switch-screen.rules` | Triggers checker on DRM hotplug |
| Screen checker | `/usr/bin/batocera-switch-screen-checker` | Detects docked state, writes flag |
| Docked flag | `/var/run/batocera-docked` | Contains external output name when docked |
| ES standalone | `/usr/bin/emulationstation-standalone` | Reads flag, overrides output if set |
| Status file | `/var/run/batocera-switch-screen-checker-status` | Baseline of known outputs at init |
| batocera.conf | `/userdata/system/batocera.conf` | User's configured outputs |

## Why PC/Steam Deck Is Different from RP5

| Device | Expected behavior when second display connected |
|--------|------------------------------------------------|
| RP5 / handheld | Switch entirely to external display (dock mode) |
| PC | Keep existing display, add second as optional multi-screen |
| Steam Deck | Keep eDP-1 as primary unless user explicitly switches |

The broken code applied the RP5 behavior universally. The fix correctly gates it behind "no configured outputs" which is only true on a device that has never been set up — i.e., first boot into a dock.
