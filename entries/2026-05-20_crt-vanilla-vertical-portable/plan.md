# Vanilla Batocera Vertical CRT (Portable Bundle)

## Agent/Model Scope

Composer + `ssh-batocera`, `rsync-batocera`, skills: `myzar-es-exit-rotation`, `myzar-mame-rotate`. **Out of scope:** `myzar-dp` (DisplayPort / RDNA4 boot hack).

## Why not Myzar (policy, not technical)

The Myzar/Mizar project **does not support DisplayPort** for CRT output — including **DisplayPort through a DAC** (e.g. DP → analog for a 15 kHz / VGA-scaler path). That is a **project/community position**, not a Batocera limitation. This cabinet **requires** DP video (hardware outputs CRT on DP-1 only), so staying on the Myzar image or ecosystem means no supported path for the actual display chain.

This session exists to **decouple vertical CRT gameplay from Myzar politics**: use **official Batocera + Batocera-CRT-Script** (which is separate from Myzar) and own the boot/output/rotation fixes locally — without depending on a Myzar build that rejects DP.

Technical note: earlier work included a **`myzar-dp`** boot workaround on a Myzar-based image; that is **out of scope** for the vanilla target build (installer picks the correct `videooutput` for your hardware instead).

## Problem

Myzar/Mizar vertical CRT image works for rotation and MAME tuning but **cannot be the long-term platform** when the display path is DP + DAC. The image also ties the setup to pre-baked userdata and one-off discovery on a machine that can only be online one at a time.

**Goal:** reproduce vertical CRT on **official Batocera v42 or v43** + **Batocera-CRT-Script** installer, using the **same ROM set**, with all necessary configs captured so we never need to reopen this Myzar-era system for file archaeology.

## Root Cause

1. **Platform:** Myzar/Mizar policy excludes DisplayPort and DP+DAC CRT — incompatible with this hardware’s video path.
2. **Operational:** Myzar image is a one-off; userdata (scripts, 1066 MAME cfgs) must be captured before swap or work is lost.
3. **Technical (secondary):** Rotation/ES-exit behavior lives in configs + scripts, not ROMs — portable to vanilla + CRT Script.

## Solution

1. **One-time capture** from current Batocera (`design/scripts/capture-vertical-bundle.sh`) → Mac archive under `design/captured/`.
2. **Fresh install** official Batocera **42 or 43** (match CRT script major version).
3. Copy **Batocera-CRT-Script** to `/userdata/system/Batocera-CRT-Script/`, run installer with documented TATE choices (`design/crt-installer-choices.md`).
4. Apply **portable overlays** from `design/portable/` (ES exit rotation, optional MAME rotate policy).
5. Restore **ROMs** (same tree) — no ROM changes required.
6. Validate checklist in `debug/README.md`.

**Related (future automation):** planned CRT Script vertical preset generator — `entries/2026-05-22_crt-vertical-autoconfig-script/` (`research/` includes **PCE**, **SNES**, **Vectrex**, **FBNeo**, **Saturn**, **Dreamcast**, **NAOMI**, **PSX**, **PS2** merge specs).

## Files Touched

| Repo | File | Change |
|------|------|--------|
| Batocera-Development-KB | `entries/2026-05-20_crt-vanilla-vertical-portable/` | This session |
| Mac | `~/.cursor/skills/myzar-es-exit-rotation/` | Source for portable scripts |
| Mac | `~/.cursor/skills/myzar-mame-rotate/` | Optional MAME cfg generator |
| Mac | `Batocera-CRT-Script/` | Installer source (v42/v43 script) |
| Batocera `/userdata` | See `design/file-manifest.md` | Capture + re-apply |

## Validation

