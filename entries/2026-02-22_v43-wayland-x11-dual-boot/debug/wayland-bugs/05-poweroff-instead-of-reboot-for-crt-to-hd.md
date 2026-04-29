# 05 — Poweroff Instead of Reboot for Dual-Boot CRT-to-HD

**Date:** 2026-02-21
**Status:** Fix implemented

## Problem

When mode_switcher switches CRT (X11) to HD (Wayland) and calls `reboot`, the Steam Deck shows a black screen with no splash video and is unreachable via SSH. A manual power cycle (cold boot) is required to recover.

The GPU's DRM hardware registers retain CRT-specific state (custom EDID for DP-1 at 15kHz interlaced timing) through a warm reboot. The Wayland kernel fails to cleanly reinitialize eDP-1.

The existing X11-level teardown (`batocera-resolution setOutput eDP-1` calls `xrandr --output DP-1 --off` internally) is insufficient because the stale state is below the X11 layer, at the DRM/KMS kernel hardware register level.

## Fix

Replace `reboot` with `poweroff` for dual-boot CRT-to-HD transitions. A full shutdown forces a complete GPU power cycle when the user presses the power button to boot back up.

### Files Changed

**`mode_switcher.sh`** (line 207):
```bash
if is_dualboot_system && [ "$target_mode" = "hd" ]; then
    poweroff
else
    reboot
fi
```

**`mode_switcher_modules/04_user_interface.sh`** (`show_success_message`):
- Added dual-boot-specific HD mode message: "The system will now SHUT DOWN. Press the POWER BUTTON to boot into Wayland HD Mode."
- Single-boot HD mode keeps the existing "System will reboot now..." message.

### Scope

| Transition | System | Behavior |
|-----------|--------|----------|
| CRT to HD | Dual-boot | `poweroff` (new) |
| HD to CRT | Dual-boot | `reboot` (unchanged) |
| CRT to HD | Single-boot | `reboot` (unchanged) |
| HD to CRT | Single-boot | `reboot` (unchanged) |

## Alternatives Considered

- **DRM teardown + reboot**: Already happening via `batocera-resolution setOutput` — didn't prevent the black screen. DPMS off and killing X are also X11-level.
- **GPU PCI device reset** (`echo 1 > /sys/bus/pci/devices/<id>/reset`): Risk of system hang while GPU is actively driving display.
- **Unload amdgpu kernel module**: May fail with "module in use" if processes hold GPU handles.
