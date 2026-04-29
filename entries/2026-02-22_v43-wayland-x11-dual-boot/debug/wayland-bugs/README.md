# Wayland Bugs — Step-by-Step Documentation

Systematic documentation of Wayland dual-boot bugs, captured via SSH at each stage.

## Steps

| Step | File | Description | Status |
|------|------|-------------|--------|
| 00 | [00-factory-wayland-baseline.md](00-factory-wayland-baseline.md) | Fresh v43 Wayland install, factory defaults | Baseline |
| 01 | [01-user-set-edp1-and-none.md](01-user-set-edp1-and-none.md) | User set Video Output=eDP-1, Backglass=None | **eDP-1 NOT written to batocera.conf** |
| 02 | [02-reboot-after-user-settings.md](02-reboot-after-user-settings.md) | Reboot after user settings | eDP-1 still missing; DP-1 hotplug cycling observed |
| 03 | [03-crt-svg-theme-asset-missing-hd-mode.md](03-crt-svg-theme-asset-missing-hd-mode.md) | CRT.svg/CRT.png missing in Wayland HD mode | **FIXED** — dual-boot boot-custom.sh |
| 04 | [04-restore-video-settings-fix-and-black-screen.md](04-restore-video-settings-fix-and-black-screen.md) | restore_video_settings gate removed; black screen on warm reboot | **Fix verified**; transient GPU issue on warm reboot |
| 05 | [05-poweroff-instead-of-reboot-for-crt-to-hd.md](05-poweroff-instead-of-reboot-for-crt-to-hd.md) | Use poweroff instead of reboot for dual-boot CRT-to-HD | **Implemented** |
| 06 | [06-poweroff-instead-of-reboot-phase1-wayland-to-x11.md](06-poweroff-instead-of-reboot-phase1-wayland-to-x11.md) | Use poweroff instead of reboot for Phase 1 Wayland→X11 | **FIXED** |
