# Sega Saturn (Beetle Saturn) — autoconfig spec (vanilla vertical)

## Canonical prior art

Cabinet-tested deployment (38 titles, 76 state files, decoupled autoload/autosave):
[saturn-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/saturn-vertical-vanilla-v43.md)

## How this differs from the other autoconfig specs

PCE, SNES, FBNeo, and Vectrex specs set **`<system>.videomode`**, **`<system>.ratio`**, and RetroArch keys to produce the correct **geometry / rotation** at launch. **On this cabinet, v43 already produces the correct Saturn geometry and rotation with no Saturn-specific keys.** The Saturn problem is **time-to-play** (skip Sega/Saturn/game intros) and the fact that some titles only flip to **TATE** via an **in-game options menu** that would be annoying to set every boot.

The Saturn solution is therefore **state-injection**, not geometry:

1. **Seed `/userdata/saves/saturn/<Game>.state.auto` (+ `.state.auto.png`)** with a snapshot captured **past** the splash screens and **after** the in-game vertical / Side toggle was set.
2. **Auto-load on launch, never overwrite on exit.** This keeps the curated baseline pristine across play sessions.

No videomode, ratio, rotation, viewport, or `crt_switch_resolution` keys are written.

## Config paths (Batocera)

| Layer | Path |
|-------|------|
| Per-system keys | `/userdata/system/batocera.conf` (`saturn.*`) |
| Save / state directory | `/userdata/saves/saturn/` (Batocera maps both `savefile_directory` and `savestate_directory` here) |
| Core (locked) | **`beetle-saturn`** on x86_64 (`configgen-defaults-x86_64.yml`); states are core-tied, do not switch to `yabasanshiro` |

## Script should implement

1. **Decouple autoload from autosave** (idempotent):

   ```bash
   batocera-settings-set saturn.autosave 0
   batocera-settings-set saturn.retroarch.savestate_auto_load true
   batocera-settings-set saturn.retroarch.savestate_auto_save false
   ```

   Why three keys: Batocera's `<system>.autosave=1` couples `savestate_auto_save = true` with `savestate_auto_load = true` (see `libretroConfig.py` `autosave` block). That would let RA overwrite the curated `.state.auto` on quit. Setting `autosave=0` sets both to `false`, then the two explicit `retroarch.*` pass-through keys flip only the **load** side back to `true`. Result: RA loads the curated state on launch and never writes over it.

2. **Deploy the state bundle** from a packaged source (e.g. CRT Script `assets/saturn-vertical-states/`) into `/userdata/saves/saturn/`:

   ```bash
   rsync -av --include='*.state.auto' --include='*.state.auto.png' --exclude='*' \
     ASSET_DIR/  /userdata/saves/saturn/
   chown -R root:root /userdata/saves/saturn/*.state.auto*
   ```

   - Match by **ROM display name** (e.g. `Batsugun.state.auto` for `Batsugun.chd`). Filename stem must equal the launched content stem.
   - Bundle files only deploy for ROMs that actually exist on the cabinet (or just push everything; orphans are harmless).
   - **Re-running re-pushes the pristine bundle.** Operator can use this to roll back any drift.

3. **Filename hygiene:** spaces and punctuation in ROM names matter (`Battle Garegga.state.auto`, `ImageFight & Xmultiply.state.auto`). Preserve verbatim from the source bundle; do not slugify.

4. **Do not touch** any of: `saturn.videomode`, `saturn.ratio`, other `saturn.retroarch.*` (besides the two savestate flags above), or `/userdata/system/configs/retroarch/config/Beetle Saturn/*`. Geometry is the cabinet's existing CRT Script + display profile; this generator only handles state seeds.

5. **Subsystem filter:** `--only=saturn` touches the three `saturn.*` keys and files under `/userdata/saves/saturn/` only.

6. **`--clean` (optional, dangerous):** remove `*.state.auto*` from `/userdata/saves/saturn/` before reseeding. Default: off. User-facing warning required.

## Manifest format (optional)

Plain list of ROM stems to deploy. Empty manifest deploys whatever `.state.auto` files exist in the bundle.

| Column | Meaning |
|--------|---------|
| `rom_basename` | e.g. `Batsugun.chd` |
| `state_source` | optional path inside bundle; default = `<rom_stem>.state.auto` |

## Validation targets for script

- [ ] Dry-run shows only the three `saturn.*` key changes and the file list to copy, no other `batocera.conf` edits.
- [ ] On apply, `batocera-settings-get saturn.retroarch.savestate_auto_load` returns `true` and `...savestate_auto_save` returns `false`.
- [ ] State files present and owned `root:root`.
- [ ] Launching a seeded title resumes mid-game in correct orientation with v43's existing geometry untouched.
- [ ] Play → quit → relaunch: state file size and mtime unchanged (RA did not overwrite).
- [ ] Launching an unseeded title (no `.state.auto`) boots cold as normal.

## Risks / gotchas

- **Core lock.** States are tied to `beetle-saturn`. If a user changes `saturn.core` to `yabasanshiro`, the seeded states will not load. The generator should refuse to run (or warn) if `saturn.core` is set to anything other than `beetle-saturn`.
- **Geometry assumption.** This spec assumes the cabinet already has correct Saturn geometry. On a fresh install where v43 / CRT Script defaults produce wrong geometry, that has to be fixed by the operator (or by a future Saturn geometry preset, separate from this state-seed path).
- **In-game progress is not preserved across sessions.** Because `savestate_auto_save = false`, anything the player accomplishes in a session is lost on quit. That is the **intended** behavior for arcade-style vertical shmups where the goal is "always boot to the curated baseline." Players who want to save mid-run should use a manual savestate slot (`F2` → Slot 1, etc.) which is independent of `.state.auto`.

## See also

- [snes-vertical-autoconfig.md](snes-vertical-autoconfig.md), [pcengine-vertical-autoconfig.md](pcengine-vertical-autoconfig.md), [vectrex-vertical-autoconfig.md](vectrex-vertical-autoconfig.md): geometry-class specs (different mechanism).
- [dreamcast-vertical-autoconfig.md](dreamcast-vertical-autoconfig.md): Dreamcast / Flycast variant — same state-injection decoupled-autoload pattern, **plus** per-game `video_rotation = "3"` cfgs (Dreamcast games render horizontal; rotation is RA-side, not in the savestate).
- [naomi-vertical-autoconfig.md](naomi-vertical-autoconfig.md): rotation-only (one key, no state-injection — opposite end of the complexity scale from Saturn).
- [psx-vertical-autoconfig.md](psx-vertical-autoconfig.md): rotation + fill + per-game custom viewport (no state-injection — PSX persists in-game TATE to its own memory card live during play).
- [saturn-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/saturn-vertical-vanilla-v43.md): cabinet-tested deployment with title list and Myzar source.
