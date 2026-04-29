# 09 - HD mode, pre mode switcher (second pass, fix-wayland)

**Date:** (fill when captured)  
**Host:** (e.g. `batocera.local`, SSH)  
**Compositor / session:** **Wayland** **HD** (**`/boot/linux`**, **`BOOT_IMAGE=/boot/linux`**, no **`/crt/`** **initrd** on **`/proc/cmdline`**).  
**Scope:** [fix-wayland README](README.md) — **after reboot** from [08-mode-switcher-crt-to-hd-pre-reboot.md](08-mode-switcher-crt-to-hd-pre-reboot.md) (second **CRT→HD** switcher). **HD** baseline **before** another switcher action. Parallels [05-hd-mode-pre-mode-switcher.md](05-hd-mode-pre-mode-switcher.md); same idea as [../pre-fix/09-hd-mode-pre-mode-switcher.md](../pre-fix/09-hd-mode-pre-mode-switcher.md), on **dual-boot**.

## Definition

- **`global.videooutput`** / **`global.videomode`** reflect **HD** target from **08** (now applied after reboot).
- **No** switcher transition toward **CRT** yet in this file.

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
grep APPEND /boot/boot/syslinux.cfg | head -8

stat /lib/firmware/edid/generic_15.bin 2>&1
ls -la /lib/firmware/edid/ 2>/dev/null

tail -40 /userdata/system/logs/display.log 2>/dev/null
```

## Captured output

*(Paste: **version**, **cmdline**, **batocera.conf**, **listOutputs** / compositor, **syslinux**, **EDID** **stat**, **display.log**.)*

## Notes

- Compare **05** vs **09** for **EDID** visibility, **`APPEND`** **CRT** firmware lines on **HD** label, and **switcher** log **Config check** / **Boot:** after a full **CRT** round trip.
- **10** can mirror **`pre-fix/10`**: second **HD→CRT** pre-reboot.

## Next

- **10:** (e.g. **`10-mode-switcher-hd-to-crt-pre-reboot.md`**) second **HD→CRT** switcher, **pre-reboot**.

## Reference

- [08-mode-switcher-crt-to-hd-pre-reboot.md](08-mode-switcher-crt-to-hd-pre-reboot.md)  
- First **HD** baseline: [05-hd-mode-pre-mode-switcher.md](05-hd-mode-pre-mode-switcher.md)  
- X11-only analogue: [../pre-fix/09-hd-mode-pre-mode-switcher.md](../pre-fix/09-hd-mode-pre-mode-switcher.md)
