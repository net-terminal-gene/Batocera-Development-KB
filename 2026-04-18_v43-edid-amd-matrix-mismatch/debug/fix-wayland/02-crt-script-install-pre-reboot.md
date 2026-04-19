# 02 - CRT script install pre-reboot (fix-wayland)

**Date:** (fill when captured)  
**Host:** (e.g. `batocera.local`, SSH)  
**Compositor / session:** **X11** (CRT boot entry: **`BOOT_IMAGE=/crt/linux`** or **`INITRD`** **`/crt/initrd-crt.gz`** on **`/proc/cmdline`**)  
**Scope:** [fix-wayland README](README.md) — **Phase 2** interactive CRT install on the **X11** side, **before** any installer-driven **reboot** (same idea as [../pre-fix/01-crt-script-pre-reboot.md](../pre-fix/01-crt-script-pre-reboot.md), but from **dual-boot** after [01](01-crt-x11-install-from-wayland-hd.md)).

## Definition

- Machine booted **CRT** entry (**`DEFAULT crt`** / **`LABEL crt`**) so **`/crt/linux`** is live.
- **CRT Script** re-run from **X11**; user completed menu choices for **CRT output** / **matrix** / **monitor** as applicable.
- This checkpoint is **pre-reboot**: **`xrandr`**, **`batocera.conf`**, **`BUILD_15KHz_Batocera.log`**, **`BootRes.log`**, **`/lib/firmware/edid/`**, and **`syslinux`** **`APPEND`** are captured **before** the script asks to **reboot** (or before you reboot to apply **EDID** / **kernel cmdline**).

## Commands run

```bash
batocera-version
cat /proc/cmdline
ps aux | grep -E '[X]org|labwc' | head -5
batocera-settings-get global.videooutput
batocera-settings-get global.videomode
DISPLAY=:0.0 xrandr 2>/dev/null | head -40

stat /lib/firmware/edid/generic_15.bin 2>&1
ls -la /lib/firmware/edid/ 2>/dev/null

tail -80 /userdata/system/logs/BUILD_15KHz_Batocera.log
tail -40 /userdata/system/logs/BootRes.log

grep -E 'DEFAULT|LABEL|APPEND' /boot/boot/syslinux.cfg
grep -E 'DEFAULT|LABEL|APPEND' /boot/EFI/batocera/syslinux.cfg 2>/dev/null
```

## Captured output

*(Paste SSH blocks here: **`EDID build`**, **`TYPE_OF_CARD`**, **`video_output`**, **`H_RES_EDID`**, primary **`xrandr`** mode, **`APPEND`** **`drm.edid_firmware`** if present.)*

## Notes

- If **`generic_15.bin`** is still missing at this step, note whether the script plans to create it **on reboot** vs **immediately**.
- Compare **`DEFAULT`** / **`MENU DEFAULT`** in **syslinux** to live **`/proc/cmdline`** (still **CRT** entry until you switch back to **Wayland HD**).

## Next

- **03:** [03-crt-mode-pre-mode-switcher.md](03-crt-mode-pre-mode-switcher.md) (post-reboot **CRT** baseline **before** mode switcher)

## Reference

- [01-crt-x11-install-from-wayland-hd.md](01-crt-x11-install-from-wayland-hd.md)  
- X11-only analogue: [../pre-fix/01-crt-script-pre-reboot.md](../pre-fix/01-crt-script-pre-reboot.md)
