# Sony PlayStation (PSX, `pcsx_rearmed`) — autoconfig spec (vanilla vertical)

## Canonical prior art

Cabinet-tested deployment (10 of 30 titles verified — 8 system-wide PASS, 2 Cave-family PASS with per-game cfg + in-game TATE):
[psx-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/psx-vertical-vanilla-v43.md)

## Reading this from a fresh install

The generator runs on a cabinet that already has:

- Vanilla Batocera v43 + CRT Script vertical install (`display.rotate=1`, correct CRT geometry + super-res ladder).
- PSX disc images in `/userdata/roms/psx/` (`.chd` preferred; `.pbp`, `.cue+bin`, `.m3u` also supported).
- **PSX BIOS** in `/userdata/bios/` (`scph1001.bin` or equivalent; required for `pcsx_rearmed` for full compatibility).
- Default core unchanged (`pcsx_rearmed` in `configgen-defaults-x86_64.yml`).

It must not touch the display profile, global rotation, videomodes, or any other system. **As of 2026-05-23 it writes three `psx.*` keys** to `batocera.conf`, **two per-game cfgs** for the Cave family, and optionally bundles two PSX memory cards (`.1.mcr`) so the operator skips the manual in-game TATE step.

## How this differs from the Dreamcast / NAOMI autoconfigs

PSX, Dreamcast, and NAOMI all need rotation. PSX and Dreamcast both need fill keys. PSX adds per-game cfgs richer than Dreamcast's (full custom viewport, not just rotation kill) but skips Dreamcast's state-injection (PSX persists in-game TATE to its own memory card, no RA savestate needed).

| Concern | PSX | Dreamcast | NAOMI |
|---------|-----|-----------|-------|
| Core | `pcsx_rearmed` | `flycast` | `flycast` |
| Per-game cfg dir | `PCSX-ReARMed/` | `Flycast/` | `Flycast/` (shared) |
| State-injection | **No.** PSX writes to its own memory card live during play. | Yes. Six titles need a savestate. | No. |
| Autosave decoupling keys | **No.** | Yes (3 keys). | No. |
| System-wide rotation | Yes (`psx.retroarch.video_rotation=3`) | Yes | Yes |
| System-wide fill keys | Yes (`psx.ratio=full` + `psx.retroarch.video_force_aspect=false`) | Yes (same pair, `dreamcast.*`) | No (NAOMI 640×480 fills natively) |
| Per-game cfgs | **2 titles**, full custom viewport + `video_rotation = "0"` | 9 titles, only `video_rotation = "0"` | 0 (or conditional on NVRAM TATE state) |
| In-game TATE storage | **PSX memory card** (`/userdata/saves/psx/<stem>.1.mcr`), core-independent | Dreamcast RAM (captured in `.state.auto`, core-tied) | NAOMI NVRAM (`.zip.nvmem`, core-tied) |
| Assets bundled by autoconfig | 2 per-game cfgs + (optionally) 2 `.1.mcr` files | savestates + per-game cfgs + 3 batocera.conf keys + 3 retroarch keys | system-wide key only (plus conditional per-game cfgs) |

Net mechanism for PSX: **3 system-wide keys + per-game custom-viewport cfgs for the Cave family + (optional) bundled memory cards for the Cave family.**

## Config paths (Batocera)

| Layer | Path |
|-------|------|
| Per-system keys | `/userdata/system/batocera.conf` (`psx.*`) |
| Per-game custom viewport | `/userdata/system/configs/retroarch/config/PCSX-ReARMed/<ROM_STEM>.cfg` |
| PSX memory card slot 1 (persistence layer for in-game TATE) | `/userdata/saves/psx/<ROM_STEM>.1.mcr` |
| PSX memory card slot 2 (rarely used) | `/userdata/saves/psx/<ROM_STEM>.2.mcr` |
| RAM dump (auto-created by some games) | `/userdata/saves/psx/<ROM_STEM>.srm` |
| Savestates (NOT used by this recipe) | `/userdata/saves/psx/<ROM_STEM>.state.auto[.png]` |
| Core (locked) | **`pcsx_rearmed`** on x86_64 (`configgen-defaults-x86_64.yml`); per-game cfgs are core-tied via `PCSX-ReARMed/` dir name. Memory cards are core-INdependent. |

