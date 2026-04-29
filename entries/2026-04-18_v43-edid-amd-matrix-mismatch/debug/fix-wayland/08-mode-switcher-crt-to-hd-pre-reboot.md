# 08 - Mode switcher CRT→HD, pre-reboot (second pass, fix-wayland)

**Date:** (fill when captured)  
**Host:** (e.g. `batocera.local`, SSH)  
**Compositor / session:** Still **X11** **CRT** (**`/crt/linux`**) until reboot; **`batocera.conf`** may already target **Wayland HD** output.  
**Scope:** [fix-wayland README](README.md) — **second** **CRT→HD** via mode switcher (**target: hd**, save), **after** [07-crt-mode-pre-mode-switcher.md](07-crt-mode-pre-mode-switcher.md), **before** reboot to **Wayland**. Compare first pass: [04-mode-switcher-crt-to-hd-pre-reboot.md](04-mode-switcher-crt-to-hd-pre-reboot.md). Same idea as [../pre-fix/08-mode-switcher-crt-to-hd-pre-reboot.md](../pre-fix/08-mode-switcher-crt-to-hd-pre-reboot.md), on **dual-boot**.

## Definition

- **Pre-reboot:** persisted **HD** connector + **`videomode=default`** (typical) vs **live** **xrandr** still **CRT**-primary until reboot.
- **`mode_backups/`** usually populated from the earlier **HD** leg; contrast **Config check** / **Boot:** lines to **04**.

## Commands run

```bash
batocera-version
cat /proc/cmdline

batocera-settings-get global.videooutput
batocera-settings-get global.videomode
grep -n global.video /userdata/system/batocera.conf
grep -n global.videomode /userdata/system/batocera.conf

DISPLAY=:0.0 xrandr | head -40

grep DEFAULT /boot/boot/syslinux.cfg
grep APPEND /boot/boot/syslinux.cfg | head -8

cat /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/video_output.txt 2>/dev/null
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_output.txt 2>/dev/null
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_mode.txt 2>/dev/null

grep -E 'Mode switch|Config check|Saving selections|Boot:' /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -25

tail -30 /userdata/system/logs/display.log 2>/dev/null
```

## Captured output

*(Paste: **version**, **cmdline**, **batocera.conf**, **xrandr**, **mode_backups**, **BUILD**, **syslinux**, **display.log**.)*

## Next

- **09:** [09-hd-mode-pre-mode-switcher.md](09-hd-mode-pre-mode-switcher.md)

## Reference

- [07-crt-mode-pre-mode-switcher.md](07-crt-mode-pre-mode-switcher.md)  
- First **CRT→HD** pre-reboot: [04-mode-switcher-crt-to-hd-pre-reboot.md](04-mode-switcher-crt-to-hd-pre-reboot.md)  
- X11-only analogue: [../pre-fix/08-mode-switcher-crt-to-hd-pre-reboot.md](../pre-fix/08-mode-switcher-crt-to-hd-pre-reboot.md)
