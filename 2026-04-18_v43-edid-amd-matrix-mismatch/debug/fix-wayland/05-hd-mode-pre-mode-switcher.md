# 05 - HD mode, pre mode switcher (fix-wayland)

**Date:** (fill when captured)  
**Host:** (e.g. `batocera.local`, SSH)  
**Compositor / session:** **Wayland** **HD** entry (**`/boot/linux`**, **`BOOT_IMAGE=/boot/linux`** on **`/proc/cmdline`**, no **`/crt/`** **initrd** path).  
**Scope:** [fix-wayland README](README.md) — **after** reboot from [04-mode-switcher-crt-to-hd-pre-reboot.md](04-mode-switcher-crt-to-hd-pre-reboot.md), **desktop / ES on HD output**, **before** any mode switcher step back toward **CRT**. Same checkpoint idea as [../pre-fix/04-hd-mode-pre-mode-switcher.md](../pre-fix/04-hd-mode-pre-mode-switcher.md), but **Wayland** **HD** boot, not **X11** **HDMI-only**.

## Definition

- **`global.videooutput`** / **`global.videomode`** match the **HD** target saved in **04** (now applied after reboot).
- **No** switcher transition back to **CRT** yet in this file (baseline for “HD session” before **HD→CRT** tests).
- **Do not** assume **`DISPLAY=:0.0 xrandr`** on pure **Wayland**; use **`batocera-resolution`** (or your build’s documented equivalents) plus **process** list (**labwc**, etc.).

## Commands run

```bash
batocera-version
cat /proc/cmdline

batocera-settings-get global.videooutput
batocera-settings-get global.videomode
grep -n global.video /userdata/system/batocera.conf
grep -n global.videomode /userdata/system/batocera.conf

batocera-resolution listOutputs 2>/dev/null
ps aux | grep -E '[l]abwc|[w]eston|[X]org' | head -8

grep DEFAULT /boot/boot/syslinux.cfg
grep APPEND /boot/boot/syslinux.cfg | head -6

stat /lib/firmware/edid/generic_15.bin 2>&1
ls -la /lib/firmware/edid/ 2>/dev/null

tail -40 /userdata/system/logs/display.log 2>/dev/null
```

## Captured output

*(Paste: **version**, **cmdline** (**confirm** **HD** kernel path), **batocera.conf** video lines, **listOutputs** / compositor, **syslinux** **DEFAULT**, **EDID** path **stat**, **display.log** tail.)*

## Notes

- If **`syslinux`** **`DEFAULT`** is still **`crt`** but you landed on **Wayland** because you picked **HD** at the boot menu, record that ( **`DEFAULT`** vs **actual boot** ).
- **CRT** **EDID** on **`APPEND`** for **DP-1** while on **HD** may still appear on the **Wayland** label; note whether **`drm.edid_firmware`** is present on the **batocera** **APPEND** line you actually booted.

## Next

- **06:** [06-mode-switcher-hd-to-crt-pre-reboot.md](06-mode-switcher-hd-to-crt-pre-reboot.md)

## Reference

- [04-mode-switcher-crt-to-hd-pre-reboot.md](04-mode-switcher-crt-to-hd-pre-reboot.md)  
- X11-only analogue: [../pre-fix/04-hd-mode-pre-mode-switcher.md](../pre-fix/04-hd-mode-pre-mode-switcher.md)