## Script should implement

### Step 1 — Set the three `psx.*` keys (idempotent)

```bash
batocera-settings-set psx.retroarch.video_rotation "$ROTATION"        # default 3, operator override 1 for mirrored cabinets
batocera-settings-set psx.ratio "full"
batocera-settings-set psx.retroarch.video_force_aspect "false"
```

That is the entire mandatory `batocera.conf` write. Do NOT preemptively set `psx.autosave`, `psx.retroarch.savestate_auto_*`, or any other keys — they are not needed and would diverge from the cabinet-tested baseline.

### Step 2 — Per-game custom-viewport cfgs for the Cave family (conditional)

For each entry in the (operator-supplied) `cave_family` manifest:

```bash
mkdir -p /userdata/system/configs/retroarch/config/PCSX-ReARMed
for stem in $CAVE_STEMS; do
  cat > "/userdata/system/configs/retroarch/config/PCSX-ReARMed/${stem}.cfg" <<EOF
aspect_ratio_index = "24"
custom_viewport_width = "${PORTRAIT_W}"
custom_viewport_height = "${PORTRAIT_H}"
custom_viewport_x = "0"
custom_viewport_y = "0"
video_rotation = "0"
video_force_aspect = "true"
video_scale_integer = "false"
EOF
  chmod 644 "/userdata/system/configs/retroarch/config/PCSX-ReARMed/${stem}.cfg"
done
chown -R root:root /userdata/system/configs/retroarch/config/PCSX-ReARMed
```

- `PORTRAIT_W / PORTRAIT_H` come from the cabinet profile. On this cabinet: `480 × 640` (post-rotation portrait dimensions for the 641×480 landscape super-res). **The generator must compute these from `global.videomode` + `display.rotate`**, not hardcode. Wrong dimensions produce off-screen or shrunk-in-middle results.
- `aspect_ratio_index = "24"` is RA's "Custom" aspect index in this RA build. **Verify the RA enum at generator time** in case of future RA upgrades.
- `video_rotation = "0"` is mount-independent — these titles render portrait inside their own framebuffer via the game's TATE option; RA must NOT add another rotation regardless of mount polarity.
- `video_force_aspect = "true"` is the per-game override of the system-wide `false`.
- `video_scale_integer = "false"` is required; PSX framebuffer dimensions don't divide evenly into portrait CRT dimensions.
- `chmod 644` matches every other RA cfg.
- Do NOT write per-game cfgs for the non-Cave titles. Every file in `PCSX-ReARMed/` should be an exception.
- The default `cave_family` list ships with `["DoDonPachi", "Donpachi"]` because those are the two cabinet-tested Cave titles. The list is editable per cabinet — if a future PSX roster adds (e.g.) ESP Ra.De. or Mushihimesama PSX (none exist commercially, but for symmetry with future cores), the operator extends the list.

### Step 3 — (Optional) bundle PSX memory cards for the Cave family

The per-game cfg is **inert** until the operator enables in-game TATE on the matching title. To skip that manual step, the autoconfig MAY bundle two cabinet-captured `.1.mcr` files as static assets:

```bash
if [ "$BUNDLE_MEMORY_CARDS" = "yes" ]; then
  mkdir -p /userdata/saves/psx
  for stem in $CAVE_STEMS; do
    src="$BUNDLE_DIR/psx/${stem}.1.mcr"
    dst="/userdata/saves/psx/${stem}.1.mcr"
    if [ -f "$src" ] && [ ! -f "$dst" ]; then
      cp "$src" "$dst"
      chmod 644 "$dst"
    fi
  done
fi
```

