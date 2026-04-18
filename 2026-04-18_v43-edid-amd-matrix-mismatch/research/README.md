# Research — v43 EDID Wrong Matrix on AMD Re-Install

## Hardware

- GPU: AMD RX6400 XT
- Display: 15 kHz CRT via DP→VGA on DP-1, HDMI monitor on HDMI-1
- Install: X11-only (NOT dual-boot — confirmed by user)
- Boot path: `BOOT_IMAGE=/boot/linux` (single CRT entry, no `/crt/linux` separation)

## Tester observations (full timeline)

| Boot | Mode | xrandr highlights |
|------|------|---|
| 1 (baseline CRT, fresh install) | CRT | DP-1 connected 485×364mm, preferred `769x576i 49.97 +`, active `769x576i 49.97*` |
| 2 (after HD switch) | HD | DP-1 disconnected, HDMI-1 connected `1920x1080 60` |
| 3 (back to CRT, after re-running install) | CRT | DP-1 connected 400×300mm, preferred `1280x240 59.68 +`, active `769x576 50.00*` |

ES at 769x576@50 in boot 3, looks visually correct. EDID metadata is wrong.

## Cmdline (HD mode)

```
BOOT_IMAGE=/boot/linux label=BATOCERA console=tty3 quiet loglevel=0 vt.global_cursor_default=0 mitigations=off  usbhid.jspoll=0 xpad.cpoll=0 drm.edid_firmware=DP-1:edid/generic_15.bin video=DP-1:e initrd=/boot/initrd.gz
```

By design in v43 single-boot — `drm.edid_firmware` and `video=DP-1:e` are always present. DP-1 reports `disconnected` in HD mode when CRT is physically off (boot 2 confirms), so the override does not cause a phantom display.

## v43 matrix branches (confirmed by user)

```
generic_15 320x240@60 640x480@30 768x576@25       # AMD/ATI / NVIDIA-prop / Intel-DP — line 3516
generic_15 1280x240@60 1280x480@30 1280x576@25    # Intel / NVIDIA-NOUV — line 3546
```

User picked option 3 (`768x576@25`) on his AMD card. EDID was rebuilt with the superres branch. Smoking gun.

## Why we know the install script was re-run, not just the mode switcher

User's exact wording:

> Now I coma back the CRT
> I choose Boot_576i 1:0:0:0 15KHz 50hz

The string `Boot_576i 1.0:0:0 15KHz 50Hz` only appears in two places:

1. v43 install script line 260 (welcome screen)
2. `videomodes.conf_generic_15` (boot resolution profile)

It does NOT appear in any `mode_switcher*.sh` file. Confirmed via grep across the entire `Geometry_modeline/` tree.

Therefore: between boot 2 and boot 3, the user re-ran `Batocera-CRT-Script-v43.sh`, not the mode switcher. The mode switcher cannot regenerate the EDID.

## Outstanding questions for tester

- Did `TYPE_OF_CARD` detect as `AMD/ATI` on the second install run?
- What `video_output` did the script see (DP-1 vs HDMI-1)?
- Was `Drivers_Nvidia_CHOICE` somehow set?
- File mtime on `/lib/firmware/edid/generic_15.bin` — does it line up with the second install run?
