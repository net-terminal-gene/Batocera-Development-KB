# Research — Vanilla Batocera Vertical CRT (Portable Bundle)

## Device snapshot (2026-05-20, batocera.local)

| Item | Value |
|------|-------|
| Batocera version | **41ocp** (2025/01/06) — migrate target **42 or 43** |
| `display.rotate` | **1** |
| `mame.rotation` | Not set in grep (bulk cfg policy instead) |
| MAME `.cfg` count | **1066** |
| `rotation_fix.sh` | **Stock** (not patched — portable patch pending on new build) |
| Event scripts | `first_script.sh`, `first_script_right.sh` (no `~restore_*.sh`) |
| CRT script on userdata | **Absent** (`/userdata/system/Batocera-CRT-Script` empty/missing) — image was pre-configured |

## Findings

### Why not Myzar (display politics)

- Myzar/Mizar **does not believe in / support DisplayPort** for CRT use, and **does not allow DisplayPort via a DAC** as an acceptable path.
- This cabinet’s workable video path is **DP-based**; staying in Myzar means fighting community rules instead of fixing the stack.
- **Batocera-CRT-Script** (ZFEbHVUE) is a separate project from Myzar; vertical TATE and CRT modes are available there without Myzar’s DP ban.
- Migration captures rotation/MAME/ES fixes learned on a Myzar-era image, then moves them to **official Batocera v42/43** where DP boot can be configured without Myzar approval.

### Myzar vs vanilla (technical)

- Vertical ES and console rotation on Myzar come from **Batocera-CRT-Script installer outputs** + **userdata scripts**, not from ROM format.
- **Portable bundle** in `design/portable/` reproduces session fixes (ES exit, single `setRotation`, optional MAME 270 generator).
- DP boot on the **new** build: use CRT installer + hardware docs — not dependent on Myzar image or `myzar-dp` living inside their ecosystem.

### CRT script documentation (v43 installer)

- `display.rotate` — ES UI only; emulators configured separately.
- Libretro: horizontal games on TATE; native vertical arcade can be problematic.
- Standalone (PSP, PCSX2): horizontal-on-rotated-screen; rotation via `display_standalone_rotation` in generated `first_script.sh`.
- MAME: GroovyMAME `autorol`/`autoror` + ini split; optional per-game cfg.

### Risk: version skew

Current cabinet is **v41**; target **v42/v43** may change `first_script.sh-generic` template, configgen paths, and Wayland/X11 dual-boot. After install, **re-apply** `design/portable/` overlays and diff captured `batocera.conf` keys.

## Capture status

Automated capture from agent environment **failed** (SSH expect: no PTYs). **You must run** `design/scripts/capture-vertical-bundle.sh` from a local terminal before retiring this image. See `design/captured/README.md`.

## PC Engine vertical (v43 roster)

- See [[pcengine-vertical-vanilla-v43.md]] — HuCARD + PCE CD roster, **global** `256x224.60.00004` + `ratio=core` for both systems on cabinet (2026-05-21), Myzar vs vanilla, optional per-game RetroArch overrides.

## Vectrex vertical (vecx, cabinet roster 2026-05-22)

- See [[vectrex-vertical-vanilla-v43.md]] — **global** `vectrex.videomode=384x480.60.00028` + `vectrex.ratio=full` (fill), per-system RA overrides (`crt_switch_resolution`, `video_rotation`), portrait `listModes` alternates, 28-title ROM list from `batocera.local`, Myzar parse note. **Generator merge spec:** [[vectrex-vertical-autoconfig.md]] in `2026-05-22_crt-vertical-autoconfig-script/research/`.

## SNES vertical (snes9x, cabinet roster 2026-05-22)

- See [[snes-vertical-vanilla-v43.md]] — **global** `snes.videomode=256x256.60.00006` + `snes.ratio=full` + `snes.retroarch.crt_switch_resolution=0` + `video_crop_overscan=false` + **`snes9x_gfx_clip` off** (differs from PCE’s **`256x224`** token when using **`full`** on this cab). **Generator merge spec:** [[snes-vertical-autoconfig.md]] in `2026-05-22_crt-vertical-autoconfig-script/research/`.

