# 03 - CRT mode, pre mode switcher (fix-wayland)

**Date:** (fill when captured)  
**Host:** (e.g. `batocera.local`, SSH)  
**Compositor / session:** **X11** on **CRT** syslinux entry (**`/crt/linux`**, **`/proc/cmdline`** includes **`drm.edid_firmware`** / **`video=…`** as installed)  
**Scope:** [fix-wayland README](README.md) — post-install **CRT** baseline **after** [02](02-crt-script-install-pre-reboot.md) reboot, **before** any **HD (Wayland) ↔ CRT (X11)** mode switcher round trip. Same checkpoint idea as [../pre-fix/02-crt-mode-pre-mode-switcher.md](../pre-fix/02-crt-mode-pre-mode-switcher.md), on the **dual-boot** tree.

## Definition

- **CRT Script** install completed on the **X11** side and system **rebooted** into stable **CRT** boot (typically **`DEFAULT crt`** still, or **`DEFAULT`** returned to **HD** but you manually chose **CRT** for this capture; **state which** in **Notes**).
- **Single** **X11** **CRT** session: **15 kHz** path on the configured connector (e.g. **DP-1**).
- **No** mode switcher transition to **Wayland HD** exercised yet in this file (fresh **CRT** profile only).

## Commands run

```bash
batocera-version
cat /proc/cmdline

batocera-settings-get global.videooutput
batocera-settings-get global.videomode

stat /lib/firmware/edid/generic_15.bin
cat /userdata/system/logs/BootRes.log

grep -E 'EDID build|Parity decision|EDID PRE-bump|EDID post|Amd_NvidiaND|Intel_Nvidia|TYPE_OF_CARD|matrix|Monitor Type|Boot Resolution' \
  /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -60

edid-decode /lib/firmware/edid/generic_15.bin 2>/dev/null | head -55

DISPLAY=:0.0 xrandr | head -50
head -8 /userdata/system/videomodes.conf

grep DEFAULT /boot/boot/syslinux.cfg
grep APPEND /boot/boot/syslinux.cfg
```

## Captured output

*(Paste blocks: **version**, **cmdline**, **BootRes**, filtered **BUILD**, **edid-decode** head, **xrandr** primary, **videomodes.conf** head, **syslinux** **DEFAULT** vs which entry you booted.)*

## Notes

- If **`DEFAULT`** in **syslinux** is **Wayland HD** but you booted **CRT** via menu once, say so; **`03`** is about **runtime** **CRT** state, not only **DEFAULT** line.

## Next

- **04:** [04-mode-switcher-crt-to-hd-pre-reboot.md](04-mode-switcher-crt-to-hd-pre-reboot.md)

## Reference

- [02-crt-script-install-pre-reboot.md](02-crt-script-install-pre-reboot.md)  
- X11-only analogue: [../pre-fix/02-crt-mode-pre-mode-switcher.md](../pre-fix/02-crt-mode-pre-mode-switcher.md)
