# Design — BUA Steam Big Picture Fix

## Architecture

### Launcher Flow

```
EmulationStation → Steam_Big_Picture.sh → Launcher "-gamepadui"
                                               ↓
                                    export DISPLAY, XAUTHORITY, HOME, ...
                                    (optional: DRI_PRIME for dual-GPU)
                                               ↓
                                    wmctrl -r EmulationStation -b add,hidden  (optional)
                                               ↓
                                    create-steam-launchers.sh &
                                               ↓
                                    /userdata/system/add-ons/steam/steam -gamepadui &
                                               ↓
                                    while ! wmctrl -l | grep -qiE "Steam|Big.Picture|Big-Picture"; sleep 1; done
                                               ↓
                                    wmctrl bring to foreground / fullscreen (optional)
                                               ↓
                                    while wmctrl detects Steam; sleep 2; done
                                               ↓
                                    pkill -f steam; curl reloadgames
```

### Key Components

| Component | Purpose |
|-----------|---------|
| `Launcher` | Main script at `/userdata/system/add-ons/steam/Launcher` — deployed from `steam/extra/Launcher` (old) or `steam/extra/Launcher2` (latest) |
| `steam.sh` | Old install script — downloads Launcher from GitHub |
| `steam2.sh` | Latest install script (BUA installer) — downloads Launcher2 from GitHub |
| `Steam_Big_Picture.sh` | ROM launcher in `/userdata/roms/steam/` — invokes `Launcher "-gamepadui"` |
| wmctrl | X11 window manager control — detects Steam window, manages focus/fullscreen |

### Required Environment for wmctrl

wmctrl requires both:

- `DISPLAY=:0.0` — which X server
- `XAUTHORITY=/var/run/xauth` — X11 authentication (Batocera's default location)

Without XAUTHORITY, `wmctrl -l` fails with "Cannot open display" and the Launcher exits after timeout.

### Window Title Localization

Steam Big Picture window title varies by locale:

| Locale | Title |
|--------|-------|
| English | "Steam" or "Big Picture" |
| German | "Big-Picture-Modus" |

Fix: use extended regex `grep -qiE "Steam|Big.Picture|Big-Picture"` to match all variants.

### Dual-GPU (DRI_PRIME)

On systems with iGPU + dGPU (e.g. AMD Renoir + RX 6600 XT), Steam may default to iGPU. Force dGPU:

```bash
export DRI_PRIME=pci-0000_12_00_0  # PCI slot is hardware-specific
```

Options for implementation:

- **Config file:** `/userdata/system/configs/steam/steam.conf` with `DRI_PRIME=pci-...` — Launcher sources it if present
- **Auto-detect:** Script to find secondary GPU via `/sys/class/drm/card*/device/` and set DRI_PRIME
- **Docs only:** Wiki instructions for manual override
