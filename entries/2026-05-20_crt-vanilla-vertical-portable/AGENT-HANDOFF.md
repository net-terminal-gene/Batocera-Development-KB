# Agent handoff — Vanilla Batocera Vertical CRT (Portable Bundle)

**One-page summary for a new agent session.** Read this first; everything below points to the deeper docs.

---

## What this session is

Reproduce vertical CRT gameplay on **vanilla Batocera v43 + Batocera-CRT-Script** (NOT Myzar), capturing every per-core preset as a self-contained from-scratch recipe so the cabinet can be rebuilt from a clean install without re-discovering each system's quirks.

**Why not Myzar:** Myzar/Mizar community policy rejects DisplayPort + DP-through-DAC CRT paths. This cabinet's display chain is DP, so the platform must be vanilla Batocera + the standalone CRT Script (not the Myzar fork).

**Reference cabinets:**
- `10.23.6.210` — target, vanilla Batocera v43, all work deployed here.
- `10.23.6.211` — Myzar source, used for state-file extraction only. Myzar's geometry / per-system RA cfgs are explicitly REJECTED for this cabinet (wrong polarity / wrong viewport / different physical mount).

---

## What's cabinet-validated (as of 2026-05-24)

Each row is a self-contained recipe in `research/`. Order is "recommended deploy order" but they're independent.

