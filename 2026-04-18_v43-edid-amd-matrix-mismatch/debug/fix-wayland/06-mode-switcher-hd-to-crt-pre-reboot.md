# 06 - Mode switcher HD→CRT, pre-reboot (fix-wayland)

**Date:** (fill when captured)  
**Host:** (e.g. `batocera.local`, SSH)  
**Compositor / session:** Still **Wayland HD** (**`/boot/linux`**) until reboot; **userdata** may already request **CRT** output / mode for next **X11** **CRT** boot.  
**Scope:** [fix-wayland README](README.md) — **after** **HD→CRT** in the mode switcher (target **CRT**, save), **before** reboot into **`/crt/linux`**. Same checkpoint idea as [../pre-fix/06-mode-switcher-hd-to-crt-pre-reboot.md](../pre-fix/06-mode-switcher-hd-to-crt-pre-reboot.md), on the **dual-boot** tree.

## Definition

- Follows [05-hd-mode-pre-mode-switcher.md](05-hd-mode-pre-mode-switcher.md).
- **Pre-reboot:** **`batocera.conf`** (and **`mode_backups/**`) can already list **CRT** connector and **CRT** videomode; **live** session may still be **Wayland** on **HD** until power cycle selects **CRT** entry (or **`DEFAULT crt`** takes effect).

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

ls -la /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/ 2>/dev/null
ls -la /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/ 2>/dev/null
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/hd_mode/video_settings/video_output.txt 2>/dev/null
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_output.txt 2>/dev/null
cat /userdata/Batocera-CRT-Script-Backup/mode_backups/crt_mode/video_settings/video_mode.txt 2>/dev/null

grep -E 'Mode switch|Config check|Saving selections|Converting boot|Boot:' /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -35

tail -40 /userdata/system/logs/display.log 2>/dev/null
```

## Captured output

*(Paste: **version**, **cmdline** (still **HD** path?), **batocera.conf**, **listOutputs** vs saved **CRT**, **mode_backups** file contents, **BUILD** switcher lines, **syslinux**, **display.log**.)*

## Notes

- If **`videomode`** is **`default`** on **HD**, **Boot:** resolution lines in logs may be empty until a **CRT** boot was saved once; compare to **`pre-fix/05`** in the same session tree.

## Next

- **07:** [07-crt-mode-pre-mode-switcher.md](07-crt-mode-pre-mode-switcher.md)

## Reference

- [05-hd-mode-pre-mode-switcher.md](05-hd-mode-pre-mode-switcher.md)  
- X11-only analogue: [../pre-fix/06-mode-switcher-hd-to-crt-pre-reboot.md](../pre-fix/06-mode-switcher-hd-to-crt-pre-reboot.md)
