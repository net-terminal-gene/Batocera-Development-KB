# 04 - Mode switcher CRT→HD, pre-reboot (fix-wayland)

**Date:** (fill when captured)  
**Host:** (e.g. `batocera.local`, SSH)  
**Compositor / session:** Still **X11** **CRT** session (**`/crt/linux`** live until you reboot); config may already target **Wayland HD** output for next boot.  
**Scope:** [fix-wayland README](README.md) — snapshot **after** using the mode switcher (or equivalent) to move **CRT → HD (Wayland)**, **before** reboot. Same checkpoint idea as [../pre-fix/03-mode-switcher-crt-to-hd-pre-reboot.md](../pre-fix/03-mode-switcher-crt-to-hd-pre-reboot.md), on the **dual-boot** tree.

## Definition

- Follows [03-crt-mode-pre-mode-switcher.md](03-crt-mode-pre-mode-switcher.md) baseline.
- **Pre-reboot:** **`batocera.conf`** (and any switcher **mode_backups** / logs) already reflect the **HD** target (**HDMI-***, **eDP-1**, etc., per your install), while **`xrandr`** and **`/proc/cmdline`** may still show the **current** **CRT** **X11** boot until the next power cycle.
- **Contrast with X11-only pre-fix:** here **HD** means the **Wayland** **HD** boot entry (**`/boot/linux`**) when you reboot, not only moving primary output on the same kernel.

## Commands run

```bash
batocera-version
cat /proc/cmdline

batocera-settings-get global.videooutput
batocera-settings-get global.videomode
grep -n global.video /userdata/system/batocera.conf
grep -n global.videomode /userdata/system/batocera.conf

DISPLAY=:0.0 xrandr | head -45

grep DEFAULT /boot/boot/syslinux.cfg
grep APPEND /boot/boot/syslinux.cfg
grep LABEL /boot/boot/syslinux.cfg | head -10

test -f /boot/crt/linux && echo crt_linux=yes || echo crt_linux=no
test -f /boot/linux && echo hd_linux=yes || echo hd_linux=no

ls -la /userdata/system/Batocera-CRT-Script/Geometry_modeline/mode_switcher_modules/ 2>/dev/null
tail -80 /userdata/system/logs/display.log 2>/dev/null
```

## Captured output

*(Paste: **version**, **cmdline**, **batocera.conf** video lines, **xrandr**, **syslinux** **DEFAULT** / **CRT** vs **HD** labels, **mode_switcher** / **display.log** tails, note whether **save** in UI completed.)*

## Notes

- Record **Config check** / **Boot:** lines from switcher logs if your build prints them (empty **Boot_** vs saved **CRT** boot resolution matters for **HD→CRT** return).
- After reboot, **05** captures **HD Wayland** first frame: [05-hd-mode-pre-mode-switcher.md](05-hd-mode-pre-mode-switcher.md).

## Next

- **05:** [05-hd-mode-pre-mode-switcher.md](05-hd-mode-pre-mode-switcher.md)

## Reference

- [03-crt-mode-pre-mode-switcher.md](03-crt-mode-pre-mode-switcher.md)  
- X11-only analogue: [../pre-fix/03-mode-switcher-crt-to-hd-pre-reboot.md](../pre-fix/03-mode-switcher-crt-to-hd-pre-reboot.md)