| # | System | Core (locked) | Recipe doc | Autoconfig spec | Mechanism | Cabinet-tested |
|---|--------|---------------|------------|------------------|-----------|----------------|
| 1 | PC Engine + PCE CD | `pce_fast` | [pcengine-vertical-vanilla-v43.md](research/pcengine-vertical-vanilla-v43.md) | [pcengine-vertical-autoconfig.md](../2026-05-22_crt-vertical-autoconfig-script/research/pcengine-vertical-autoconfig.md) | Geometry: 2 keys each (`videomode` + `ratio`) | YES (2026-05-21) |
| 2 | SNES | `snes9x` | [snes-vertical-vanilla-v43.md](research/snes-vertical-vanilla-v43.md) | [snes-vertical-autoconfig.md](../2026-05-22_crt-vertical-autoconfig-script/research/snes-vertical-autoconfig.md) | Geometry: 5 keys (`videomode` + `ratio=full` + `crt_switch=0` + `crop_overscan=false` + `gfx_clip` off) | YES (2026-05-23) |
| 3 | Vectrex | `vecx` | [vectrex-vertical-vanilla-v43.md](research/vectrex-vertical-vanilla-v43.md) | [vectrex-vertical-autoconfig.md](../2026-05-22_crt-vertical-autoconfig-script/research/vectrex-vertical-autoconfig.md) | Geometry + portrait RA rotation: 4 keys (`videomode` + `ratio=full` + `crt_switch=0` + `video_rotation=3`) | YES (2026-05-22) |
| 4 | Sega Saturn | `beetle-saturn` | [saturn-vertical-vanilla-v43.md](research/saturn-vertical-vanilla-v43.md) | [saturn-vertical-autoconfig.md](../2026-05-22_crt-vertical-autoconfig-script/research/saturn-vertical-autoconfig.md) | State-injection: 3 keys (autosave decouple) + 38 `.state.auto` files | YES (2026-05-22) |
| 5 | Sega Dreamcast | `flycast` | [dreamcast-vertical-vanilla-v43.md](research/dreamcast-vertical-vanilla-v43.md) | [dreamcast-vertical-autoconfig.md](../2026-05-22_crt-vertical-autoconfig-script/research/dreamcast-vertical-autoconfig.md) | State-injection + 2-tier rotation: 6 keys + 36 state files + 9 per-game cfgs | YES (2026-05-22) |
| 6 | Sega NAOMI | `flycast` (shared with Dreamcast) | [naomi-vertical-vanilla-v43.md](research/naomi-vertical-vanilla-v43.md) | [naomi-vertical-autoconfig.md](../2026-05-22_crt-vertical-autoconfig-script/research/naomi-vertical-autoconfig.md) | **Rotation only**: 1 key (`naomi.retroarch.video_rotation=3`). No state-injection (arcade ROMs have no skippable splash). Per-game `=0` cfgs documented as fallback for NVRAM-TATE-on titles (none on this cabinet yet). | Ikaruga PASS (2026-05-22); 11 other roster ROMs pending per-title sweep |
| 7 | Sony PlayStation (PSX) | `pcsx_rearmed` | [psx-vertical-vanilla-v43.md](research/psx-vertical-vanilla-v43.md) | [psx-vertical-autoconfig.md](../2026-05-22_crt-vertical-autoconfig-script/research/psx-vertical-autoconfig.md) | **Rotation + fill + per-game custom viewport**: 3 system-wide keys (`video_rotation=3` + `ratio=full` + `video_force_aspect=false`) + per-game custom viewport cfg for Cave family (2 titles) + (optional) bundled PSX memory cards for the same 2 titles. No state-injection (PSX persists in-game TATE to its own memory card). | 10 of 30 roster PASS (2026-05-23); 20 pending per-title sweep |
| 8 | Sony PlayStation 2 (PS2) | **standalone `pcsx2`** (PCSX2-Qt v2.5.229; NOT libretro) | [ps2-vertical-vanilla-v43.md](research/ps2-vertical-vanilla-v43.md) | [ps2-vertical-autoconfig.md](../2026-05-22_crt-vertical-autoconfig-script/research/ps2-vertical-autoconfig.md) | **Standalone-emulator bootstrap-state w/ file-lock**: 9 system-wide keys for PCSX2-Qt + per-title `state_filename` + `state_slot=1` + `chmod 444` on operator-captured `.01.p2s`. Configgen appends `-statefile <path> -stateindex 1` to pcsx2-qt → auto-load before frame 1. Libretro path rejected (`pcsx2_libretro` SIGILLs on BC250 AVX-512). | 12 of 13 vertical-shmup roster PASS (2026-05-24); Triggerheart Exelica Enhanced dropped → DC version |
| 9 | Sony PlayStation Portable (PSP) | `ppsspp` (libretro) | [psp-vertical-vanilla-v43.md](research/psp-vertical-vanilla-v43.md) | [psp-vertical-autoconfig.md](../2026-05-22_crt-vertical-autoconfig-script/research/psp-vertical-autoconfig.md) | **State-injection + two-tier rotation + viewport + TATE input remap**: 10 system-wide keys + TATE tier (3 titles: 480×640 cfg+rmp+Myzar `.state.auto`) + horizontal tier (3 titles: 544×480 or 816×480 viewport-only). Space Invaders: no Myzar state (v41→v43 PPSSPP hang). | 6 of 6 roster PASS (2026-05-24) |
| 10 | Nintendo Switch | **`citron-emu`** (unofficial add-on AppImage) | [switch-vertical-vanilla-v43.md](research/switch-vertical-vanilla-v43.md) | [switch-vertical-autoconfig.md](../2026-05-22_crt-vertical-autoconfig-script/research/switch-vertical-autoconfig.md) | **Standalone Citron + in-game TATE save**: 7 system-wide keys (`citron-emu` lock + `864x486` videomode + Vulkan + stretch `yuzu_ratio=5` + 1× scale). Operator enables TATE in Options menu once per title (persists to `yuzu/sdmc`). No RA, no state-injection. **NOT** stock `citron` (missing on v43). | 3 of 3 Cave roster PASS (2026-05-24) |