- **Skip-if-exists.** Never overwrite an operator's existing memory card — they may have game saves there. The bundled `.1.mcr` is only meaningful for cabinets that have never launched the title.
- **Core-independent.** The same `.1.mcr` works with `pcsx_rearmed`, `mednafen_psx` (Beetle PSX HW), `swanstation`, and standalone `duckstation`. Bundling is safe even if a future operator switches cores.
- **Provenance disclosure.** The bundled `.1.mcr` was captured on a specific cabinet at a specific date with a specific in-game TATE setting. Generator should log which titles received bundled memory cards so the operator can audit.
- **Default: `BUNDLE_MEMORY_CARDS=yes`.** The two `.1.mcr` files are ~128KB each, total bundle weight is negligible, and skipping the in-game TATE step is a meaningful UX win. Operators with privacy / provenance concerns can set `no` and fall back to the manual procedure documented in `psx-vertical-vanilla-v43.md`.

### Step 4 — Do NOT touch

- `psx.videomode` — v43's CRT Script geometry handles this.
- `psx.retroarch.crt_switch_resolution` — global already controls Switchres for the CRT Script display profile.
- `psx.autosave` / `psx.retroarch.savestate_auto_*` — not used by this recipe; PSX persists state via its own memory cards, not RA savestates.
- `psx.core` — switching to `mednafen_psx`, `swanstation`, or standalone `duckstation` invalidates the per-game cfg directory (different dir name) and changes the rendering path. Even if the operator switches cores manually, the memory cards remain valid and can be re-cfg'd for the new core's dir.
- `PCSX-ReARMed/PCSX-ReARMed.cfg` / `.opt` — do NOT write per-system Myzar-style globals (those were tuned for a different core anyway). Keep all per-system tuning in `batocera.conf` (`psx.*`) so configgen owns it.
- `/userdata/saves/psx/<stem>.srm` — auto-created by some games; never touch.
- `/userdata/saves/psx/<stem>.state.auto[.png]` — savestates are not part of this recipe; do not generate, do not delete.
- Existing operator memory cards (`.1.mcr`, `.2.mcr`) — never overwrite; only seed when none exist.

### Step 5 — Subsystem filter

`--only=psx` touches exactly:

- The three `psx.*` keys in `batocera.conf`.
- Files under `/userdata/system/configs/retroarch/config/PCSX-ReARMed/<cave_stem>.cfg` (and only those matching the manifest).
- (If `BUNDLE_MEMORY_CARDS=yes`) `/userdata/saves/psx/<cave_stem>.1.mcr` if not already present.

Nothing else. Critically: does NOT delete or modify any existing memory card, savestate, RAM dump, or non-Cave `PCSX-ReARMed/*.cfg`.

### Step 6 — Optional `--clean` (dangerous)

Removes only the per-game `PCSX-ReARMed/<cave_stem>.cfg` files for stems in the manifest. Default: off. Must NOT remove the three system-wide keys, memory cards, savestates, RAM dumps, or any other PSX file.

### Step 7 — Manifest format

