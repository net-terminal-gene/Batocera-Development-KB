# Sony PlayStation (PS1) — vertical cabinet on vanilla Batocera v43

**Session:** [Vanilla vertical portable](../plan.md)
**Default core (Batocera x86_64, locked here):** `libretro` + **`pcsx_rearmed`** (`configgen-defaults.yml`). Available alternatives: `mednafen_psx` (Beetle PSX HW), `swanstation`, standalone `duckstation`. **Do not switch cores** — the per-game cfg dir name is core-dependent (PCSX-ReARMed/, Beetle PSX HW/, etc.) and per-game memory card content is core-independent but renderer behavior differs.
**Related:** [PS2 vertical](ps2-vertical-vanilla-v43.md) (sequel system on standalone PCSX2-Qt — entirely different recipe class: standalone-emulator bootstrap-state w/ file-lock, no RA cfg files, no memory-card-as-persistence; PCSX2-Qt CLI `-statefile` instead of libretro `savestate_auto_load`), [Dreamcast vertical](dreamcast-vertical-vanilla-v43.md) (shares the rotation + fill key triplet, plus per-game cfg pattern for problem titles; Dreamcast adds state-injection which PSX does NOT need), [NAOMI vertical](naomi-vertical-vanilla-v43.md) (shares the rotation-only baseline for most titles), [Saturn vertical](saturn-vertical-vanilla-v43.md), [SNES vertical](snes-vertical-vanilla-v43.md), [PC Engine vertical](pcengine-vertical-vanilla-v43.md), [Vectrex vertical](vectrex-vertical-vanilla-v43.md); autoconfig spec [psx-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/psx-vertical-autoconfig.md).

---

## Reading this from a fresh install

This doc assumes the operator has:

1. Flashed and booted **vanilla Batocera v43** on the cabinet hardware.
2. Run the **Batocera-CRT-Script v43 installer** and picked the **vertical / TATE** options. After reboot the cabinet should have:
   - `display.rotate=1` in `/userdata/system/batocera.conf`
   - `global.videooutput=<your CRT output>` (e.g. `DP-1`)
   - `global.videomode=Boot_…` from the installer (this cabinet uses `641x480.60.00082`)
   - The CRT display profile applied (`first_script.sh`, EDID, super-res ladder)
   - EmulationStation booting vertically at the cabinet's native CRT resolution
3. Copied PSX disc images to `/userdata/roms/psx/` (`.chd` preferred; `.pbp`, `.cue+bin`, `.m3u` also supported).
4. Dropped **PSX BIOS** (`scph1001.bin`, `scph5500.bin`, etc.) into `/userdata/bios/`. `pcsx_rearmed` is somewhat permissive on BIOS but `scph1001.bin` is the canonical.

Everything below adds PSX vertical-shmup support on top of that baseline. It does not change any other system, the CRT display profile, or the global rotation. **As of 2026-05-23 it adds three `psx.*` keys** to `batocera.conf` plus **two per-game cfgs** for the Cave family (DoDonPachi, Donpachi).

---

## Why PSX needs more than the NAOMI one-key recipe but less than Dreamcast

| Concern | PSX | Dreamcast | NAOMI |
|---------|-----|-----------|-------|
| Console framebuffer | Variable (256×224 → 640×480 per title) | Always 640×480 | Always 640×480 |
| Splash to skip | No (console boots straight to game) | Yes (Sega/Dreamcast logo + game intro) | No (arcade attract) |
| In-game TATE storage | **PSX memory card** (`.1.mcr`), saved by the game when operator picks TATE in Options menu | Dreamcast RAM, captured in `.state.auto` | NAOMI NVRAM (`.zip.nvmem`), auto-created on first launch |
| Default render orientation | Horizontal YOKO; most titles fill the 320×240 frame with playfield, a few (Cave) put narrow playfield + wide side panels | Horizontal | Horizontal (fresh NVRAM defaults to TATE off) |
| Number of `<system>.*` keys | **3** (rotation + fill + force_aspect=false) | 6 (those 3 + autosave decouple + 2 RA savestate keys) | 1 (rotation only) |
| Per-game cfgs | **2 titles** (Cave family) — full custom viewport + `video_rotation = "0"` | 9 in-game-TATE titles — single line `video_rotation = "0"` | 0 (so far) |
| Memory card / state files shipped | 2 `.1.mcr` files (after operator enables in-game TATE) | 36 `.state.auto[.png]` files | 0 |

