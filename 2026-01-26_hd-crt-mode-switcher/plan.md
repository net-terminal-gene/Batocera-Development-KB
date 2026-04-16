# HD/CRT Mode Switcher — Persistent Display Configuration

## Agent/Model Scope

Multiple sessions. Initial implementation pre-dates RAG tracking. Later bug fixes and verification used Claude (claude-4.6-opus-high-thinking) with ssh-batocera skill.

## Problem

Users with dual-display setups (HD monitor + CRT) must manually reconfigure settings when switching displays, deal with black screens from incorrect output selection, lose emulator configurations when changing modes, and reinstall the CRT script to switch back to CRT mode.

## Root Cause

No mode switching infrastructure existed. Batocera boots with one set of configs, and swapping between CRT (15kHz, switchres, MAME TATE) and HD (1080p/4K, standard configs) required manual file edits and overlay manipulation.

## Solution

Complete mode switching system using overlay file swapping, per-mode backup/restore of batocera.conf, MAME, RetroArch, scripts, and video settings. Controller-friendly dialog UI. Modular architecture split across four modules.

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-CRT-Script | `Geometry_modeline/mode_switcher.sh` | Main entry point and orchestration |
| Batocera-CRT-Script | `mode_switcher_modules/01_mode_detection.sh` | Mode detection and verification |
| Batocera-CRT-Script | `mode_switcher_modules/02_hd_output_selection.sh` | Video output/resolution selection via DRM sysfs |
| Batocera-CRT-Script | `mode_switcher_modules/03_backup_restore.sh` | Complete backup/restore system |
| Batocera-CRT-Script | `mode_switcher_modules/04_user_interface.sh` | UI dialogs and user interaction |
| Batocera-CRT-Script | `Batocera-CRT-Script-v42.sh` | Mode Switcher integration into install script |
| Batocera-CRT-Script | `crt/mode_switcher.sh` | Wrapper launcher for CRT Tools menu |
| Batocera-CRT-Script | `crt/mode_switcher.sh.keys` | Controller key mappings |
| Batocera-CRT-Script | `crt/gamelist.xml` | Mode Switcher entry in EmulationStation |
| Batocera-CRT-Script | `crt/images/*` | Marquee, thumbnail, screenshot art for Mode Switcher |

## Validation

- [x] CRT → HD → reboot → HD works
- [x] HD → CRT → reboot → CRT works
- [x] Full roundtrip CRT → HD → CRT → HD
- [x] MAME/RetroArch configs restore correctly per mode
- [x] User custom scripts preserved across switches
- [x] VNC works in both modes
- [x] Theme assets persist in HD mode
- [x] Tested on AMD GPU (RX 7900 XT)
- [x] Tested on Steam Deck
- [ ] Tested on NVIDIA GPU (pending)

---

## KB maintenance (2026-04-16)

| Record | Location |
|--------|----------|
| Outcome / scope | `VERDICT.md` |
| PR / branch | `pr-status.md` |
| Wiki index | `Vault-Batocera/wiki/sources/batocera-development-kb.md`, `wiki/concepts/active-work.md`, `wiki/concepts/development-contributions.md` |
| Changelog-style notes | `Vault-Batocera/log.md` |

CRT Script v43 HD/CRT mode switcher delivery: branch `crt-hd-mode-switcher-v43` (e.g. commit `64b9a16`, 2026-04-16). Applies only to sessions in that scope.