```yaml
# psx-vertical.manifest.yml
rotation_system_wide: 3       # 3 = 270° CCW (this cabinet); 1 = 90° CW (mirrored)
ratio: "full"
force_aspect: false
rotation_override_value: 0    # for per-game Cave-family overrides

cave_family:
  - DoDonPachi
  - Donpachi

# Cabinet portrait dimensions for per-game custom viewport.
# Generator must compute these from global.videomode + display.rotate
# at apply time, not hardcode. The values shown are for the 641x480
# super-res cabinet.
portrait_width: 480
portrait_height: 640

# Whether to seed PSX memory cards for the Cave family on first deploy.
# yes = skip operator's manual in-game TATE step (recommended for new cabinets).
# no  = leave memory cards alone; operator must enable in-game TATE per title.
bundle_memory_cards: yes

# Optional explicit roster (matches /userdata/roms/psx/*.{chd,pbp,m3u}).
# Used only by --validate to list which ROMs the operator considers in-scope.
roster:
  - Airgrave                              # cabinet-tested PASS 2026-05-23 (system-wide)
  - Detana Twinbee Yahoo! Deluxe Pack     # cabinet-tested PASS 2026-05-23 (system-wide)
  - Strikers 1945                         # cabinet-tested PASS 2026-05-23 (system-wide)
  - Strikers 1945 II                      # cabinet-tested PASS 2026-05-23 (system-wide)
  - Raiden DX                             # cabinet-tested PASS 2026-05-23 (system-wide)
  - Raiden Project                        # cabinet-tested PASS 2026-05-23 (system-wide)
  - Sonic Wings Special                   # cabinet-tested PASS 2026-05-23 (system-wide)
  - Toaplan Shooting Battle 1             # cabinet-tested PASS 2026-05-23 (system-wide)
  - DoDonPachi                            # cabinet-tested PASS 2026-05-23 (cfg + memory card + in-game TATE)
  - Donpachi                              # cabinet-tested PASS 2026-05-23 (cfg + memory card + in-game TATE)
  - Dezaemon Plus (Japan)                 # pending per-title launch
  - Galaga - Destination Earth (USA)      # pending
  - Gekioh - Shooting King                # pending
  - Gunbare! Game Tengoku 2               # pending
  - Kagaku Ninjatai Gatchaman - The Shooting   # pending
  - Meta-ph-list Micro.x.2297             # pending (multi-disc .m3u)
  - Night Raid                            # pending
  - Philosoma (USA)                       # pending
  - RayCrisis                             # pending (PSX hi-res 640x480 candidate)
  - RayStorm                              # pending (PSX hi-res 640x480 candidate)
  - SD Gundam - Over Galaxian             # pending
  - Soukyuu Gurentai - Oubushutsugeki     # pending
  - Stahlfeder - Tekkou Hikuudan          # pending
  - TRL - The Rail Loaders                # pending
  - Time Bokan Series - Bokan Desu Yo     # pending
  - Time Bokan Series - Bokan to Ippatsu! Doronboo   # pending
  - Two-Tenkaku                           # pending
  - Viewpoint                             # pending (isometric — orientation TBD)
  - Xevious 3D-G+                         # pending (PSX hi-res candidate)
  - Zanac x Zanac                         # pending
```

The default manifest ships with `cave_family: [DoDonPachi, Donpachi]` because those two are the cabinet-tested Cave family on this roster. The list is operator-extensible if future PSX titles exhibit the same Cave-family YOKO-with-side-panels behavior.

## Validation targets for script

- [ ] Dry-run shows only: the three `psx.*` key changes, the listed `PCSX-ReARMed/<stem>.cfg` writes, and (if `bundle_memory_cards=yes`) the listed `.1.mcr` seeds. No other `batocera.conf` edits, no display profile changes, no global key changes, no Flycast or other-core cfg touches.
- [ ] On apply:
  - `batocera-settings-get psx.retroarch.video_rotation` → `3` (or `1` per operator polarity).
  - `batocera-settings-get psx.ratio` → `full`.
  - `batocera-settings-get psx.retroarch.video_force_aspect` → `false`.
- [ ] Every entry in `cave_family` has a matching `PCSX-ReARMed/<stem>.cfg` containing exactly the 7 keys above (mode 644, root:root).
- [ ] No `PCSX-ReARMed/<stem>.cfg` exists for PSX stems NOT in `cave_family`.
- [ ] If `bundle_memory_cards=yes`: every `cave_family` entry has a matching `/userdata/saves/psx/<stem>.1.mcr` (mode 644, root:root). **Existing operator memory cards were not overwritten.**
- [ ] Existing operator savestates / RAM dumps are untouched.
- [ ] Launching one system-wide PASS title (e.g. **Airgrave**) → vertical, fullscreen.
- [ ] Launching one Cave title with bundled memory card (e.g. **DoDonPachi**) → vertical, fullscreen TATE, no operator action required.
- [ ] (If `bundle_memory_cards=no`) After operator enables in-game TATE manually on a Cave title, relaunch produces vertical fullscreen TATE.