PSX sits between NAOMI (simplest) and Dreamcast (most complex). The rotation + fill is the same as Dreamcast; the per-game cfgs are richer than Dreamcast's (need a full custom viewport, not just rotation kill); but no state-injection is required because PSX games persist their own settings to memory cards across launches.

---

## All the configuration (cabinet-tested 2026-05-23)

### 1. `batocera.conf` — three system-wide keys

Append to `/userdata/system/batocera.conf` (or set via `batocera-settings-set`):

```ini
# PSX vertical CRT (cabinet-tested 2026-05-23 on v43 + CRT Script)
psx.retroarch.video_rotation=3
psx.ratio=full
psx.retroarch.video_force_aspect=false
```

Set via:

```bash
batocera-settings-set psx.retroarch.video_rotation 3
batocera-settings-set psx.ratio full
batocera-settings-set psx.retroarch.video_force_aspect false
```

What each key does:

| Key | Effect |
|-----|--------|
| `psx.retroarch.video_rotation=3` | **System-wide rotation = 270° CCW.** Writes `video_rotation = 3` into `retroarchcustom.cfg` at every PSX launch. Correct polarity for this cabinet's mount. **On a cabinet mounted the opposite way, use `=1`** (90° CW). |
| `psx.ratio=full` | Configgen translates this to RA `aspect_ratio_index = "24"` (Custom) plus a `custom_viewport_width × height` matching the cabinet's portrait CRT super-res. Result: the rotated framebuffer is scaled to fill the entire portrait screen. |
| `psx.retroarch.video_force_aspect=false` | Pairs with `ratio=full`. Without this, the core's reported 4:3 aspect would override the custom viewport and letterbox the picture. |

This 3-key triplet is the system-wide baseline for **30 of 32** vertical-shmup titles on this cabinet's roster. The other 2 (Cave family — DoDonPachi, Donpachi) need a per-game override (see Section 3 below).

### 2. NO state-injection deployed

Unlike Saturn and Dreamcast, PSX gets **no `.state.auto`, no autosave decoupling, no `savestate_auto_*` keys**. PSX games persist player choices (including in-game TATE mode) to the virtual memory card (`/userdata/saves/psx/<rom_stem>.1.mcr`), which survives quit + relaunch on its own. State-injection would add a core-tied dependency for zero gameplay benefit (PSX has no skippable splash like Sega's BIOS screens).

### 3. Per-game rotation overrides — Cave family only

For titles whose YOKO mode renders the playfield in a narrow strip with wide static side panels (cabinet artwork, score, credits), the system-wide stretch-to-fill stretches those panels into the gameplay area and squashes everything horizontally. The fix is **the Myzar approach**: enable the game's in-game TATE option and override the per-game RA config to use a Custom viewport without RA rotation (the game's own TATE rendering already draws portrait content inside its 320×240 framebuffer).

Two titles on this roster need this treatment:

- **DoDonPachi** (Cave, 1998 PSX port)
- **Donpachi** (Cave, 1995 PSX port)

Generate the per-game cfgs:

```bash
CFG=/userdata/system/configs/retroarch/config/PCSX-ReARMed
mkdir -p "$CFG"
for stem in "DoDonPachi" "Donpachi"; do
  cat > "$CFG/${stem}.cfg" <<'EOF'
aspect_ratio_index = "24"
custom_viewport_width = "480"
custom_viewport_height = "640"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_rotation = "0"
video_force_aspect = "true"
video_scale_integer = "false"
EOF
  chmod 644 "$CFG/${stem}.cfg"
done
chown -R root:root "$CFG"
```

