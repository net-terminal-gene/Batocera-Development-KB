# Myzar DisplayPort Hybrid Switchres (RDNA4)

## Agent/Model Scope

- Skills: `myzar-dp` (canonical), `ssh-batocera` / `SSH_ASKPASS` for Batocera
- **Deprecated on this build:** `myzar-mame-rotate`, `myzar-es-exit-rotation`, `apply-myzar-dp-switchres.sh`
- Hardware: Myzar/Mizar Batocera v41/v42, AMD RDNA4, DP-only CRT cabinet, `display.rotate=1`

## Problem

Myzar community image outputs CRT on **DisplayPort only** (not HDMI). Goals:

1. Boot and ES menu stable at **640×480i** with cabinet rotation (480×640)
2. Per-game **Switchres** arcade timings (not flat 640×480 for all MAME)
3. Correct rotation when **exiting** games back to EmulationStation
4. Settings survive **reboot** without reverting to stock HDMI path

## Root Cause (confirmed on device)

| Issue | Cause |
|-------|--------|
| Games stuck at 640×480, no modelines | `/usr/bin/batocera-resolution` symlink reverted to `batocera-resolution-hdmi`; `custom.sh` had `exit 0` **before** myzar symlink lines |
| ES rotation wrong after game exit | `is_menu_mode()` treated “MAME still running” as “in game” for `640x480i` restore → skipped menu rotation |
| ~30s game exit | Rotation-lock loop (200ms `xrandr`) + duplicate `setRotation` calls; stuck foreground `gameStart` `setMode` |
| Pillarboxing / wrong aspect (earlier) | ~1064 per-game `.cfg` with `rotate="270"`; `keepaspect=1`; `super_width=2560` mismatch |
| Display broken after agent SSH | Live `switchres` / manual `xrandr` tests left wrong global X11 mode |

## Solution

**Hybrid stack** (not full `crt=true` + `emulationstation-standalone-crt`):

| Layer | Component |
|-------|-----------|
| Boot | `#crt=true`, `amdgpu.dc=1` last in syslinux, `video=DP-1:640x480ieS`, EDID firmware |
| Runtime output | `global.videooutput=DisplayPort-0` (X11 name; kernel uses `DP-1`) |
| Wrappers | `batocera-resolution-myzar.sh`, `batocera-resolution-hdmi-myzar.sh` |
| Game hooks | `scripts/zzz-myzar-switchres.sh` (`gameStart` / `gameStop`) |
| Mode lookup | `batocera-get-game-mode.sh` (MAME `-listxml` → e.g. `384x224.59.19`) |
| Boot hook | `custom.sh` — myzar symlinks **first**, before any `exit` |
| MAME | `mame.switchres=1`, `default.cfg` only; `keepaspect=0`, `unevenstretchx=1`, `super_width=1024` |

Deploy from Mac: `~/.cursor/skills/myzar-dp/scripts/apply-myzar-dp-hybrid.sh`

## Files Touched

| Location | File | Change |
|----------|------|--------|
| Batocera `/userdata/system/` | `batocera-resolution-myzar.sh` | Menu vs arcade `setMode`; menu rotation on exit path |
| Batocera | `batocera-resolution-hdmi-myzar.sh` | `listModes` → CRT catalog |
| Batocera | `batocera-get-game-mode.sh` | Per-game videomode string |
| Batocera | `scripts/zzz-myzar-switchres.sh` | Fast `gameStop`; background `gameStart` `setMode` |
| Batocera | `custom.sh` | Symlinks every boot |
| Batocera | `batocera.conf` | `mame.switchres=1`, `DisplayPort-0`, `640x480i` |
| Batocera | `configs/mame/mame.ini`, `ini/vertical.ini` | Stretch / super_width |
| Mac skills | `myzar-dp/SKILL.md`, `reference.md` | Rewritten 2026-05-21 |
| Mac skills | `myzar-mame-rotate`, `myzar-es-exit-rotation` | Marked DEPRECATED |

## Validation

- [x] Menu: 480×640, `640x480i`, rotate right
- [x] `readlink /usr/bin/batocera-resolution` → myzar script after reboot
- [x] Game: Switchres modeline (e.g. ddpdoj → 1536×224 class)
- [x] Exit game: menu rotation correct, exit in seconds not ~30s
- [x] Reboot: symlinks and `mame.switchres=1` persist
- [x] **MAME + FBNeo Sai** both correct; no rotation cross-talk (`debug/04-mame-fbneo-rotation-coexistence-pass.md`)
- [x] **Saturn (Beetle core)** Batsugun + core-wide stretch/timing (`debug/saturn-beetle-core-crt.md`)
- [ ] User spot-check: pacman, 1942, additional vertical Cave titles
- [ ] No agent live `switchres` probes on production cabinet
- [ ] **Other emulators** — see `research/emulator-expected-resolutions.md` (SNES, PCE, FBNeo, DC, Naomi, Saturn, PSX, Windows, …)

### Emulator CRT matrix (2026-05-21)

| Priority | System | Expected timing | Expected X super-res |
|----------|--------|-----------------|----------------------|
| Done | mame | per-game XML | e.g. 1536×224, 1280×240 |
| 1 | snes | 256×224 @ 60 | 1024×224 |
| 2 | pcengine / pcenginecd | 512×240 @ 60 | 2048×240 or 1280×240 |
| 3 | fbneo | Sai `ddpsdoj` PASS | 1280×240 + Sai-only xrandr path |
| 4 | saturn | Beetle core PASS | `320×240` → 1280×240, `ratio=full`, normal xrandr |
| 5 | dreamcast / naomi / psx | set `*.videomode` first | often 640×480 until set |
| 5 | ps2 / psp | 640×480 / 960×480 | as configured |
| 6 | windows | per-title in conf | 320×240 … 1280×480 buckets |
| 7 | nes / vectrex | add `*.videomode` | 1024×240 / TBD |