## Risks / gotchas

- **Core lock.** Per-game cfgs are tied to `PCSX-ReARMed/` dir. Switching `psx.core` away from `pcsx_rearmed` invalidates the cfgs. Memory cards (`.1.mcr`) survive the core switch; cfgs do not.
- **Rotation polarity.** `=3` assumes the cabinet is mounted with the screen's bottom on the cabinet's right (270° CCW logical rotation). Mirrored cabinets need `=1` system-wide; per-game `=0` is mount-independent.
- **Memory card content is the persistence layer for in-game TATE.** If a Cave-title `.1.mcr` is later deleted, the in-game TATE setting reverts and the per-game cfg will render content lying on its side. Generator should document this coupling; ideally `--validate` would warn when a `cave_family` entry has a per-game cfg but no `.1.mcr` in `/userdata/saves/psx/`.
- **Aspect-ratio-index value `24` is RA-version-specific.** This Batocera v43 RA build maps `24 = Custom`, `25 = Full`. Generator should NOT hardcode `24` across future RA upgrades; instead, query or version-gate.
- **Portrait dimensions must be computed from cabinet config.** Hardcoding `480 × 640` would break on cabinets with different super-res values. Generator must read `global.videomode` (or `global.videooutput`-keyed videomode) + `display.rotate` to derive the post-rotation portrait dimensions.
- **PSX BIOS in `/userdata/bios/`.** `pcsx_rearmed` is somewhat permissive but real BIOS (`scph1001.bin`) is recommended. Generator should warn if no PSX BIOS file present.
- **Hi-res PSX titles (640×480 mode, e.g. RayStorm / RayCrisis / Xevious 3D-G+) untested.** They MAY need different custom viewport math (the 320×240 framebuffer assumption breaks). Validation sweep for these three should treat them as a separate test cohort.
- **`PCSX-ReARMed/` is not shared with other systems.** Unlike `Flycast/` (Dreamcast + NAOMI), PSX has its own dir, so the no-collision check that the NAOMI/Dreamcast generators need is unnecessary here.
- **Bundled memory cards leak provenance.** A `.1.mcr` captured on a specific cabinet includes that cabinet's player name / clear progress (none for fresh Cave saves, but worth verifying the bundled cards were captured fresh with only TATE flipped). If the bundle is publicly distributed, the generator's docs should make this explicit.

## See also

- [ps2-vertical-autoconfig.md](ps2-vertical-autoconfig.md): sequel system on standalone PCSX2-Qt; entirely different mechanism (PCSX2-Qt CLI `-statefile` instead of libretro `savestate_auto_load`; `chmod 444` lock instead of `autosave=0` decoupling).
- [dreamcast-vertical-autoconfig.md](dreamcast-vertical-autoconfig.md): same fill triplet + per-game rotation overrides, but with state-injection + autosave decoupling on top.
- [naomi-vertical-autoconfig.md](naomi-vertical-autoconfig.md): rotation-only, no fill keys, no per-game cfgs (in default state).
- [saturn-vertical-autoconfig.md](saturn-vertical-autoconfig.md): state-injection-class, different core, no rotation cfgs.
- [snes-vertical-autoconfig.md](snes-vertical-autoconfig.md), [pcengine-vertical-autoconfig.md](pcengine-vertical-autoconfig.md), [vectrex-vertical-autoconfig.md](vectrex-vertical-autoconfig.md): geometry-class specs (different mechanism — videomode + ratio).
- [psx-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/psx-vertical-vanilla-v43.md): cabinet-tested deployment with full per-title status table, memory card behavior notes, in-game TATE procedure, gotchas.