- [ ] Capture tarball completed before retiring current image
- [ ] Fresh Batocera v42/43 boots CRT with installer (no Myzar image)
- [ ] `display.rotate=1`, ES vertical 480×640
- [ ] Launch MAME → quit → ES stays vertical (~6s exit OK)
- [x] PSP vertical: 6/6 roster PASS (2026-05-24) — see `research/psp-vertical-vanilla-v43.md`
- [x] Switch vertical (citron-emu): 3/3 Cave roster PASS (2026-05-24) — see `research/switch-vertical-vanilla-v43.md`
- [ ] MAME cfgs restored or regenerated; count matches ROM zip count
- [x] PC Engine / PCE CD: global `pcengine` + `pcenginecd` `videomode=256x224.60.00004`, `ratio=core` on cabinet (`research/pcengine-vertical-vanilla-v43.md`)
- [x] SNES: global `snes.videomode=256x256.60.00006`, `snes.ratio=full`, `snes.retroarch.crt_switch_resolution=0`, `video_crop_overscan=false`, `snes9x_gfx_clip` off; cabinet-tested (`research/snes-vertical-vanilla-v43.md`, autoconfig `2026-05-22_crt-vertical-autoconfig-script/research/snes-vertical-autoconfig.md`)
- [x] Vectrex: `vectrex.videomode=384x480.60.00028`, `vectrex.ratio=full`, RA `crt_switch_resolution=0`, `video_rotation=3`; QA Mine Storm + Pole Position (`research/vectrex-vertical-vanilla-v43.md`, autoconfig spec `2026-05-22_crt-vertical-autoconfig-script/research/vectrex-vertical-autoconfig.md`)
- [x] Saturn (Beetle Saturn): state-injection with decoupled autoload (`saturn.autosave=0` + `saturn.retroarch.savestate_auto_load=true` + `..._save=false`) + 38 `.state.auto` titles seeded Myzar → v43; geometry untouched. Cabinet-tested (`research/saturn-vertical-vanilla-v43.md`, autoconfig `2026-05-22_crt-vertical-autoconfig-script/research/saturn-vertical-autoconfig.md`).
- [x] Dreamcast (Flycast): same decoupled autoload + `dreamcast.ratio=full` + `dreamcast.retroarch.video_force_aspect=false` + system-wide `dreamcast.retroarch.video_rotation=3` + per-game `Flycast/<stem>.cfg` `video_rotation="0"` for 9 in-game-TATE titles (Ikaruga, Karous, NEO XYX, Triggerheart Exelica, Trizeal, Under Defeat, Radirgy, Psyvariar 2, Shikigami no Shiro II). Full 18-title rotation matrix cabinet-tested (`research/dreamcast-vertical-vanilla-v43.md`, autoconfig `2026-05-22_crt-vertical-autoconfig-script/research/dreamcast-vertical-autoconfig.md`).
- [x] NAOMI (Flycast, same core as Dreamcast): **one key only** — `naomi.retroarch.video_rotation=3`. Ikaruga cabinet-validated 2026-05-22; 11 other roster ROMs (karous, psyvar2, radirgy, radirgyn, shikgam2, trgheart, trizeal, undefeat, illvelo, mamonoro, sl2007) expected PASS based on fresh-NVRAM-defaults-to-TATE-off, per-title launch sweep pending. No state-injection (arcade ROMs have no skippable splash), no fill keys, no autosave decoupling. Per-game `Flycast/<stem>.cfg` `video_rotation="0"` documented as fallback for any NVRAM-TATE-on title (mirroring Dreamcast in-game-TATE pattern). (`research/naomi-vertical-vanilla-v43.md`, autoconfig `2026-05-22_crt-vertical-autoconfig-script/research/naomi-vertical-autoconfig.md`).
- [x] PSX (`pcsx_rearmed`): **three keys + per-game cfgs for Cave family** — system-wide `psx.retroarch.video_rotation=3` + `psx.ratio=full` + `psx.retroarch.video_force_aspect=false` covers 8 of 10 cabinet-tested titles (Airgrave, Detana Twinbee, Strikers 1945, Strikers 1945 II, Raiden DX, Raiden Project, Sonic Wings Special, Toaplan Shooting Battle 1); 2 Cave-family titles (DoDonPachi, Donpachi) need per-game `PCSX-ReARMed/<stem>.cfg` with full custom viewport (`aspect_ratio_index="24"` + `custom_viewport_width="480"`/`height="640"` + `video_rotation="0"` + `video_scale_integer="false"`) plus operator enables in-game TATE in Options menu (persisted to `/userdata/saves/psx/<stem>.1.mcr`). No state-injection (PSX persists settings to memory card live during play). 10 of 30 roster titles cabinet-validated 2026-05-23; 20 pending per-title sweep. (`research/psx-vertical-vanilla-v43.md`, autoconfig `2026-05-22_crt-vertical-autoconfig-script/research/psx-vertical-autoconfig.md`).
- [x] PS2 (**standalone PCSX2-Qt v2.5.229**, NOT libretro — `pcsx2_libretro` SIGILLs on BC250 AVX-512): **first standalone-emulator recipe, new fifth recipe class — standalone-emulator bootstrap-state w/ file-lock**. Nine system-wide `ps2.*` keys for PCSX2-Qt: `emulator=pcsx2` + `autosave=0` (`SaveStateOnShutdown=false`) + `incrementalsavestates=0` (`AutoIncrementSlot=false`) + `pcsx2_bilinear_filtering=0` (nearest on present) + `pcsx2_blur=true` (`pcrtc_antiblur=true`, inverted semantics = sharper) + `pcsx2_gfxbackend=14` (Vulkan; Software `=13` tested, no sharpness gain on Cave 2D) + `pcsx2_vsync=1` + `pcsx2_resolution=1` (1x native; 2x/3x cause sprite artifacts on Cave ports) + `pcsx2_texture_filtering=2` (PS2-spec; `=0` Nearest makes fonts chunky). Per-title (12 of 13 vertical-shmup roster wired + cabinet-validated 2026-05-24): two `batocera.conf` keys + `chmod 444` lock — `ps2["<ROM>"].state_filename=/userdata/saves/ps2/pcsx2/sstates/<ROM>.01.p2s` + `ps2["<ROM>"].state_slot=1`. Configgen translates to `-statefile <path> -stateindex 1` CLI args appended to pcsx2-qt → auto-load before frame 1 → cabinet boots directly into TATE gameplay. Operator workflow per title: in-game TATE → save to PS2 memory card `Mcd001.ps2` → relaunch to verify TATE persistence → F1 mid-gameplay at desired launch spot → wire keys + lock. Validated titles: Castle Shikigami, Castle Shikigami II, DoDonPachi Dai-Ou-Jou, Espgaluda (soft port — source limitation), Gunbird Special Edition, Homura (Europe), Ibara, Mushihime-sama, Psyvariar 2 - Ultimate Final, Raiden III (Europe), Shooting Love - Trizeal, XII Stag. Triggerheart Exelica Enhanced (SLPM-55052) dropped — BIOS region loop on European SCPH30004R, use DC version (`Triggerheart Exelica (Japan).cdi` in Flycast TATE manifest) instead. Configgen bug logged: `pcsx2_fastboot=true` writes `EnableFastBoot=false` due to inverted `return_values=("false","true")` in `pcsx2Generator.py` line 273 — cosmetic only because `-statefile` suppresses BIOS animation regardless. (`research/ps2-vertical-vanilla-v43.md`, autoconfig `2026-05-22_crt-vertical-autoconfig-script/research/ps2-vertical-autoconfig.md`).
- [ ] No duplicate `~restore_*.sh` scripts

## New-agent entry point

Any agent picking this up should start at [AGENT-HANDOFF.md](AGENT-HANDOFF.md) — single-page summary of which per-core recipes are cabinet-validated, where they live, what's still TBD, and how the recipes compose.