Key meanings:

| Key | Effect |
|-----|--------|
| `aspect_ratio_index = "24"` | RA's "Custom" aspect index. Tells RA to use the literal `custom_viewport_*` dimensions instead of a preset aspect formula. |
| `custom_viewport_width/height = 480/640` | Cabinet's **portrait** screen dimensions. On this cabinet the active CRT mode is `641x480` landscape pre-rotation; after `display.rotate=1` the screen is 480 wide × 640 tall (the extra 1px row is unused). **For a cabinet with different super-res, change these values to match the post-rotation portrait dimensions.** |
| `custom_viewport_x/y = "0"` | Anchor the viewport at the top-left. With width/height matching the screen, the viewport covers the entire portrait surface. |
| `video_rotation = "0"` | **Kills RA rotation for this title only.** The game's in-game TATE option produces content already in portrait orientation inside its framebuffer, so RA must not add another rotation. |
| `video_force_aspect = "true"` | Per-game override of the system-wide `false`. With Custom viewport this is largely redundant but defensive. |
| `video_scale_integer = "false"` | Allow non-integer scaling. PSX framebuffers don't divide evenly into the cabinet's portrait dimensions, so non-integer scale is required. |

**Why `chmod 644`:** matches the perms of every other RA cfg on the system. Defensive — root reads `600` but matching perms removes a misleading symptom during future diagnosis.

**Why NOT write a cfg for the other 30 titles:** they would be redundant with the system-wide keys, and would confuse the next maintainer about which files matter. Every file in `PCSX-ReARMed/` should be an exception.

### 4. Per-game in-game TATE prerequisite (operator action — once per Cave title)

The per-game cfg above is **inert** until the operator enables in-game TATE on the matching title. Without TATE on, the game still renders in YOKO mode and the per-game cfg's `video_rotation = "0"` makes it appear lying sideways. Procedure:

