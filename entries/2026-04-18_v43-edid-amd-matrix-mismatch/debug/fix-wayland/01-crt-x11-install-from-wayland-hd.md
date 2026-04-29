# 01 - CRT X11 install from Wayland HD (fix-wayland prerequisite)

**Date:** (fill when complete)  
**Host:** (e.g. `batocera.local`, SSH)  
**Compositor / session:** **Wayland** **HD** during install; outcome adds **X11 CRT** boot path.  
**Scope:** [fix-wayland README](README.md) — **install X11 / CRT Script** (dual-boot or bundled) **before** any further **`02+`** tests in this directory.

## Definition

- Run **v43 CRT Script** (or documented PR #395 installer flow) from the **Wayland** desktop session so the system gains the **X11 CRT** kernel/overlay/syslinux entries needed for later **HD↔CRT** checks.
- Document **pre-reboot** and **post-reboot** if the installer splits phases (mirror **`pre-fix/01`** style if useful).

## Commands run

```bash
batocera-version
# Log installer milestones from BUILD_15KHz_Batocera.log (tail or grep CRT / EDID / switchres)
# grep APPEND /boot/EFI/syslinux.cfg /boot/boot/syslinux.cfg 2>/dev/null | head -12
# After reboot into first CRT or HD entry: session type, listOutputs, batocera.conf head
```

## Captured output

*(In progress: add **`BUILD`** excerpts, **`BootRes.log`**, **`syslinux`** **DEFAULT** / **APPEND** diff, and first boot session type **Wayland vs X11**.)*

## Notes

- Until **01** succeeds, **`fix-wayland/02+`** files should **not** assume **X11** or **`xrandr`** on the **Wayland** image.

## Next

- **02:** [02-crt-script-install-pre-reboot.md](02-crt-script-install-pre-reboot.md) (**X11** **Phase 2** pre-reboot captures)

## Reference

- [00-v43-wayland-first-boot.md](00-v43-wayland-first-boot.md)  
- X11-only ladder (contrast): [../fix/00-v43-x11-first-boot.md](../fix/00-v43-x11-first-boot.md), [../fix/01-crt-script-pre-reboot.md](../fix/01-crt-script-pre-reboot.md)
