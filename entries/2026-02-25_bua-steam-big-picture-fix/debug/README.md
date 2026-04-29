# Debug — BUA Steam Big Picture Fix

## Verification

```bash
# Check what windows are open on the display
export DISPLAY=:0
export XAUTHORITY=/var/run/xauth
wmctrl -l

# Check Steam launch log
tail -50 /userdata/system/add-ons/steam/.local/share/Steam/logs/console-linux.txt

# Check Batocera / EmulationStation launch log
tail -100 /userdata/system/logs/es_launch_stdout.log

# Check running Steam processes
pgrep -fa steam
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| Returns to menu immediately | XAUTHORITY missing — wmctrl can't connect to X11 |
| Black screen with cursor, then exits ~13s | Wrong GPU — Steam rendering on iGPU, crashes |
| Waits 60–240s then returns to menu | Localized window title — wmctrl never finds "Steam" |
| wmctrl -l shows "Cannot open display" | XAUTHORITY not set in Launcher environment |
| Steam works via SSH but not from ES | Different env when launched from ES — missing exports |

## Pre/Post-Fix Checklist

1. Confirm Steam installed via BUA at `/userdata/system/add-ons/steam/`
2. Confirm Launcher path: `/userdata/system/add-ons/steam/Launcher` (steam2.sh installs Launcher2 here)
3. Note Batocera system language (affects window title)
4. On dual-GPU: identify dGPU PCI slot if DRI_PRIME fix needed
5. **Local QA:** Copy `steam/extra/Launcher2` to device: `scp steam/extra/Launcher2 root@batocera.local:/userdata/system/add-ons/steam/Launcher`
