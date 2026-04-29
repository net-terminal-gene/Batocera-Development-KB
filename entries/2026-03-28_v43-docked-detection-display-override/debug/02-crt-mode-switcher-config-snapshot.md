# Debug — CRT Mode Switcher Config Snapshot (April 2, 2026)

## Context

After confirming the docked detection fix works on dmanlfc's patched image, the HD/CRT Mode Switcher was run to switch back to CRT mode (before reboot). This captures the exact state written to `batocera.conf` by the mode switcher.

## batocera.conf — CRT Mode (post mode-switcher, pre-reboot)

```
global.videooutput=DP-1
global.videooutput2=none
global.videomode=769x576.50.00
es.resolution=769x576.50.00
es.customsargs=--screensize 769 576 --screenoffset 00 00
display.rotate=0
global.retroarch.crt_switch_resolution = "4"
global.retroarch.crt_switch_resolution_super = "0"
global.retroarch.crt_switch_hires_menu = "true"
global.retroarch.vrr_runloop_enable=0
global.retroarch.notification_show_refresh_rate = "false"
global.retroarch.video_font_size = 10
global.retroarch.settings_show_onscreen_display = "false"
global.smooth=0
global.shaderset=none
global.bezel=none
global.hud=none
CRT.emulator=sh
CRT.core=sh
mame.switchres=1
neogeo.switchres=1
```

## Output Name Observation

`global.videooutput=DP-1` — correctly using the xrandr name, not `DP-A-1` (DRM connector name).

This contrasts with the earlier HD mode issue where the mode switcher wrote `HDMI-A-2` instead of `HDMI-2`. The DRM vs xrandr name mismatch appears to be specific to HDMI outputs on this AMD GPU — DP outputs wrote the correct name. Needs further investigation to confirm whether this is consistent across hardware.

## /userdata/system/configs/ Contents

```
cannonball
dosbox
emulationstation
mame
multimedia_keys.conf
mupen64
retroarch
theforceengine
```

No `drm-no-edid.conf` or `99-crt.conf` present — CRT script is relying purely on `batocera.conf` settings and not dropping any custom X.org or DRM configs for this setup.

## Docked Detection Status

With `global.videooutput=DP-1` and `global.videooutput2=none` set, the fixed `batocera-switch-screen-checker` on this image will see `KNOWN_OUTPUTS` as non-empty and skip docked detection. HDMI-2 being physically connected should no longer trigger a takeover after reboot.
