# Emulator test matrix — Fightcade Switchres wrapper

**Goal:** Verify the Switchres wrapper (`switchres_fightcade_wrap.sh`) works for every emulator Fightcade supports, not just FBNeo.

**Precondition:** `--rmmode` fix deployed (see `../second-pass-black-screen-issue/20-rmmode-fix-second-launch-resolved.md`).

---

## Part 1: Emulators

| # | Emulator | Fightcade channel | Test game | ROM name | Resolution source | Expected WxH |
|---|----------|-------------------|-----------|----------|-------------------|--------------|
| 1 | **fbneo** | SF3, KOF98, etc. | Street Fighter III / KOF98 | `sfiii3nr1` / `kof98` | MAME `-listxml` | 384x224 / 320x224 |
| 2 | **ggpofba** | FC1 legacy rooms (SF2, etc.) | Street Fighter II | `sf2` | MAME `-listxml` | 384x224 |
| 3 | **snes9x** | SNES rooms | Street Fighter II (SNES) | `snes_sf2` | Hardcoded fallback: 320x224@60.10 | 320x224 |
| 4 | **flycast** | Naomi / Atomiswave rooms | Marvel vs Capcom 2 | `nulldc_mvc2` | Hardcoded fallback: 640x480@59.94 | 640x480 |

### Part 1 Notes

- **fbneo:** Uses Wine + `fcadefbneo.exe`. INI patched for resolution. MAME XML lookup for native game dims.
- **ggpofba:** Uses Wine + `ggpofba-ng.exe`. INI patched. MAME XML lookup (same arcade ROMs as FBNeo, different emulator binary). FC1 (legacy Fightcade 1) rooms only.
- **snes9x:** Uses Wine + `fcadesnes9x.exe`. Config is `.conf` format (not FBNeo `.ini`); patched via `patch_snes9x_conf()`. No MAME XML for SNES ROMs, falls back to hardcoded 320x224@60.10 (320 not 256 to fill CRT face; snes9x stretches 256→320 with bilinear off).
- **flycast:** Native Linux binary (`flycast.elf`), not Wine. Config patched via `patch_flycast_cfg()` (`fullscreen=yes`, `rend.vsync=yes`). No MAME XML for Naomi/Atomiswave, falls back to hardcoded 640x480@59.94.

---

## Part 2: FBNeo console platforms

FBNeo in Fightcade supports console games via prefixed ROM names. Resolution is resolved by trying hardcoded per-prefix fallbacks first (to avoid false positives from MAME's arcade database on console ROMs), then MAME lookup for non-prefixed arcade ROMs.

| # | Platform | Prefix | Test game | ROM name | Resolution source | Expected WxH |
|---|----------|--------|-----------|----------|-------------------|--------------|
| 5 | **Mega Drive** | `md_` | Altered Beast | `md_altbeast` | Hardcoded fallback: 320x224@59.92 | 320x224 |
| 6 | **NES** | `nes_` | Contra | `nes_contra` | Hardcoded fallback: 320x240@60.10 | 320x240 |
| 7 | **PC Engine** | `pce_` | Adventure Island | `pce_advislnd` | Hardcoded fallback: 320x240@59.82 | 320x240 |
| 8 | **TurboGrafx-16** | `tg_` | Bonk's Adventure | `tg_bonkadv` | Hardcoded fallback: 320x240@59.82 | 320x240 |
| 9 | **Master System** | `sms_` | Alex Kidd | `sms_alexkidd` | Hardcoded fallback: 320x192@59.92 | 320x192 |
| 10 | **Game Gear** | `gg_` | Sonic the Hedgehog | `gg_sonicj` | Hardcoded fallback: 320x144@59.92 | 320x144 |
| 11 | **ColecoVision** | `cv_` | Zaxxon | `cv_zaxxon` | Hardcoded fallback: 320x192@59.92 | 320x192 |
| 12 | **SG-1000** | `sg1k_` | — | `sg1k_*` | Hardcoded fallback: 320x192@59.92 | 320x192 |
| 13 | **MSX** | `msx_` | — | `msx_*` | Hardcoded fallback: 320x192@59.92 | 320x192 |

### Part 2 Notes

- All console games run through FBNeo (`fcadefbneo.exe`) via Wine, same INI patching as arcade games.
- Resolution strategy: (1) hardcoded per-prefix fallback for console ROMs, (2) MAME lookup for non-prefixed arcade ROMs, (3) emulator-specific fallback (snes9x, flycast).
- All widths set to 320 (not native 256/160) to fill the CRT face horizontally; FBNeo `bVidFullStretch` handles internal stretching.
- 192-line platforms (SMS, CV, SG-1000, MSX) have visible top/bottom black bars on CRT. This is hardware-accurate (TMS9918 VDP outputs 192 active lines). Consumer TVs hid this via overscan; team to decide if 240-line stretch is preferred.
- Game Gear (144 lines) has very thick scanlines when displayed on a full-size CRT. Switchres doubled to 640x288@51.77 for modeline stability; 51.77 Hz is a Switchres calculation artifact, not PAL.

### Test procedure

1. Join the game's channel in Fightcade
2. Click TEST GAME
3. Confirm picture on CRT (no black screen)
4. SSH capture: `xrandr`, `pgrep -af` for emulator process
5. Exit emulator (ALT+F4), confirm return to menu timing
6. Record results below

---

## Part 1 Results

| Emulator | Entry | First launch | Second launch | Resolution confirmed |
|----------|-------|-------------|---------------|---------------------|
| fbneo | `01-fbneo-confirmed.md` | PASS | PASS | 384x224, 320x224 |
| ggpofba | — | SKIP | SKIP | FC1-only (legacy), not testing |
| snes9x | `02-snes9x-confirmed.md` | PASS | — | 320x224 (stretched from 256 native) |
| flycast | `03-flycast-confirmed.md` | PASS | — | 640x480i (interlaced) |

## Part 2 Results

| Platform | ROM tested | First launch | Resolution confirmed | Notes |
|----------|-----------|-------------|---------------------|-------|
| Mega Drive | `md_altbeast`, `md_sonic` | PASS | 320x224@59.92 | Hardcoded fallback; also tested Sonic |
| NES | `nes_contra` | PASS | 320x240@60.10 | Initial 256x224 had tearing (MAME arcade Contra collision); fixed with hardcoded 320x240 |
| PC Engine | `pce_advislnd` | PASS | 320x240@59.82 | Initial 256x224 had black bars + artifacts; PCE uses 240 lines not 224; fixed to 320x240 |
| TurboGrafx-16 | `tg_bonkadv` | PASS | 320x240@59.82 | Same hardware as PCE; 320x240 confirmed |
| Master System | `sms_alexkidd` | PASS | 320x192@59.92 | 192-line VDP; top/bottom bars expected (hardware-accurate). Initial 256 width fixed to 320 |
| Game Gear | `gg_sonicj` | PASS | 640x288@51.77 | Switchres doubled 320x144; thick scanlines expected (handheld, 144 lines on full CRT) |
| ColecoVision | `cv_zaxxon` | PASS | 320x192@59.92 | Same TMS9918 VDP as SMS; 192-line bars expected |
| SG-1000 | — | SKIP | — | Same VDP/resolution as SMS and CV; code path identical, not tested on device |
| MSX | — | SKIP | — | Same VDP/resolution as SMS and CV; code path identical, not tested on device |
