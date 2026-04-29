# Design — CRT Mode Switcher: eDP-1 Blank in Wayland

## Fix: Suppress DP-1 Extended Desktop Before Spawning xterm

**File changed:** `Geometry_modeline/crt/mode_switcher.sh`

### Why This File

`crt/mode_switcher.sh` is the ES "game" shim — a one-liner that ES/emulatorlauncher executes
directly. It spawns the xterm and passes control to the actual `mode_switcher.sh`. Fixing the
window placement here is the right layer: before the terminal is created, ensure the display
topology gives the WM nowhere to put the window except eDP-1.

### Approach

Option 3 from plan.md: temporarily disable DP-1 via `wlr-randr` before spawning xterm, restore
it on exit.

Detection predicate: `WAYLAND_DISPLAY` is set (exported into the game process by ES running in
the Wayland session) AND `wlr-randr` is available AND DP-1 reports "enabled".

```
[crt/mode_switcher.sh invoked by emulatorlauncher]
    |
    +-- WAYLAND_DISPLAY set? AND wlr-randr available? AND DP-1 enabled?
    |       YES → wlr-randr --output DP-1 --off   (DP1_WAS_ON=1)
    |       NO  → no-op (single display, CRT mode, or DP-1 already off)
    |
    +-- DISPLAY=:0.0 xterm -fs 15 -maximized ... -e mode_switcher.sh
    |       (xterm now opens on eDP-1 — only connected display in X domain)
    |
    +-- xterm exits (user completed switch → reboots, OR user cancelled)
            DP1_WAS_ON=1? → wlr-randr --output DP-1 --on   (restore for cancel path)
            Reboot path: restore never runs, reboot reconfigures display
```

### Why Not Option 1 (geometry flag)

`xterm -geometry +0+0` positions the window but the Wayland WM (labwc) may still maximize it on
the wrong screen. Geometry hints in X11 are advisory; `-maximized` overrides them. Unreliable.

### Why Not Option 2 (suppress in Batocera standalone)

Would require changes to the Batocera standalone display script in `batocera.linux` repo — outside
the CRT Script. Correct long-term fix, but higher blast radius and requires a separate PR upstream.
This option should be filed as a follow-up improvement.

### Edge Cases

- CRT/X11 mode: `WAYLAND_DISPLAY` not set → block skipped entirely, zero behavior change
- Single-display (no DP-1): wlr-randr grep misses "enabled" → DP1_WAS_ON stays 0, no-op
- DP-1 already off (user unplugged): grep misses "enabled" → no-op
- wlr-randr not in PATH (shouldn't happen on Batocera Wayland): `command -v` guard → no-op
