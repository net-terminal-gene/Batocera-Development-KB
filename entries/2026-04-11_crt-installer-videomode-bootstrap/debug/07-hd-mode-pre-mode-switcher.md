# Debug 07 — HD Mode (Post CRT→HD Reboot), Pre Mode Switcher

## Date: 2026-04-13

## Script Version

**CRT-Script-04-03** — original script WITHOUT videomode-bootstrap changes.

## Action

Rebooted from CRT mode into HD/Wayland mode (after Mode Switcher CRT→HD switch). System is running in Wayland. Mode Switcher has NOT been run yet in this HD session — capturing the pre-switch baseline.

## Boot Environment

```
/proc/cmdline:
BOOT_IMAGE=/boot/linux label=BATOCERA console=tty3 quiet loglevel=0
vt.global_cursor_default=0 initrd=/boot/initrd.gz
```

Standard Wayland boot entry. No CRT kernel parameters.

## batocera.conf State (Restored by Mode Switcher for HD Boot)

```
global.videomode   = (empty)
global.videooutput = eDP-1
es.resolution      = (empty)
```

The mode switcher restored HD values correctly. `global.videooutput=eDP-1` is correct for HD. `global.videomode` and `es.resolution` are empty — no HD video mode was set (as expected, since none was set in the original Wayland session).

## Display State (Wayland)

```
batocera-drminfo current:
  0.0:EDP 800x1280 60Hz (800x1280*)   ← eDP-1, Steam Deck display, ACTIVE
  1.0:DISPLAYPORT 640x480 60Hz (640x480)  ← DP-1, DAC connected, 640x480 only

batocera-resolution currentMode = (empty — does not work in Wayland)
batocera-resolution listModes   = (empty — does not work in Wayland)
```

Steam Deck display is primary at 800x1280@60Hz. DP-1 shows only 640x480 (EDID firmware not active in Wayland boot — it's a CRT kernel parameter only).

## Key Observations

1. **HD restore was clean.** `global.videooutput=eDP-1`, `global.videomode=empty` — exactly what was in batocera.conf before the original CRT install. The mode switcher correctly returned to the pre-install HD state.

2. **DP-1 reverts to 640x480 in Wayland.** The `drm.edid_firmware=DP-1:edid/ms929.bin` kernel parameter only applies in the CRT boot. In Wayland boot, the DAC reports generic 640x480 capability only.

3. **batocera-resolution is non-functional in Wayland.** Both `currentMode` and `listModes` return empty — consistent with stages 00–02.

4. **This state is correct baseline for HD→CRT switch test.** The mode switcher will switch back to CRT from this state. It should restore `global.videooutput=DP-1` and the CRT batocera.conf from the crt_mode backup.

## Next Stage

→ `08-mode-switcher-hd-to-crt-pre-reboot.md` — Run Mode Switcher HD→CRT switch, capture state before CRT reboot.
