#!/bin/bash
# Attempted fix: Steam Deck specific (eDP-1 hardcoded)
# REJECTED: Not universal across all Wayland devices
# This version queries eDP-1 position via wlr-randr and positions xterm with
# explicit geometry. Works for Steam Deck but breaks on devices without eDP-1.

#
# ES launcher shim for the HD/CRT Mode Switcher.
# Runs as a "game" from EmulationStation; opens an xterm and runs mode_switcher.sh inside it.
#
# WAYLAND-EXCLUSIVE FIX:
# In Wayland/HD mode with an external output connected, the Batocera standalone
# script may extend the desktop to that output. xterm -maximized then opens on
# the extended desktop instead of the internal display.
#
# Solution: Query the internal display (eDP-1) position from wlr-randr and use
# explicit geometry to position xterm there. Falls back to -maximized for
# single-display or CRT/X11 modes.

XTERM_OPTS="-maximized"

# Wayland check: must have WAYLAND_DISPLAY (emulatorlauncher exports it)
if [ -n "$WAYLAND_DISPLAY" ]; then
    # Second check: NOT in CRT boot mode (CRT mode uses BOOT_IMAGE=/crt/)
    if ! grep -q 'BOOT_IMAGE=/crt/' /proc/cmdline 2>/dev/null; then
        # We're in Wayland/HD mode; check if wlr-randr is available
        if command -v wlr-randr >/dev/null 2>&1; then
            # Query eDP-1's position and resolution from wlr-randr
            _EDPI_DATA=$(wlr-randr 2>/dev/null | awk '
                /^eDP-1 / { in_edpi=1; next }
                /^[A-Z]/ && in_edpi { in_edpi=0; exit }
                in_edpi {
                    if (/Position:/) {
                        split($2, a, ","); pos_x=a[1]; pos_y=a[2]
                    }
                    if (/^    [0-9]/) {  # First mode line (indented, starts with digit)
                        split($1, res, "x"); width=res[1]; height=res[2]
                        cols=int(width/9); rows=int(height/17)
                        print pos_x "," pos_y "," cols "," rows
                        exit
                    }
                }
            ')
            
            if [ -n "$_EDPI_DATA" ]; then
                IFS="," read -r _X _Y _COLS _ROWS <<< "$_EDPI_DATA"
                # Build geometry to fill eDP-1 exactly (no overflow)
                if [ -n "$_X" ] && [ -n "$_Y" ] && [ -n "$_COLS" ] && [ -n "$_ROWS" ]; then
                    XTERM_OPTS="-borderwidth 0 -geometry ${_COLS}x${_ROWS}+${_X}+${_Y}"
                fi
            fi
        fi
    fi
fi

# Launch xterm with calculated geometry (Wayland) or maximized (fallback)
DISPLAY=:0.0 xterm -fs 15 $XTERM_OPTS \
    +sb \
    -fg white -bg black -fa "DejaVuSansMono" -en UTF-8 \
    -e /userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher.sh
