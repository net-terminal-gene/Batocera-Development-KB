# CRT Installer: Missing global.videooutput in batocera.conf

## Agent/Model Scope

Composer + ssh-batocera for live system verification.

## Problem

After reflashing to Wayland v43 and installing the CRT Script + X11, the first reboot to CRT mode produces a black screen. EmulationStation is running but rendering to `eDP-1` (the factory Wayland default) while X11/CRT is on `DP-1`.

## Root Cause

The CRT Script installer (`Batocera-CRT-Script-v43.sh`) uses the selected video output (`$video_output` / `$video_output_xrandr`) to configure syslinux, X11 configs, and helper scripts — but **never writes `global.videooutput` to `batocera.conf`**.

On Wayland dual-boot systems, `batocera.conf` retains the factory setting `global.videooutput=eDP-1`. The `emulationstation-standalone` MultiScreen wrapper reads this value to decide which display to target, so ES renders to the invisible laptop screen instead of the CRT.

On older single-boot X11-only systems, this gap didn't matter because `global.videooutput` wasn't set at all (or was irrelevant — X11 configs handled everything).

## Solution

Add `global.videooutput=$video_output_xrandr` to the installer's `batocera.conf` write block (~line 5358 in `Batocera-CRT-Script-v43.sh`), between `global.videomode` and `es.resolution`.

Additionally, add an `es.resolution` fallback in `get_crt_boot_resolution()` (~line 492 in `02_hd_output_selection.sh`) so the mode switcher can detect pre-configured boot resolution from the installer and skip the boot resolution prompt on first run.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `Batocera_ALLINONE/Batocera-CRT-Script-v43.sh` (~line 5358) | Add `global.videooutput=$video_output_xrandr` to batocera.conf during install |
| Batocera-CRT-Script | `Geometry_modeline/mode_switcher_modules/02_hd_output_selection.sh` (~line 492) | Add `es.resolution` fallback in `get_crt_boot_resolution()` |

## Validation

- [ ] After CRT Script install on Wayland dual-boot, verify `global.videooutput` is set to CRT output in batocera.conf
- [ ] Verify first CRT boot shows EmulationStation on CRT (no black screen)
- [ ] Test mode switcher first run: should only ask for HD output (not CRT or boot res)

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