## Sega Saturn vertical (beetle-saturn, cabinet roster 2026-05-22)

- See [[saturn-vertical-vanilla-v43.md]] — **state-injection** (not geometry): decoupled autoload-only keys (`saturn.autosave=0` + `saturn.retroarch.savestate_auto_load=true` + `..._save=false`) + 38 `.state.auto` files seeded from Myzar `10.23.6.211` to v43 `10.23.6.210`. v43's existing rotation / screen size kept; Myzar's `Beetle Saturn/*.cfg` geometry rejected. Beetle Saturn core locked. Pristine baseline survives every quit. **Generator merge spec:** [[saturn-vertical-autoconfig.md]] in `2026-05-22_crt-vertical-autoconfig-script/research/`.

## Sega Dreamcast vertical (flycast, cabinet roster 2026-05-22)

- See [[dreamcast-vertical-vanilla-v43.md]] — **state-injection + two-tier rotation matrix** (Dreamcast titles render horizontal by default, but those with an in-game TATE menu rotate themselves when the option is on, which the savestate captures). Six `dreamcast.*` keys (autosave decouple + `ratio=full` + `video_force_aspect=false` + system-wide `video_rotation=3`) + 36 `.state.auto*` files seeded from Myzar to v43 + per-game `Flycast/<stem>.cfg` with `video_rotation = "0"` for the 9 in-game-TATE titles (Ikaruga, Karous, NEO XYX, Triggerheart Exelica, Trizeal, Under Defeat, Radirgy, Psyvariar 2, Shikigami no Shiro II). Myzar's `Flycast/dreamcast.cfg` + `reicast_screen_rotation=vertical` core option rejected (wrong rotation polarity + wrong viewport for this cab). Flycast core locked. **Generator merge spec:** [[dreamcast-vertical-autoconfig.md]] in `2026-05-22_crt-vertical-autoconfig-script/research/`.

## Sega NAOMI vertical (flycast, cabinet roster 2026-05-22)

- See [[naomi-vertical-vanilla-v43.md]] — **simplest of the six recipes**: rotation-only, **one** `naomi.*` key, no state-injection, no fill keys. Arcade ROMs boot to attract mode with no skippable splash; NAOMI service-mode TATE lives in NVRAM (`/userdata/saves/naomi/reicast/<rom>.zip.nvmem`) which auto-creates on first launch defaulting to TATE off, so a system-wide `naomi.retroarch.video_rotation=3` rotates the framebuffer to portrait without any per-game overrides on this cabinet. **Cabinet-validated:** Ikaruga (NAOMI) on `10.23.6.210` (2026-05-22). **Pending per-title launch sweep:** 11 other roster ROMs (karous, psyvar2, radirgy, radirgyn, shikgam2, trgheart, trizeal, undefeat, illvelo, mamonoro, sl2007); expected PASS with no override based on fresh-NVRAM-defaults-to-TATE-off, with per-game `Flycast/<stem>.cfg` `video_rotation = "0"` as the documented fallback (mirroring Dreamcast in-game-TATE pattern) if any NVRAM is found TATE-on. Shares the `Flycast/` per-game cfg dir with Dreamcast — no stem collision (NAOMI MAME short names vs Dreamcast display names). Myzar's `Flycast/naomi.opt` `reicast_screen_rotation=vertical` core option + custom 640×960 viewport rejected for same reasons as Dreamcast (wrong polarity, unnecessary on v43). Flycast core locked. **Generator merge spec:** [[naomi-vertical-autoconfig.md]] in `2026-05-22_crt-vertical-autoconfig-script/research/`.

## Sony PlayStation (PSX) vertical (pcsx_rearmed, cabinet roster 2026-05-23)