1. Launch DoDonPachi (or Donpachi). It will look wrong on this first launch — that is expected.
2. From the title screen, enter the **Options** / **Config** menu.
3. Find **"Screen"** / **"Display"** → **"Tate Mode"** (or similar — the exact label varies between Cave's PSX ports). Set to **ON**.
4. Exit the options menu. The game auto-saves to the virtual PSX memory card.
5. Quit the game (`HOTKEY + START` or your exit combo).
6. Confirm the memory card was written: `/userdata/saves/psx/DoDonPachi.1.mcr` (or `Donpachi.1.mcr`) should exist with mtime around your save time.
7. Relaunch — picture should now be fullscreen portrait TATE.

For a redistributable autoconfig, the two `.1.mcr` files can be bundled as static assets so the operator skips steps 1–6 entirely. Memory card content for PSX is core-independent — the same `.1.mcr` works with `pcsx_rearmed`, `mednafen_psx`, `swanstation`, etc.

---

## Per-title rotation status (cabinet roster, 30 titles)

| Title | ROM file | Status (2026-05-23) | Notes |
|-------|----------|---------------------|-------|
| Airgrave | `Airgrave.chd` | **PASS** system-wide | Fills the framebuffer in YOKO; stretch works |
| Detana Twinbee Yahoo! Deluxe Pack | `Detana Twinbee Yahoo! Deluxe Pack.chd` | **PASS** system-wide | Same as above |
| Strikers 1945 | `Strikers 1945.chd` | **PASS** system-wide | Psikyo, minimal side panels |
| Strikers 1945 II | `Strikers 1945 II.chd` | **PASS** system-wide | Psikyo, same engine family |
| Raiden DX | `Raiden DX.chd` | **PASS** system-wide | Seibu, content fills framebuffer |
| Raiden Project | `Raiden Project.chd` | **PASS** system-wide | Seibu anthology |
| Sonic Wings Special | `Sonic Wings Special.chd` | **PASS** system-wide | Psikyo |
| Toaplan Shooting Battle 1 | `Toaplan Shooting Battle 1.chd` | **PASS** system-wide | Toaplan anthology |
| DoDonPachi | `DoDonPachi.chd` | **PASS** with per-game cfg + in-game TATE enabled | Cave |
| Donpachi | `Donpachi.chd` | **PASS** with per-game cfg + in-game TATE enabled | Cave |
| Dezaemon Plus (Japan) | `Dezaemon Plus (Japan).chd` | Pending per-title launch | Athena (player-built shmup creator) |
| Galaga - Destination Earth (USA) | `Galaga - Destination Earth (USA).chd` | Pending | Hasbro / 3D Galaga |
| Gekioh - Shooting King | `Gekioh - Shooting King.chd` | Pending | Visco anthology |
| Gunbare! Game Tengoku 2 | `Gunbare! Game Tengoku 2.chd` | Pending | Jaleco comedy shmup |
| Kagaku Ninjatai Gatchaman - The Shooting | `Kagaku Ninjatai Gatchaman - The Shooting.chd` | Pending | Banpresto licensed |
| Meta-ph-list Micro.x.2297 | `Meta-ph-list Micro.x.2297.m3u` (Disc 1 + Disc 2) | Pending | Sony Music Ent. |
| Night Raid | `Night Raid.chd` | Pending | Takumi vertical shmup |
| Philosoma (USA) | `Philosoma (USA).chd` | Pending | Sony's 3D shmup, mixed planes |
| RayCrisis | `RayCrisis.chd` | Pending | Taito 3D shmup |
| RayStorm | `RayStorm.chd` | Pending | Taito 3D shmup |
| SD Gundam - Over Galaxian | `SD Gundam - Over Galaxian.chd` | Pending | Banpresto niche |
| Soukyuu Gurentai - Oubushutsugeki | `Soukyuu Gurentai - Oubushutsugeki.chd` | Pending | Banpresto vertical |
| Stahlfeder - Tekkou Hikuudan | `Stahlfeder - Tekkou Hikuudan.chd` | Pending | Tecmo vertical |
| TRL - The Rail Loaders | `TRL - The Rail Loaders.chd` | Pending | Sony Music Ent. rail shooter |
| Time Bokan Series - Bokan Desu Yo | `Time Bokan Series - Bokan Desu Yo.chd` | Pending | Banpresto licensed |
| Time Bokan Series - Bokan to Ippatsu! Doronboo | `Time Bokan Series - Bokan to Ippatsu! Doronboo.chd` | Pending | Banpresto licensed |
| Two-Tenkaku | `Two-Tenkaku.chd` | Pending | Yumekobo Mr. Driller-adjacent vertical |
| Viewpoint | `Viewpoint.chd` | Pending | Aicom isometric (orientation TBD) |
| Xevious 3D-G+ | `Xevious 3D-G+.chd` | Pending | Namco anniversary 3D Xevious |
| Zanac x Zanac | `Zanac x Zanac.chd` | Pending | Compile MSX classic remake |

Per-title test procedure for the remaining 20:

1. Launch with current setup (system-wide recipe only, no per-game cfg).
2. Observe orientation + aspect:
   - Correct vertical fullscreen → done, no per-game cfg.
   - Vertical orientation but content stretched horizontally (sprites too wide, side panels stretched into gameplay) → likely a Cave-family-style YOKO + side panels case. Add a per-game cfg using the DoDonPachi template, then operator enables in-game TATE on that title and saves to memory card.
   - Double-rotated (lying sideways) → unexpected for PSX; investigate per-title.
3. Update the status table above as each title is confirmed.

---

## Adding a new PSX title later

1. Drop the disc image into `/userdata/roms/psx/` (`.chd` preferred). If multi-disc, also create the `.m3u`.
2. Launch and observe.
3. **If correctly vertical and fullscreen** → done. The first launch creates `/userdata/saves/psx/<rom_stem>.srm` (and `.1.mcr` once the game writes to its memory card) automatically.
4. **If stretched horizontally** → likely a Cave-family-style YOKO-mode title. Write a per-game cfg using the DoDonPachi/Donpachi template (above), enable in-game TATE in the game's Options menu, exit + relaunch.
5. **If double-rotated (lying sideways)** → unexpected. Compare to the per-title status table; may be a hi-res PSX mode (640×480) or a 3D title with a non-standard render path. Investigate per-title.

---

## Save / state directory layout

After PSX titles are launched on this cabinet:

| File | Purpose |
|------|---------|
| `/userdata/saves/psx/<rom_stem>.srm` | RAM dump used by some games / shared assets; auto-created on first launch |
| `/userdata/saves/psx/<rom_stem>.1.mcr` | **PSX virtual memory card slot 1.** Stores game saves AND user-chosen Options (including TATE Mode on/off). Created when a game writes to its memory card (DoDonPachi/Donpachi auto-write Options on Options-menu exit). |
| `/userdata/saves/psx/<rom_stem>.2.mcr` | Memory card slot 2 (rarely used) |
| `/userdata/saves/psx/<rom_stem>.state.auto[.png]` | RetroArch savestate (NOT deployed by this recipe) |

For this recipe, the only meaningful files are the `.1.mcr` files for the 2 Cave titles. For redistribution via autoconfig, ship those two as static assets.

---

## Hard locks for this approach to work

- **Core: `pcsx_rearmed` only.** Per-game cfgs live in `PCSX-ReARMed/`. Switching `psx.core` to `mednafen_psx` (Beetle PSX HW), `swanstation`, or standalone `duckstation` invalidates the per-game cfgs (different directory name) and changes the rendering path. PSX memory card content (`.1.mcr`) IS core-independent, but the rest of the recipe is core-tied.
- **PSX BIOS in `/userdata/bios/`.** Without `scph1001.bin` (or equivalent), `pcsx_rearmed` falls back to HLE BIOS which may have subtle compatibility issues with shmup intros. Real BIOS recommended for the full roster.
- **Rotation polarity.** `=3` assumes the cabinet is mounted with the screen's bottom on the cabinet's right (270° CCW logical rotation). Mirrored cabinets use `=1`. Per-game `=0` overrides are mount-independent because they leave game-internal TATE alone to drive rotation.
- **Custom viewport dimensions are cabinet-specific.** The `480 × 640` values in the per-game cfgs match THIS cabinet's portrait CRT super-res. On a cabinet with a different display size or videomode, query `global.videomode` + `display.rotate` and write the post-rotation portrait dimensions. Wrong viewport dimensions produce off-screen or shrunk-in-middle results.
- **Geometry.** This recipe assumes v43 + CRT Script has already produced correct PSX resolution. The three system-wide keys above add rotation + fill on top of that geometry; they do not set videomode. If a fresh CRT Script install produces wrong PSX geometry, fix that first (separately from this recipe).
- **Memory card content is the persistence layer.** If `/userdata/saves/psx/DoDonPachi.1.mcr` is deleted, the in-game TATE setting reverts and the per-game cfg will render content sideways on next launch until the operator re-enables TATE in-game. Treat `.1.mcr` files for the Cave titles as part of the recipe asset bundle.

---

## Risks / gotchas

- **PSX YOKO-with-side-panels detection is empirical.** The list of titles needing per-game cfg + in-game TATE (currently 2) was found by launch + observation. Any new title that comes back stretched should be added to the per-game cfg list and have its in-game TATE enabled. Conversely, do NOT preemptively write per-game cfgs for untested titles — a cfg with `video_rotation = "0"` on a title that has NOT had in-game TATE enabled will render content lying on its side.
- **Aspect-ratio-index value `24` is RA-version-specific.** This RA build maps `24 = Custom`, `25 = Full`. Older RA builds may differ. If transplanting this recipe to a non-Batocera-v43 install, verify the RA version's aspect_ratio_index enum first.
- **`psx.ratio=full` does double duty.** It actually sets `aspect_ratio_index = "24"` (Custom) + a default `640 × 480` custom viewport at the configgen layer, NOT a true "stretch every framebuffer". For most titles this happens to fill the rotated portrait screen correctly. The per-game cfgs override with the SAME aspect index but a different viewport sized for explicit portrait-orientation 480×640.
- **Mid-session progress lost on quit?** No. PSX uses memory cards (`.1.mcr`) for game saves, and `pcsx_rearmed` writes the memory card live during play. No `savestate_auto_*` interaction. Quit-and-resume works normally.
- **Per-game cfg owner-perms.** Generate with `chmod 644`. Root reads `600` but matching `644` perms removes a misleading variable during diagnosis.
- **Hi-res PSX titles (640×480) untested.** RayStorm / RayCrisis / Xevious 3D-G+ may render at PSX's 640×480 mode. Aspect-correct stretching may behave differently. Test these explicitly; they may need their own per-game cfg variant.

---

## QA checklist (current as of 2026-05-23)

1. **Keys present:**
   ```bash
   batocera-settings-get psx.retroarch.video_rotation        # → 3
   batocera-settings-get psx.ratio                            # → full
   batocera-settings-get psx.retroarch.video_force_aspect    # → false
   ```
2. **BIOS present:**
   ```bash
   ls /userdata/bios/scph*.bin
   ```
3. **Per-game cfgs present (Cave titles):**
   ```bash
   ls /userdata/system/configs/retroarch/config/PCSX-ReARMed/
   # → DoDonPachi.cfg, Donpachi.cfg
   ```
4. **Memory cards present (Cave titles, after operator TATE-enabled step):**
   ```bash
   ls /userdata/saves/psx/DoDonPachi.1.mcr /userdata/saves/psx/Donpachi.1.mcr
   ```
5. **Launch test matrix:**
   - One system-wide-recipe title (e.g. **Airgrave** or **Strikers 1945**) → rotated correctly, fullscreen.
   - One Cave title with TATE enabled (e.g. **DoDonPachi**) → rotated correctly, fullscreen TATE, no side panels stretched.
   - Quit, relaunch the Cave title: TATE setting persisted via the `.1.mcr` (mtime unchanged unless game writes again).

---

## SSH note (`ssh-batocera.sh`)

```bash
~/bin/ssh-batocera.sh 10.23.6.210 'grep ^psx /userdata/system/batocera.conf'
~/bin/ssh-batocera.sh 10.23.6.210 'ls /userdata/system/configs/retroarch/config/PCSX-ReARMed/'
~/bin/ssh-batocera.sh 10.23.6.210 'ls /userdata/saves/psx/*.1.mcr 2>/dev/null'
```

When writing per-game cfgs that include `aspect_ratio_index = "24"` style multi-key contents, prefer writing the generator script to a local file and `rsync`-ing it to `/tmp/` on the cabinet, then SSH to `chmod +x && run`. Embedding multi-line `cat <<'EOF'` blocks directly inside an SSH command string is fragile (nested expect quoting eats backslashes).

---

## Links

- Generator merge spec: [psx-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/psx-vertical-autoconfig.md)
- Dreamcast (similar fill triplet + per-game rotation overrides for in-game-TATE titles, plus state-injection): [dreamcast-vertical-vanilla-v43.md](dreamcast-vertical-vanilla-v43.md)
- NAOMI (simpler rotation-only recipe, also on Flycast): [naomi-vertical-vanilla-v43.md](naomi-vertical-vanilla-v43.md)
- Sibling vertical specs: [pcengine-vertical-vanilla-v43.md](pcengine-vertical-vanilla-v43.md), [snes-vertical-vanilla-v43.md](snes-vertical-vanilla-v43.md), [vectrex-vertical-vanilla-v43.md](vectrex-vertical-vanilla-v43.md), [saturn-vertical-vanilla-v43.md](saturn-vertical-vanilla-v43.md)
- Myzar source reference (different core `mednafen_psx`, different polarity, similar per-game cfg pattern in `Beetle PSX HW/`): [`2026-05-21_crt-myzar-dp-hybrid-switchres/research/emulator-expected-resolutions.md`](../../2026-05-21_crt-myzar-dp-hybrid-switchres/research/emulator-expected-resolutions.md)
