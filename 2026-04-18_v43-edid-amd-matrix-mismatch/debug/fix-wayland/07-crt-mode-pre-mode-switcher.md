# 07 - CRT mode, pre mode switcher (after HD round trip, fix-wayland)

**Date:** (fill when captured)  
**Host:** (e.g. `batocera.local`, SSH)  
**Compositor / session:** **X11** **CRT** boot (**`/crt/linux`**, **`/proc/cmdline`** typically includes **`drm.edid_firmware`** / **`video=…`** for **CRT** connector).  
**Scope:** [fix-wayland README](README.md) — **after reboot** from [06-mode-switcher-hd-to-crt-pre-reboot.md](06-mode-switcher-hd-to-crt-pre-reboot.md) (**HD→CRT** switcher save, then reboot). Second **CRT** baseline **before** another switcher action; compare to [03-crt-mode-pre-mode-switcher.md](03-crt-mode-pre-mode-switcher.md). Same idea as [../pre-fix/07-crt-mode-pre-mode-switcher.md](../pre-fix/07-crt-mode-pre-mode-switcher.md), on **dual-boot**.

## Definition

- **CRT** live again on the configured connector (e.g. **DP-1**) with **CRT** videomode in **`batocera.conf`**.
- **No** further **HD↔CRT** switcher transition in this file (post–**HD** round trip **CRT** snapshot only).

## Commands run

```bash
batocera-version
cat /proc/cmdline

batocera-settings-get global.videooutput
batocera-settings-get global.videomode
grep -n global.video /userdata/system/batocera.conf
grep -n global.videomode /userdata/system/batocera.conf

DISPLAY=:0.0 xrandr | head -35
cat /userdata/system/logs/BootRes.log

grep -E 'EDID build|Parity decision|EDID PRE-bump|EDID post|Mode switch|Config check|Saving selections|TYPE_OF_CARD|Boot Resolution' \
  /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -45

stat /lib/firmware/edid/generic_15.bin 2>&1
edid-decode /lib/firmware/edid/generic_15.bin 2>/dev/null | head -45

grep DEFAULT /boot/boot/syslinux.cfg
grep APPEND /boot/boot/syslinux.cfg | head -8
```

## Captured output

*(Paste: **version**, **cmdline**, **batocera.conf**, **xrandr**, **BootRes**, filtered **BUILD**, **EDID** **stat** / **edid-decode**, **syslinux**.)*

## Notes

- Diff **03** vs **07** for **EDID** horizontal resolution, **matrix** menu parity, and **`Boot_*`** / **`mode_backups`** consistency after **Wayland** **HD** leg.

## Next

- **08:** [08-mode-switcher-crt-to-hd-pre-reboot.md](08-mode-switcher-crt-to-hd-pre-reboot.md)

## Reference

- [06-mode-switcher-hd-to-crt-pre-reboot.md](06-mode-switcher-hd-to-crt-pre-reboot.md)  
- First **CRT** baseline: [03-crt-mode-pre-mode-switcher.md](03-crt-mode-pre-mode-switcher.md)  
- X11-only analogue: [../pre-fix/07-crt-mode-pre-mode-switcher.md](../pre-fix/07-crt-mode-pre-mode-switcher.md)