- See [[psx-vertical-vanilla-v43.md]] — **fourth recipe class: rotation + fill + per-game custom viewport**. Three system-wide `psx.*` keys (`retroarch.video_rotation=3` + `ratio=full` + `retroarch.video_force_aspect=false`) cover 8 of 10 tested roster titles (Airgrave, Detana Twinbee, Strikers 1945, Strikers 1945 II, Raiden DX, Raiden Project, Sonic Wings Special, Toaplan Shooting Battle 1). The Cave family (DoDonPachi, Donpachi) renders YOKO with wide static side panels which the system-wide stretch breaks, so they need per-game `PCSX-ReARMed/<stem>.cfg` with full custom viewport (`aspect_ratio_index="24"` + `custom_viewport_width="480"`/`height="640"` + `video_rotation="0"` + `video_scale_integer="false"`) **plus** the operator enables in-game TATE mode in the game's Options menu, which the PSX virtual memory card (`/userdata/saves/psx/<stem>.1.mcr`) persists across launches. **No state-injection** required (PSX games persist their own settings to memory cards, no skippable Sega-style splash). **Cabinet-validated:** 10 titles on `10.23.6.210` (2026-05-23). 20 roster titles pending per-title launch sweep. Myzar's `mednafen_psx` (Beetle PSX HW) approach uses the same custom-viewport pattern in `Beetle PSX HW/<stem>.cfg`; this recipe ports it to v43's `pcsx_rearmed` default. PSX BIOS in `/userdata/bios/` required. `pcsx_rearmed` core locked (memory cards are core-independent, per-game cfgs are core-tied). **Generator merge spec:** [[psx-vertical-autoconfig.md]] in `2026-05-22_crt-vertical-autoconfig-script/research/`.

## Sony PlayStation Portable (PSP) vertical (libretro ppsspp, cabinet roster 2026-05-24)

- See [[psp-vertical-vanilla-v43.md]] — **new sixth recipe class: state-injection + two-tier rotation + per-game viewport + TATE input remap**. Ten `psp.*` system-wide keys (`emulator=libretro` + `core=ppsspp` + `ratio=full` + `videomode=960x480.60.00` + `retroarch.video_rotation=3` + `video_force_aspect=false` + `crt_switch_resolution=0` + decoupled autoload-only trio) + core-wide `PPSSPP.cfg` + **two title tiers** on a 6-game roster: **TATE tier (3):** Star Soldier / Beta Bloc / Neo Geo Heroes Ultimate Shooting — per-game `PPSSPP/<Title>.cfg` (480×640 viewport, `video_rotation=0`, D-pad remap 90° CW, `remap_save_on_exit=false`) + locked `remaps/PPSSPP/<Title>.rmp` + Myzar `.state.auto` (cross-version OK for these three on v43). **Horizontal tier (3):** Pac-Man Championship Edition / Super Stardust Portable (544×480 viewport, rotation 3, no remap, no state) + Space Invaders Evolution (816×480, rotation 3, **`savestate_auto_load=false`**, Myzar `.state.auto` rejected — hung RetroArch on v43 PPSSPP autoload). v43 adds input remap layer Myzar never had (PPSSPP libretro rotates picture but not pad). ES per-system PSP menu clobbers keys. **Generator merge spec:** [[psp-vertical-autoconfig.md]] in `2026-05-22_crt-vertical-autoconfig-script/research/`.

## Nintendo Switch vertical (citron-emu AppImage, cabinet roster 2026-05-24)

- See [[switch-vertical-vanilla-v43.md]] — **new seventh recipe class: standalone Citron AppImage + system keys + in-game TATE save**. Requires **unofficial Switch add-on** (`citron-emu.AppImage`, `edenGenerator.py`). **Seven `switch.*` keys:** `switch.emulator=citron-emu` + `switch.core=citron-emu` + `switch.videomode=864x486.60.00070` + `switch.yuzu_backend=1` + `switch.yuzu_ratio=5` (stretch) + `switch.language=1` + `switch.citron_resolution_scale=2` (1× native). Operator enables in-game TATE once per title (Options → General Screen → Rotate → Right Roll; Link Rotation ON); persists to `/userdata/system/configs/yuzu/sdmc/`. **No** RetroArch, **no** state-injection, **no** per-game batocera keys on this 3-title roster (DoDonPachi Resurrection, Espgaluda 2, Mushihimesama). **Do NOT** use stock `switch.emulator=citron` (missing `/usr/bin/citron` on v43). Myzar reference (`10.23.6.214`) uses older `citron.AppImage` + stale `yuzu_ratio=4` (generator bug on v41); v43 cabinet-validated with stretch `=5`. Keys/firmware in `/userdata/bios/switch/`. **Generator merge spec:** [[switch-vertical-autoconfig.md]] in `2026-05-22_crt-vertical-autoconfig-script/research/`.

