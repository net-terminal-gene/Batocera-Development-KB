# Debug — CRT Mode Switcher: eDP-1 Blank in Wayland

## Verification Commands

```bash
# Check if mode switcher is running headlessly
ps aux | grep mode_switcher

# Check what the display log says about output state
cat /userdata/system/logs/display.log | tail -30

# Check emulatorlauncher launch log
cat /userdata/system/logs/es_launch_stdout.log | tail -30

# Check if DP-1 is causing extended desktop
batocera-drminfo /dev/dri/card0 current

# Check if backglass is running on DP-1
ps aux | grep backglass
```

## Observed During Live Testing (2026-04-13)

- System: Steam Deck, Wayland/HD mode, DP-1 (Cable Matters DAC) plugged in
- Trigger: Launched Mode Switcher from ES CRT game list
- Result: eDP-1 blank, mode_switcher.sh running headlessly (PID via emulatorlauncher)

```
emulatorlauncher -system CRT -rom /userdata/roms/crt/mode_switcher.sh
python3 batocera-backglass-window --x 1280 --y 0 --width 640 --height 480
```

## Failure Signs

| Symptom | Likely Cause |
|---------|--------------|
| eDP-1 blank after launching mode switcher from HD mode | mode_switcher.sh running headlessly in Wayland, ES hidden in game mode |
| Backglass on DP-1, nothing on eDP-1 | DP-1 extended desktop + ES game mode |
| "Wayland compositor not ready. Exiting gracefully." in display.log | Component in launch chain trying to create Wayland surface during transition |
| Mode switcher process running but no interaction possible | Shell script UI has no window in Wayland |
