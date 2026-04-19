# Fix-phase debug logs

**Started:** 2026-04-19  
**Context:** Retest after `Geometry_modeline/mode_switcher_modules/03_backup_restore.sh` changes (EFI `/boot/EFI/syslinux.cfg` as master, HD pre-save, CRT propagate-all, no premature `/boot` remount ro before syslinux restore).

## Workflow (read this)

**One step file at a time.** Create **`NN-*.md` only after** you finish that numbered checkpoint on hardware (same order as [pre-fix/](../pre-fix/)). Do not add the next `NN` until you are ready. No bulk “placeholder ladder” files.

**Skipped in fix phase:** **05** (same expected behavior as [pre-fix 05](../pre-fix/05-mode-switcher-hd-to-crt-no-boot-recognition.md); no separate capture file).

## Filename pattern (match [pre-fix/](../pre-fix/))

- Two-digit step index, hyphen, short kebab slug, `.md`
- Optional one-line title in the file: `# NN - Human title`
- Body: **Date**, **Host**, **Purpose**, **Commands run**, **Captured output**, **Notes**

Example: `00-v43-x11-first-boot.md` lines up with pre-fix `00` on the fix image.

## Suggested captures per step

1. `batocera-version` / branch or image id  
2. `cat /proc/cmdline`  
3. `grep -E 'APPEND|drm.edid_firmware|video=' /boot/EFI/syslinux.cfg /boot/boot/syslinux.cfg`  
4. `edid-decode /lib/firmware/edid/generic_15.bin | head -35`  
5. `grep 'EDID build' /userdata/system/logs/BUILD_15KHz_Batocera.log | tail -5` (after any reinstall)  
6. `DISPLAY=:0.0 xrandr | head -50`  

Add exactly **one** new row when you add the next `NN` file (no rows for steps not run yet).

## Index

| File | Summary |
|------|---------|
| [00-v43-x11-first-boot.md](00-v43-x11-first-boot.md) | Step 00: baseline before CRT install (vanilla then; live SSH). |
| [01-crt-script-pre-reboot.md](01-crt-script-pre-reboot.md) | Step 01: v43 install complete, pre-reboot; `BootRes`, `BUILD` EDID lines, `generic_15.bin` stat, `APPEND` on `EFI/batocera/syslinux.cfg`, patched `03_backup_restore.sh` present. |
| [02-crt-mode-pre-mode-switcher.md](02-crt-mode-pre-mode-switcher.md) | Step 02: post-reboot CRT baseline; `edid-decode`, `BUILD` grep, `xrandr` DP-1 769x576, `videomodes.conf` head, cmdline shows `drm.edid_firmware`. |
| [03-mode-switcher-crt-to-hd-pre-reboot.md](03-mode-switcher-crt-to-hd-pre-reboot.md) | Step 03: CRT→HD pre-reboot; `batocera.conf`→HDMI-2 + default; on-disk syslinux vanilla `APPEND`; live `xrandr`/`display.log` still DP-1 769x576; `cmdline` still has EDID for this boot. |
| [04-hd-mode-pre-mode-switcher.md](04-hd-mode-pre-mode-switcher.md) | Step 04: post-reboot HD desktop; HDMI-2 primary 3440x1440; vanilla `APPEND` on all checked syslinux paths; `cmdline` vanilla; `/lib/firmware/edid/` not visible. |
| **05** | *Skipped:* expected “empty Boot until save” behavior ([pre-fix 05](../pre-fix/05-mode-switcher-hd-to-crt-no-boot-recognition.md)). |
| [06-mode-switcher-hd-to-crt-pre-reboot.md](06-mode-switcher-hd-to-crt-pre-reboot.md) | Step 06: HD→CRT pre-reboot; `batocera.conf` CRT; live xrandr still HDMI primary; `BUILD` log shows empty Boot then Boot_576i; CRT `APPEND` on all three syslinux paths. |
| [07-crt-mode-pre-mode-switcher.md](07-crt-mode-pre-mode-switcher.md) | Step 07: post-reboot CRT after round trip; same EDID/`BUILD`/`xrandr` pattern as 02; cmdline + all syslinux paths carry `drm.edid_firmware`. |
| [08-mode-switcher-crt-to-hd-pre-reboot.md](08-mode-switcher-crt-to-hd-pre-reboot.md) | Step 08: 2nd CRT→HD pre-reboot; `Config check` shows HD filled; vanilla `APPEND` on disk; `cmdline` still CRT until reboot; live `xrandr` still DP-1. |
| [09-hd-mode-pre-mode-switcher.md](09-hd-mode-pre-mode-switcher.md) | Step 09: 2nd HD post-reboot baseline (after 08); HDMI-2 primary 3440×1440; vanilla `APPEND` + `cmdline`; no `/lib/firmware/edid/`; same `display.log` quirk as 04. |
| [09A-boot-resolution-reprompt-after-crt-to-hd-save.md](09A-boot-resolution-reprompt-after-crt-to-hd-save.md) | Supplement: boot picker runs again because CRT→HD save overwrites `video_mode.txt` with `currentMode` (`769x576.49.97`); `get_boot_display_name` cannot map that back to `Boot_576i…` vs `769x576.50.00053`. |
| [10-mode-switcher-hd-to-crt-pre-reboot.md](10-mode-switcher-hd-to-crt-pre-reboot.md) | Step 10: 2nd HD→CRT pre-reboot; empty Boot at `19:08` (09A); user picked **Boot_480i 15kHz 60Hz** → `641x480.60.00052`; live xrandr still HDMI primary; CRT `APPEND` on all paths; restore used backed-up `es.resolution`. |
| [11-crt-mode-pre-mode-switcher.md](11-crt-mode-pre-mode-switcher.md) | Step 11: post-reboot CRT after **480i** path; **641×480@60** on **DP-1**; EDID/build still 769×576 profile; `BootRes.log` still 768×576@25; snapshot predates **09A** sidecar file on disk (**12** after **`02`** deploy). |
| [12-mode-switcher-crt-to-hd-pre-reboot.md](12-mode-switcher-crt-to-hd-pre-reboot.md) | Step 12: 3rd CRT→HD pre-reboot (same slug as **08**); **09A** sidecar on device; `Config check` shows **Boot_480i** filled while `video_mode.txt` is synced `641x480.60.00`; vanilla `APPEND`; log lines **11:27** / **11:40**. |
| [13-hd-mode-pre-mode-switcher.md](13-hd-mode-pre-mode-switcher.md) | Step 13: 3rd HD post-reboot (after **12**); HDMI-2 primary 3440×1440; vanilla `APPEND` + `cmdline`; no `/lib/firmware/edid/`; **`crt_boot_display.txt`** still **Boot_480i**; `video_mode.txt` still **641x480.60.00**. |
| [14-mode-switcher-hd-to-crt-pre-reboot.md](14-mode-switcher-hd-to-crt-pre-reboot.md) | Step 14: 3rd HD→CRT pre-reboot (after **13**); **09A** validated: **`Boot:`** filled, no boot picker; **`Saved boot mode ID`** + sidecar refresh **`19:45:10`**; CRT `APPEND` on all paths. |