## Sony PlayStation 2 (PS2) vertical (standalone PCSX2-Qt, cabinet roster 2026-05-24)

- See [[ps2-vertical-vanilla-v43.md]] — **new fifth recipe class: standalone-emulator bootstrap-state w/ file-lock**. First standalone-emulator recipe in this project; all prior recipes target libretro cores via RetroArch cfg files. PS2 uses standalone PCSX2-Qt v2.5.229 (the v43 default) — every per-system and per-game setting flows through `batocera.conf` and gets materialized into `PCSX2.ini` + pcsx2-qt CLI args by `pcsx2Generator.py`. **Nine `ps2.*` system-wide keys:** `ps2.emulator=pcsx2` (lock standalone) + `autosave=0` (`SaveStateOnShutdown=false`) + `incrementalsavestates=0` (`AutoIncrementSlot=false`) + `pcsx2_bilinear_filtering=0` (`linear_present_mode=0`, nearest on present) + `pcsx2_blur=true` (`pcrtc_antiblur=true`, inverted semantics — `true` means sharper) + `pcsx2_gfxbackend=14` (Vulkan; Software `=13` tested, no sharpness gain) + `pcsx2_vsync=1` + `pcsx2_resolution=1` (1x native; 2x/3x cause Cave-port artifacts) + `pcsx2_texture_filtering=2` (PS2-spec; `=0` Nearest makes fonts chunky). **Per-title** wiring (12 of 13 cabinet-validated 2026-05-24: Castle Shikigami / II, DoDonPachi Dai-Ou-Jou, Espgaluda, Gunbird Special Edition, Homura, Ibara, Mushihime-sama, Psyvariar 2, Raiden III, Shooting Love Trizeal, XII Stag): two batocera.conf keys + chmod 444 lock — `ps2["<ROM>"].state_filename=/userdata/saves/ps2/pcsx2/sstates/<ROM>.01.p2s` + `ps2["<ROM>"].state_slot=1` + `chmod 444 <savestate> <savestate>.png`. Configgen reads the per-game keys → appends `-statefile <path> -stateindex 1` to the pcsx2-qt command line → PCSX2-Qt auto-loads the operator's bootstrap before rendering frame 1 → cabinet boots directly into TATE gameplay. The `chmod 444` makes accidental in-game F1 silently fail-safe instead of overwriting the bootstrap. **Operator workflow per title:** in-game TATE → save to PS2 memory card (`Mcd001.ps2`; persists across launches independently of save states) → F1 mid-gameplay at desired launch spot → wire two keys + lock. **Dropped title:** Triggerheart Exelica Enhanced (SLPM-55052) — BIOS memory-card-create prompt loops on European SCPH30004R BIOS regardless of YES/NO answer; **use the Dreamcast port** (`Triggerheart Exelica (Japan).cdi` already in the Dreamcast TATE manifest). **Hard locks:** standalone emulator only (libretro `pcsx2_libretro` SIGILLs on BC250 AVX-512); PS2 BIOS in `/userdata/bios/ps2/` (do NOT borrow v42-era Myzar BIOS — has caused boot loops on v43); `chmod 444` is non-negotiable; `ps2.autosave=0` is non-negotiable (otherwise `.p2s.auto` shadows bootstrap). **Configgen bug logged:** `ps2.pcsx2_fastboot=true` writes `EnableFastBoot=false` due to inverted `return_values=("false","true")` in `pcsx2Generator.py` line 273. Cosmetic only — `-statefile` suppresses BIOS animation regardless. **Generator merge spec:** [[ps2-vertical-autoconfig.md]] in `2026-05-22_crt-vertical-autoconfig-script/research/`.

## Next research steps

- [ ] Run `capture-vertical-bundle.sh` + rsync MAME cfgs while SSH access is available
- [ ] Record CRT installer menu choices from `BUILD_15KHz_Batocera.log` after capture
- [ ] Note GPU/output used on new build (for installer, not DP hack)