**Other vertical-eligible systems on this cabinet that have NOT been touched yet:** FBNeo + Neo Geo (autoconfig spec exists, no vanilla deploy doc yet), MAME (covered by CRT Script installer's existing rotation policy + per-ROM `.cfg`).

---

## Architecture in one diagram

```
Layer 0: Hardware (CRT panel, DP cable, DAC, BC-250 / x86_64 box)
            ↓
Layer 1: Vanilla Batocera v43 install (display.rotate=1 set by CRT Script later)
            ↓
Layer 2: Batocera-CRT-Script v43 installer (picks vertical/TATE)
         → sets display profile, EDID, super-res ladder, first_script.sh
         → ES boots vertically at native CRT resolution
            ↓
Layer 3: ROMs in /userdata/roms/<system>/  +  BIOS in /userdata/bios/
            ↓
Layer 4: Per-core vertical preset (THIS SESSION'S SCOPE)
         9 independent recipes — apply only the ones you need:
         · PCE / PCE CD ─┐
         · SNES          ├── Geometry-class (videomode + ratio + RA keys)
         · Vectrex       ┘
         · NAOMI         ── Rotation-only class (one RA rotation key, nothing else)
         · Saturn ──┐
         · Dreamcast ┴── State-injection class (RA savestate + per-system keys)
         · PSX           ── Rotation + fill + per-game custom-viewport class
                            (3 system keys + per-game cfg + optional bundled memory card)
         · PS2           ── Standalone-emulator bootstrap-state w/ file-lock class
                            (9 system keys for PCSX2-Qt + per-title state_filename +
                             state_slot=1 + chmod 444 on operator F1 bootstrap)
         · PSP           ── State-injection + two-tier rotation + viewport + TATE remap class
                            (10 system keys + TATE cfg+rmp+state OR horizontal viewport-only)
```

Each Layer 4 recipe touches ONLY its system's `batocera.conf` keys, save files, and per-game cfgs. None of them modify global rotation, display profile, videomodes.conf, or other systems.

---

## Six recipe classes

### Geometry-class (PCE / SNES / Vectrex / FBNeo)

Pattern: pick a `<system>.videomode` that matches a `batocera-resolution listModes` entry, set `<system>.ratio`, optionally tune RA keys per system.

Per-system tuning lives in:
- `/userdata/system/batocera.conf` — system-wide `<system>.*` keys
- `/userdata/system/configs/retroarch/config/<CoreName>/` — RA per-content overrides (only when needed)

No save-file injection involved.

### Rotation-only class (NAOMI)

Pattern: a single system-wide `<system>.retroarch.video_rotation=3` (cabinet polarity) is sufficient because the core renders at native res that already fills the rotated super-res. No fill keys, no autosave keys, no state files. Per-game `=0` overrides only if a specific ROM's NVRAM / in-game state turns out to pre-rotate.

This is essentially the geometry-class pattern stripped to its rotation key. NAOMI is the only system in scope where this works because:
- Arcade ROMs have no skippable splash → no need for state-injection.
- NAOMI native 640×480 fills the rotated super-res without fill keys.
- Service-mode TATE lives in NVRAM (`/userdata/saves/naomi/reicast/<rom>.zip.nvmem`), which auto-creates on first launch defaulting to TATE off.

### State-injection class (Saturn / Dreamcast)

v43's CRT Script geometry already produces correct screen size + rotation. The problem these systems solve is **time-to-play** (skipping splash screens) and persisting **in-game** TATE / Side options that some games hide in a menu.

Pattern:
- `<system>.autosave=0` + `<system>.retroarch.savestate_auto_load=true` + `<system>.retroarch.savestate_auto_save=false` (decoupled autoload — RA loads the curated state on launch, never overwrites it on exit, baseline survives every quit)
- `/userdata/saves/<system>/<Game>.state.auto[.png]` — curated state captured past the splashes
- Dreamcast adds: `<system>.ratio=full` + `<system>.retroarch.video_force_aspect=false` + system-wide `<system>.retroarch.video_rotation=3` + per-game cfgs for in-game-TATE titles (see Dreamcast doc for the matrix)

Hard locks for state-injection: the savestates are tied to the specific core. Switching `<system>.core` (e.g. `beetle-saturn` → `yabasanshiro`, `flycast` → `flycastvl`) breaks every seeded state.

### Rotation + fill + per-game custom viewport class (PSX)

Pattern: most titles work with three system-wide keys (rotation + ratio=full + force_aspect=false). A small minority — currently only the Cave family on PSX (DoDonPachi, Donpachi) — render their playfield in a narrow strip with wide static side panels (cabinet artwork). The system-wide stretch breaks those side panels. The fix is to override only those titles with a full per-game custom viewport cfg AND have the operator enable the game's in-game TATE option (persisted to a per-game asset file outside RA).

Pattern:
- `<system>.retroarch.video_rotation=3` + `<system>.ratio=full` + `<system>.retroarch.video_force_aspect=false` (system-wide; cover most of the roster)
- `/userdata/system/configs/retroarch/config/<CoreName>/<Game>.cfg` for the exception titles, with all of: `aspect_ratio_index = "24"`, `custom_viewport_width/height` matching the cabinet's post-rotation portrait dimensions, `custom_viewport_x/y = "0"`, `video_rotation = "0"`, `video_force_aspect = "true"`, `video_scale_integer = "false"`
- (Optional) bundled per-game persistence asset (PSX memory card `.1.mcr`) so the operator skips manually enabling in-game TATE

Hard locks: per-game cfgs are tied to the specific core's dir name (`PCSX-ReARMed/` for `pcsx_rearmed`, `Beetle PSX HW/` for `mednafen_psx`). The persistence asset itself (PSX `.1.mcr`) IS core-independent. Custom viewport dimensions must be computed from the cabinet's portrait resolution, never hardcoded.

PSX is the only system in this class. NAOMI is close (also has per-game-cfg fallback) but only needs `video_rotation = "0"` in the per-game cfg, not a full custom viewport. The PSX class exists because PSX's variable framebuffer (256×224 → 640×480 per title) means stretch-to-fill is not a one-size-fits-all answer for Cave-family side-panel layouts.

### Standalone-emulator bootstrap-state w/ file-lock class (PS2)

**First standalone-emulator recipe** in this project. All four prior classes target libretro cores via RetroArch cfg files. PS2 uses **standalone PCSX2-Qt** because the v43 libretro `pcsx2_libretro` core is built with AVX-512 SIMD instructions that crash with SIGILL on the BC250 APU. Standalone PCSX2-Qt has no `.cfg` file mechanism — every setting flows through `batocera.conf` and gets materialized into `PCSX2.ini` + pcsx2-qt CLI args by `pcsx2Generator.py`.

Pattern:
- Nine system-wide `ps2.*` keys cover renderer / vsync / resolution / texture filter / nearest present / anti-blur / autosave-off / incremental-off (no per-game render overrides needed; the same 9 keys work for every title).
- Per-title bootstrap workflow: operator launches game once → enters in-game Options → sets TATE → saves to PS2 memory card (`Mcd001.ps2`; persists across launches independently of save states) → exits → relaunches to verify TATE persistence → plays past every intro / splash / attract / default menu → reaches the launch spot → **presses F1** → PCSX2-Qt saves a `.01.p2s` + `.png` to `/userdata/saves/ps2/pcsx2/sstates/`.
- Per-title wire-up: add two `batocera.conf` keys — `ps2["<ROM>"].state_filename=/userdata/saves/ps2/pcsx2/sstates/<ROM>.01.p2s` + `ps2["<ROM>"].state_slot=1` — then `chmod 444` on the `.p2s` + `.png` to make accidental in-game F1 silently fail-safe.
- On next launch, configgen reads the per-game keys → appends `-statefile <path> -stateindex 1` to the pcsx2-qt command line → PCSX2-Qt loads the bootstrap before rendering frame 1 → cabinet boots directly into TATE gameplay (no BIOS animation, no game splash, no menus).

Hard locks:
- **Emulator lock: standalone `pcsx2` only.** Setting `ps2.core=pcsx2` (libretro) crashes on BC250. Setting either `ps2.emulator=libretro` or any non-pcsx2 standalone breaks the `-statefile` mechanism (no equivalent in libretro PS2).
- **Bootstrap file must be operator-captured.** This recipe cannot synthesize the `.01.p2s` file — it requires the operator to play through to the launch spot once and press F1.
- **`chmod 444` is non-negotiable.** Without it, accidental in-game F1 silently overwrites the bootstrap with a worse mid-stage save.
- **`ps2.autosave=0` is non-negotiable.** Without it, every clean exit creates a `<ROM>.p2s.auto` file that PCSX2-Qt prefers over the operator's `.01.p2s` bootstrap.
- **BIOS region matters.** Some Japanese titles (Triggerheart Exelica Enhanced confirmed) loop at BIOS memory-card-create prompts on European SCPH30004R BIOS; workaround is to use the title's NAOMI / Dreamcast port instead (DC port is in the Dreamcast TATE manifest).

PS2 is the only system in the standalone bootstrap-state class so far. The class will likely grow if future standalone emulators get vertical recipes.

### State-injection + two-tier rotation + viewport + TATE input remap class (PSP)

Pattern (libretro PPSSPP):

- Ten system-wide `psp.*` keys: emulator/core lock, `videomode=960x480.60.00`, fill triplet, decoupled autoload-only trio.
- Core-wide `PPSSPP/PPSSPP.cfg` mirrors rotation + autoload intent.
- **TATE tier:** per-game `PPSSPP/<Title>.cfg` with `video_rotation=0`, custom viewport 480×640, D-pad remap 90° CW, `remap_save_on_exit=false`; matching locked `remaps/PPSSPP/<Title>.rmp`; optional `.state.auto` for skip-menu (validate cross-version after PPSSPP bumps).
- **Horizontal tier:** per-game cfg with `video_rotation=3` and viewport 544×480 or 816×480 only; no remap; autoload only if v43-captured state exists (Space Invaders: Myzar state hung v43).

Hard locks: `ppsspp` core; chmod 444 on TATE cfg+rmp; never save remaps from inside RA for TATE titles; ES PSP menu clobbers system keys.

---

## Source bundle locations

All curated state captures from the Myzar source cabinet are on the maintainer Mac:

| Path | Contents | Bytes |
|------|----------|-------|
| `~/Batocera-Development-KB/snapshots/myzar-saturn-states/` | 38 Saturn titles: `.state.auto`, `.state.auto.png`, plus `.bcr/.bkr/.smpc/.state1` for completeness (~202 files) | ~81 MB |
| `~/Batocera-Development-KB/snapshots/myzar-dreamcast-states/` | 18 Dreamcast titles + 2 Battle Crust variants: `.state.auto` + `.state.auto.png` (40 files) | ~96 MB |
| Cabinet `10.23.6.210` at `/userdata/saves/psx/*.1.mcr` | 2 PSX memory cards captured after operator enabled in-game TATE on DoDonPachi + Donpachi (~128KB each, core-independent) | ~256 KB |
| `~/Batocera-Development-KB/snapshots/myzar-psp-states/` (or `/tmp/myzar-psp-states/` during deploy) | 3 TATE titles only: Star Soldier, Beta Bloc, Neo Geo Heroes Ultimate Shooting (`.state.auto` + `.png`). **Exclude Space Invaders Evolution** (Myzar v41 state hangs v43 PPSSPP on autoload). | ~15 MB |
| Cabinet `10.23.6.210` at `/userdata/saves/psp/_backup-myzar-incompatible/` | Quarantined Space Invaders Myzar state (reference only) | ~2.4 MB |
| Cabinet `10.23.6.210` at `/userdata/saves/ps2/pcsx2/sstates/*.01.p2s` + `.png` | 12 PS2 bootstrap save states captured after operator F1'd at the desired launch spot in TATE mode (`chmod 444` locked). Each `.p2s` ~10–15 MB; tied to specific BIOS version (European SCPH30004R on this cabinet) which embeds in save state header. | ~150 MB |
| Cabinet `10.23.6.210` at `/userdata/saves/ps2/pcsx2/Mcd001.ps2` | Single 8 MB PS2 memory card holding in-game TATE settings for all 12 wired titles (persists across launches independently of save states; written by PCSX2 when game writes to its save data) | ~8 MB |

For redistribution via Batocera-CRT-Script's autoconfig generator, these bundles need to be packaged as asset directories inside the CRT Script repo. PSX memory cards specifically are core-independent (work with `pcsx_rearmed`, `mednafen_psx`, `swanstation`, `duckstation`). PS2 bootstrap captures are BIOS-version-tied — bundle metadata must specify the capture BIOS or downstream load will fail with "BIOS version mismatch".

---

## What's still TBD

- [ ] **NAOMI per-title launch sweep.** Ikaruga validated. The other 11 roster ROMs (karous, psyvar2, radirgy, radirgyn, shikgam2, trgheart, trizeal, undefeat, illvelo, mamonoro, sl2007) are expected PASS with the system-wide key (fresh NVRAM defaults to TATE off), but each needs one launch to confirm. If any double-rotates, add `Flycast/<stem>.cfg` with `video_rotation = "0"` per the recipe.
- [ ] **PSX per-title launch sweep.** 10 of 30 roster titles validated. The other 20 (Dezaemon Plus, Galaga - Destination Earth, Gekioh, Gunbare Game Tengoku 2, Gatchaman, Meta-ph-list, Night Raid, Philosoma, RayCrisis, RayStorm, SD Gundam, Soukyuu Gurentai, Stahlfeder, TRL, both Time Bokan titles, Two-Tenkaku, Viewpoint, Xevious 3D-G+, Zanac x Zanac) need one launch each. Treat the three PSX-hi-res candidates (RayStorm, RayCrisis, Xevious 3D-G+) as a separate cohort since they MAY render at PSX's 640×480 mode which could need viewport math different from the 320×240 Cave template.
- [ ] **FBNeo + Neo Geo vanilla deploy doc.** Autoconfig spec exists ([fbneo-vertical-autoconfig.md](../2026-05-22_crt-vertical-autoconfig-script/research/fbneo-vertical-autoconfig.md)), no `research/fbneo-vertical-vanilla-v43.md` companion yet.
- [ ] **MAME bulk cfg policy.** CRT Script handles MAME rotation via `autorol`/`autoror`; the 1066-cfg-per-ROM bulk that lives on the Myzar source has not been ported to a vanilla recipe.
- [ ] **CRT Script integration of the autoconfig generator.** All `research/*-vertical-autoconfig.md` specs are ready for shell-script implementation in the CRT Script repo; no code committed there yet.
- [ ] **`design/scripts/capture-vertical-bundle.sh` run.** Pre-retirement userdata capture from the v41ocp cabinet is still pending (separate task — needed before retiring the original Myzar-era image, NOT a prerequisite for any deploy recipe above).

---

## How to extend (new title, new system, new cabinet)

### Adding a new title to an existing system

Each per-core recipe doc has an "Adding a new ROM later" or equivalent section. Most common cases:

- **New SNES / PCE / Vectrex title:** drop in `/userdata/roms/<system>/`, launch, observe. If the global preset works, done. If not, see the per-system "per-game overrides" section.
- **New NAOMI title:** drop the ROM zip in `/userdata/roms/naomi/`, launch. First launch auto-creates `/userdata/saves/naomi/reicast/<rom>.zip.nvmem` (defaults to TATE off, will rotate via system-wide key) and `/userdata/saves/naomi/<rom>.{A,B,C,D}1.bin` cartridge dumps. If correctly rotated → done. If double-rotated → write `Flycast/<rom_stem>.cfg` with `video_rotation = "0"` (NAOMI stems are MAME short names: `trizeal.cfg` for `trizeal.zip`).
- **New Saturn title:** drop ROM, play through any splashes, set in-game TATE / Side, exit with `F2`/quit, copy resulting `.state.auto` to your canonical backup. Reseed bundle.
- **New Dreamcast title:** drop ROM, launch. If correctly rotated → no per-game cfg needed (system-wide `=3` covers it). If wrong-orientation → check the game's in-game options for a TATE / Yoko toggle and follow the Dreamcast doc's "Adding a new Dreamcast title later" section to add a per-game `video_rotation = "0"` override (or `"2"` / `"1"` if the polarity is different).
- **New PSX title:** drop disc image (`.chd` preferred) in `/userdata/roms/psx/`, launch. If correctly rotated and fullscreen → done (the system-wide triplet covers it). If rotated but horizontally stretched with wide static side panels → likely Cave-family-style. Write per-game `PCSX-ReARMed/<stem>.cfg` from the DoDonPachi template (full custom viewport at cabinet portrait dimensions + `video_rotation = "0"` + `video_scale_integer = "false"`), then operator launches the game once, enables in-game TATE in the Options menu, exits — `/userdata/saves/psx/<stem>.1.mcr` will be created. Next launch will be fullscreen TATE.
- **New PSP title:** drop ROM in `/userdata/roms/psp/`. If native TATE (vertical shmup): write TATE-tier cfg+rmp from Star Soldier template, lock both, seed or capture `.state.auto` on **v43** (test autoload; do not assume Myzar states work). If horizontal-on-vertical: write viewport-only cfg (544×480 or 816×480, rotation 3); no remap; skip Myzar cross-version states unless validated on target PPSSPP core.
- **New PS2 title:** drop disc image (`.chd` preferred) in `/userdata/roms/ps2/`. Verify PS2 BIOS exists in `/userdata/bios/ps2/` (SCPH30004R / SCPH70012 / SCPH77000). Launch from EmulationStation. Handle any BIOS memory-card-create prompts (pick YES at every Japanese-language prompt; if it loops, abandon the PS2 version and check for a NAOMI or Dreamcast port — Triggerheart Exelica Enhanced is the canonical example of a region-locked loop). Reach the game's Options menu, set TATE / Screen / Orientation to ON, save to memory card from the game's own menu, exit cleanly. Relaunch and verify TATE persists from memory card. Play past every intro / splash / attract / default menu to reach the launch spot. Press **F1** → bootstrap `.01.p2s` + `.png` created at `/userdata/saves/ps2/pcsx2/sstates/<ROM>.01.p2s`. Then add two keys: `batocera-settings-set "ps2[\"<ROM>\"].state_filename" "/userdata/saves/ps2/pcsx2/sstates/<ROM>.01.p2s"` + `batocera-settings-set "ps2[\"<ROM>\"].state_slot" 1`. Then lock: `chmod 444 /userdata/saves/ps2/pcsx2/sstates/<ROM>.01.p2s /userdata/saves/ps2/pcsx2/sstates/<ROM>.01.p2s.png`. Relaunch from EmulationStation → cabinet boots directly into TATE gameplay at the saved spot, no menus, no BIOS animation. (The batch helper script in the PS2 vanilla doc automates the wire-up for many titles at once.)

### Adding a new system

Pick the closest matching recipe (geometry-class or state-injection class), copy its template, fill in the per-system specifics. See the autoconfig specs in `2026-05-22_crt-vertical-autoconfig-script/research/` for the spec format the new doc should follow.

### Different cabinet polarity (mirror mount, different CRT)

The current recipes assume the cabinet is mounted with the screen's bottom on the cabinet's right (270° CCW logical rotation). Mirrored cabinets swap rotation values:

| Current cabinet | Mirrored cabinet |
|-----------------|------------------|
| `vectrex.retroarch.video_rotation=3` | `=1` |
| `dreamcast.retroarch.video_rotation=3` | `=1` |
| `naomi.retroarch.video_rotation=3` | `=1` |
| `psx.retroarch.video_rotation=3` | `=1` |
| Per-game `=0` overrides (no RA rotation; in-game TATE / NVRAM TATE / PSX memory-card TATE drives it) | Same `=0` — mount-independent because no RA rotation is added |
| PSX per-game `custom_viewport_width="480" custom_viewport_height="640"` | Same `480` / `640` — these are post-rotation portrait dimensions, not landscape source; mount-independent |
| PS2 per-game `state_filename` + `state_slot=1` | Same on mirrored cabinets — the bootstrap captures the game in whatever in-game TATE orientation it was saved with; rotation is driven by `display.rotate` at the display layer, not by RA / PCSX2 per-system keys |

PCE / SNES / Saturn / PS2 do not have per-system RA rotation keys (rotation is handled at the display layer via `display.rotate`), so they are unaffected by mount polarity.

---

## Operational tips for the next agent

- **SSH:** `~/bin/ssh-batocera.sh <ip> '<command>'`. Wrap multi-line scripts in a local file and `rsync` them to `/tmp/` on the cabinet, then SSH to `chmod +x && run`. Embedded `printf` with quotes / parens in nested expect-over-ssh strings is fragile.
- **rsync filtering:** for state-file pulls, use `rsync -av --include='*.state.auto' --include='*.state.auto.png' --exclude='*' src/ dst/`. Do NOT wrap include/exclude in TCL braces inside expect.
- **No KB edits without a test cycle.** This session's rule per the project workflow: every deploy step is validated on the actual cabinet before the recipe doc claims it works. The "cabinet-tested" date in each doc's header is the floor for when that recipe was actually run end-to-end.
- **Companion session for live CRT debugging:** `2026-05-21_crt-myzar-dp-hybrid-switchres` documents the Myzar source cabinet's per-emulator behavior. Use it only as a reference for "what Myzar does differently" — do NOT copy Myzar's `xrandr` / Switchres tricks unless the same bug appears on vanilla v43.

---

## Index of every doc in this session

```
2026-05-20_crt-vanilla-vertical-portable/
├── AGENT-HANDOFF.md             ← you are here
├── plan.md                       ← session scope + validation checklist (now 8 systems [x])
├── VERDICT.md                    ← post-work summary
├── pr-status.md                  ← PR links (none open from this session yet)
├── design/                       ← capture scripts, file manifest, portable overlays
│   ├── README.md
│   ├── file-manifest.md
│   ├── crt-installer-choices.md
│   ├── portable/                 ← ES-exit + MAME rotation overlays for vanilla
│   ├── scripts/capture-vertical-bundle.sh
│   └── captured/                 ← (empty; pre-retirement capture pending)
├── debug/
│   └── README.md                 ← QA / failure-signs catalog
└── research/
    ├── README.md                 ← cross-link index of all per-core docs
    ├── pcengine-vertical-vanilla-v43.md
    ├── snes-vertical-vanilla-v43.md
    ├── vectrex-vertical-vanilla-v43.md
    ├── saturn-vertical-vanilla-v43.md
    ├── dreamcast-vertical-vanilla-v43.md
    ├── naomi-vertical-vanilla-v43.md
    ├── psx-vertical-vanilla-v43.md
    └── ps2-vertical-vanilla-v43.md
```

And the paired autoconfig generator spec session:

```
2026-05-22_crt-vertical-autoconfig-script/
├── plan.md
├── VERDICT.md
├── debug/README.md
├── design/README.md
└── research/
    ├── README.md
    ├── pcengine-vertical-autoconfig.md
    ├── snes-vertical-autoconfig.md
    ├── vectrex-vertical-autoconfig.md
    ├── fbneo-vertical-autoconfig.md
    ├── saturn-vertical-autoconfig.md
    ├── dreamcast-vertical-autoconfig.md
    ├── naomi-vertical-autoconfig.md
    ├── psx-vertical-autoconfig.md
    └── ps2-vertical-autoconfig.md
```

---

## TL;DR for the impatient agent

1. Read this page.
2. Pick the per-core recipe(s) the operator needs.
3. Each `research/*-vertical-vanilla-v43.md` opens with **"Reading this from a fresh install"** prereqs — same prereqs across all of them (vanilla v43 + CRT Script vertical + ROMs + BIOS).
4. Each recipe is self-contained: `batocera.conf` block + (optional) state files + (optional) per-game cfgs + QA checklist.
5. The autoconfig session is the spec a Batocera-CRT-Script shell helper should implement to automate all eight per-system recipes idempotently (across all five recipe classes). No code shipped there yet.
