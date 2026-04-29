# Debug 02 — DP-1 Plugged In (Wayland/HD Mode)

## Date: 2026-04-13

## Action

User plugged the Cable Matters DP-to-VGA DAC into the Steam Deck (DP-1 port) while system is running in Wayland/HD mode.

## DRM Connector Status (Post-Plug)

```
/sys/class/drm/card0-DP-1/status  = connected
/sys/class/drm/card0-eDP-1/status = connected
```

Both outputs are reported as connected at the DRM layer.

## batocera.conf State (Unchanged by Plug Event)

```
global.videooutput = eDP-1       (set by user in stage 01)
global.videomode   = (empty)
```

Plugging in DP-1 did not modify batocera.conf — correct, no Batocera configuration change expected from a hotplug event alone.

## Resolution ID State (Wayland, Post-Plug)

```
batocera-resolution listModes  = (empty — does not work in Wayland)
batocera-resolution currentMode = (empty)
es.resolution                  = (empty)
global.videomode               = (empty)
```

### batocera-drminfo current output (Wayland)
```
0.0:EDP 800x1280 60Hz (800x1280*)   ← eDP-1, ACTIVE
1.0:DISPLAYPORT 640x480 60Hz (640x480)  ← DP-1, connected but only sees 640x480
```

### DRM sysfs modes
```
eDP-1: 800x1280, 800x600, 640x480, 256x160
DP-1:  640x480   ← no EDID firmware loaded yet; DAC reports generic VGA capability only
```

**Key observation:** DP-1 only reports `640x480` because the ms929.bin EDID firmware has not been installed yet. The CRT Script installs the EDID firmware (`drm.edid_firmware=DP-1:edid/ms929.bin`) into the CRT kernel boot entry. Until that happens, the kernel has no way to know this is a 15kHz CRT and the DAC only advertises standard VGA modes.

## Notes

- SSH was unresponsive briefly after the hotplug event (system was processing the DP-1 connection). This is expected — the Wayland compositor handles the hotplug.
- Both eDP-1 and DP-1 are now `connected` at the DRM layer. Wayland compositor will mirror or extend to DP-1.
- The CRT DAC is reporting as connected, which means the kernel sees the display. The EDID firmware (`ms929.bin`) is not loaded yet — that only happens after the CRT script installs it.

## Next Stage

→ `03-script-run-no-bootstrap.md` — Run the original CRT script (no bootstrap changes), capture batocera.conf + backup state post-install.
