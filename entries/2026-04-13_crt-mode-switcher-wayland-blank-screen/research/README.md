# Research — CRT Mode Switcher: eDP-1 Blank in Wayland

## Key Finding

`mode_switcher.sh` launches an xterm window:
```
xterm -fs 15 -maximized -fg white -bg black -fa DejaVuSansMono -en UTF-8
  -e bash -c DISPLAY=:0.0 /userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher.sh
```

The xterm IS visible -- but only when DP-1 is not connected. With DP-1 plugged in, the `--maximized` flag causes the window to be placed on the extended desktop (DP-1 at x=1280), off the Steam Deck screen.

**Confirmed by test:** Unplugging DP-1 → mode switcher appears correctly on eDP-1. DP-1 plugged in → xterm opens on DP-1 surface, eDP-1 appears blank.

## DP-1 Extended Desktop Sequence (from display.log)

```
setOutput: Queuing ON for eDP-1
setOutput: Queuing ON for DP-1
Executing: wlr-randr --output eDP-1 --on --output DP-1 --on
Standalone: Setting resolution for 'eDP-1' to '800x1280.60.00'.
Standalone: No resolution for 'DP-1'. Using minTomaxResolution-secure.
  → DP-1 stays at 640x480@59.94Hz
Standalone: Launching backglass on 'DP-1' with OffsetX=1280 and OffsetY=0 with Size=640 480
Standalone: Launching EmulationStation
```

## emulatorlauncher command (from es_launch_stdout.log)

```
command: ['/bin/bash', PosixPath('/userdata/roms/crt/mode_switcher.sh')]
env: XDG_SESSION_TYPE=wayland, WAYLAND_DISPLAY=wayland-0, DISPLAY=:0
```

No terminal wrapper. The script runs in background with no visible output.

## "Wayland compositor not ready" errors

Appeared twice in display.log during mode switcher launch. Likely from a component inside the launch chain trying to start a Wayland surface and failing during the ES→game transition window.

## Related

- In CRT/X11 mode the mode switcher presumably renders in a terminal (xterm or similar) because X11 is present.
- In Wayland mode, there is no equivalent — the script runs without a window.
- This may also affect other shell-script "games" in the CRT system category.

---

## KB maintenance (2026-04-16)

Supporting research for this session. **Outcome:** `../VERDICT.md`. **PR:** `../pr-status.md`.

Vault: `Vault-Batocera/wiki/sources/batocera-development-kb.md` (session table), `wiki/concepts/development-contributions.md`, `wiki/concepts/active-work.md`.

