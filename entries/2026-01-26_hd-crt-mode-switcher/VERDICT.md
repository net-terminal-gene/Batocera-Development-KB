# VERDICT - HD/CRT Mode Switcher

## Status: MERGED (v42 & v43)

**v42 merged:** Original mode switcher with overlay file swapping and full state preservation.

**v43 merged (2026-04-23):** v43-specific implementation includes Wayland/X11 dual-kernel boot via Syslinux, CRT launcher wrapper for videomode precision sync, and Steam Deck optimization.

---

## Summary

Complete HD/CRT mode switching system implemented with overlay file swapping, full state preservation (batocera.conf, MAME, RetroArch, scripts, video settings), controller-friendly UI, and modular architecture. Tested on AMD GPU and Steam Deck. v42 shipped with v42 release; v43 shipped with PR #395 merge (Wayland/X11 dual-boot).

## Root Causes (of the original problem)

1. No infrastructure for switching between HD and CRT display configurations
2. Overlay editing (vs swapping) left mixed state between modes
3. No backup/restore for per-mode emulator configs (MAME TATE/YOKO, RetroArch CRT timing)

## Changes Applied

### v42 Base (PR #390)

| File | Change |
|------|--------|
| `mode_switcher.sh` | Main orchestrator |
| `mode_switcher_modules/01-04` | Detection, output selection, backup/restore, UI |
| `Batocera-CRT-Script-v42.sh` | Mode Switcher install integration |
| `crt/mode_switcher.sh` + `.keys` | CRT Tools launcher wrapper |
| `crt/gamelist.xml` + `crt/images/` | ES game carousel entries and art |

### v43 Extensions (PR #395)

| File | Change |
|------|--------|
| `Batocera-CRT-Script-v43.sh` | +1250 lines dual-kernel boot support, phase 1/2 install |
| `crt-launcher.sh` | Runtime videomode precision sync (wrapper) |
| `boot-custom.sh` | Mode-aware display config init |
| `crt/images/` | Updated artwork + v1/ archive |
| `grub.cfg` / syslinux | Multi-entry dual-kernel boot menu |

## Implementation Notes

- v42 uses overlay-only mode switching (single kernel, swap overlays)
- v43 uses dual-kernel architecture (Wayland kernel + X11 kernel, Syslinux boot menu)
- Both versions preserve user configs across mode switches
- CRT launcher wrapper ensures videomode string precision matches between batocera.conf and emulatorlauncher
- Requires full power cycle for cross-kernel transitions (GPU hardware state)

## Testing Status

- [x] CRT → HD → reboot → HD works
- [x] HD → CRT → reboot → CRT works
- [x] Full roundtrip CRT → HD → CRT → HD
- [x] MAME/RetroArch configs restore correctly per mode
- [x] User custom scripts preserved across switches
- [x] VNC works in both modes
- [x] Theme assets persist in HD mode
- [x] Tested on AMD GPU (RX 7900 XT)
- [x] Tested on Steam Deck
- [ ] Tested on NVIDIA GPU (pending future session)

---

## Outstanding (v43 post-launch)

- [ ] Steam preservation robustness (implemented, limited field testing)
- [ ] Steam videomode "Auto" mode on CRT (user workaround: use fixed resolution)
- [ ] NVIDIA GPU validation on v43 hardware
- [ ] Community bug reports and edge cases

---

## What Worked Well

- Systematic two-layer backup/restore (overlay + userdata configs)
- Modular architecture (01-04 modules) easy to test and debug independently
- Controller-friendly UI for non-technical users
- Gating all v43 dual-boot logic behind `/boot/crt/linux` existence checks (no impact on single-boot systems)

## What Did Not Work Well

- Initial v43 plan assumed overlay-only swap (wrong - dual-kernel required)
- Videomode precision mismatch debugging took multiple rounds before root cause (required `crt-launcher.sh` wrapper)
- MD5 validation double-suffix bug during X11 image download (fixed)
