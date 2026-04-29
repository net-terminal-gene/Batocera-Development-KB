# 01 — CRT script install complete, pre-reboot

**Date:** 2026-04-18  
**Host:** `batocera.local` (10.23.6.52), interactive SSH  
**Purpose:** Record install choices and on-screen evidence **before** reboot. Compare to tester’s “wrong matrix” report.

## Run context

- Path: `/userdata/system/Batocera-CRT-Script/Batocera_ALLINONE/Batocera-CRT-Script-v43.sh` (`chmod 755`, executed locally on device).
- OS: Batocera **43** `2026/04/07 09:23` (shown in banner; script header text still mentions “v42” in one block, version line shows **Version 43**).
- Display server: **xorg** (from earlier system info in session).
- **Scope:** **X11-only** lab. No Wayland / no two-kernel HD vs CRT dual-boot under test.

## GPU and output

| Field | Value |
|-------|--------|
| Detected card | `Advanced Micro Devices, Inc. [AMD/ATI] Navi 32 [Radeon RX 7700 XT / 7800 XT]` |
| Script label | `YOUR VIDEO CARD IS AMD/ATI` |
| CRT output (XR) | **DP-1** (selected `1`) |
| DRM / bind | `CRT bind: DP-1 -> card0 (0000:03:00.0) \| DCN \| AMD_IS_APU=0` |
| Display engine | **DCN** |
| Non-CRT outputs | Ignored via Xorg: `DP-2`, `HDMI-1`, `HDMI-2` |

## Monitor profile and EDID menu (matrix branch evidence)

- Monitor type: **1** → `generic_15`.
- **Resolution list shown for `generic_15` (native / AMD branch):**

  ```
  1 : 320x240@60
  2 : 640x480@30
  3 : 768x576@25
  ```

  If the superres (Intel/NVIDIA-NOUV) branch had been selected, this list would show **1280×…** timings instead. **This run therefore took the native matrix path** for `generic_15` at menu time.

- **EDID resolution choice:** **3** → **`768x576@25`** (confirmed by script: `Your choice is : 768x576@25`).

## Other install choices

| Step | Choice |
|------|--------|
| Rotation | **1** None |
| ES orientation | **1** NORMAL |
| Advanced configuration | Skipped (defaults) |
| USB polling | Default (Enter) |
| USB arcade encoders | **0** / none |
| GunCon2 calibration | Default **320x240@60** (bypass) |

## Post-install actions (script output)

- Syslinux updated; `emulatorlauncher.py` / `videoMode.py` backups noted.
- **Mode Switcher installed successfully.**
- Overlay sync included **`lib/firmware/edid/generic_15.bin`** in the rsync list (among other files).
- `Installed boot-custom.sh to /boot/` (0755).
- **SSH path:** message that system **will reboot after ENTER** on first-boot instructions screen.

## State not yet captured (after reboot)

- `stat` / `edid-decode` on `/lib/firmware/edid/generic_15.bin` (real root after reboot, not only overlay list).
- `BUILD_15KHz_Batocera.log` lines: `Parity decision`, `EDID build: switchres …`, `EDID PRE-bump`.
- `xrandr` on CRT output after boot and ES `Boot_576i` selection.

## Next numbered file

- **`02-*.md`** (suggested): post-reboot snapshot — `edid-decode`, `grep` EDID lines from `BUILD_15KHz_Batocera.log`, `BootRes.log`, `xrandr` for DP-1.

## Reference

- Prior baseline: [00-v43-x11-first-boot.md](00-v43-x11-first-boot.md).
