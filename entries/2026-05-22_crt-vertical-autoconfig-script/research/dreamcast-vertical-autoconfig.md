# Sega Dreamcast (Flycast) — autoconfig spec (vanilla vertical)

## Canonical prior art

Cabinet-tested deployment (18 titles, 36 state files, 9 in-game-TATE per-game cfgs, decoupled autoload/autosave, system-wide rotation):
[dreamcast-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/dreamcast-vertical-vanilla-v43.md)

## Reading this from a fresh install

The generator runs on a cabinet that already has:

- Vanilla Batocera v43 + CRT Script vertical install (`display.rotate=1`, correct CRT geometry + super-res ladder).
- Dreamcast ROMs in `/userdata/roms/dreamcast/`.
- Dreamcast BIOS (`dc_boot.bin`, `dc_flash.bin`) in `/userdata/bios/`.

It must not touch the display profile, global rotation, videomodes, or any other system. It only writes the five `dreamcast.*` keys, the per-game `Flycast/*.cfg` overrides, and (optionally) deploys state files from a packaged bundle.

## How this differs from the Saturn autoconfig

Saturn's vertical mode is captured **inside Saturn RAM**, so a `.state.auto` snapshot is sufficient and no per-game rotation cfg is needed. Dreamcast is more complex because two different mechanisms can rotate the picture:

1. **RetroArch frontend `video_rotation`** — RA rotates the framebuffer before submitting it to the display.
2. **The game's own in-game TATE / Yoko menu option** — the game itself draws content rotated within its 640×480 framebuffer. This is captured in the savestate (it lives in Dreamcast RAM at the moment of capture).

When BOTH are active, the picture is double-rotated and ends up wrong. The autoconfig must therefore pick rotation **per title** based on whether the savestate has in-game TATE on or off.

Net mechanism for Dreamcast: **system-wide rotation key (default = 3) + state-injection + decoupled autoload + per-game `video_rotation = "0"` cfgs for in-game-TATE-on titles + system-wide fill geometry.**

## Config paths (Batocera)

| Layer | Path |
|-------|------|
| Per-system keys | `/userdata/system/batocera.conf` (`dreamcast.*`) |
| Per-game rotation override | `/userdata/system/configs/retroarch/config/Flycast/<ROM_STEM>.cfg` |
| Save / state directory | `/userdata/saves/dreamcast/` |
| Core (locked) | **`flycast`** on x86_64 (`configgen-defaults-x86_64.yml`); states are core-tied, do not switch to `flycastvl` or `redream` |

## Script should implement

### Step 1 — Set the six `dreamcast.*` keys (idempotent)

```bash
batocera-settings-set dreamcast.autosave 0
batocera-settings-set dreamcast.ratio full
batocera-settings-set dreamcast.retroarch.video_force_aspect false
batocera-settings-set dreamcast.retroarch.video_rotation "$ROTATION"   # default 3, operator override 1 for mirrored cabinets
batocera-settings-set dreamcast.retroarch.savestate_auto_load true
batocera-settings-set dreamcast.retroarch.savestate_auto_save false
```

Why each key (per `libretroConfig.py` and the cabinet-tested doc):

| Key | Effect |
|-----|--------|
| `dreamcast.autosave=0` | Suppresses the convenience block that would otherwise set both `savestate_auto_*` to true. |
| `dreamcast.ratio=full` + `dreamcast.retroarch.video_force_aspect=false` | Rotated 640×480 buffer fills the active super-res. Without this, the picture letterboxes. |
| `dreamcast.retroarch.video_rotation=3` | System-wide rotation 270° CCW. Pinned at the launch-time `retroarchcustom.cfg` layer, so it cannot be lost to RA's per-content override race. **Per-game `=0` cfgs override this for in-game-TATE titles.** |
| `dreamcast.retroarch.savestate_auto_load=true` / `..._save=false` | Load curated state on launch, never overwrite on exit. Pristine baseline survives every play session. |

### Step 2 — Deploy the state bundle (if available)

```bash
rsync -av --include='*.state.auto' --include='*.state.auto.png' --exclude='*' \
  "$ASSET_DIR/"  /userdata/saves/dreamcast/
chown -R root:root /userdata/saves/dreamcast/*.state.auto*
```

- Match by **ROM display name** (e.g. `Ikaruga (Japan).state.auto` for `Ikaruga (Japan).chd`).
- Bundle files for ROMs not present are harmless (inert).
- Skip silently if `$ASSET_DIR` is unset / empty.
- Re-running re-pushes the pristine bundle. Operators can use this to roll back any drift.

### Step 3 — Per-game `video_rotation` cfgs for in-game-TATE titles

```bash
mkdir -p /userdata/system/configs/retroarch/config/Flycast
for stem in $TATE_ROM_STEMS; do
  printf 'video_rotation = "0"\n' > "/userdata/system/configs/retroarch/config/Flycast/${stem}.cfg"
  chmod 644 "/userdata/system/configs/retroarch/config/Flycast/${stem}.cfg"
done
chown -R root:root /userdata/system/configs/retroarch/config/Flycast
```

- **Only the rotation key** is written. Do NOT add `aspect_ratio_index`, `custom_viewport_*`, or other Myzar-style geometry — fill is handled by the system-wide `dreamcast.*` keys.
- `chmod 644` matches all other RA cfgs on the system. Defensive — root can read `600` but matching perms removes a misleading symptom during future diagnosis.
- Do NOT write per-game cfgs for the non-TATE titles. They would be redundant with the system-wide key and confuse the next maintainer about which files matter.

### Step 4 — Filename hygiene

Spaces, parentheses, commas, ampersands in ROM names must be preserved verbatim (`Mars Matrix (Japan) (En,Ja).state.auto`, `Triggerheart Exelica (Japan).cfg`, `ImageFight & Xmultiply.state.auto`). Do not slugify.

When generating per-game cfgs with shell loops, write the generator to a local file and run it via `bash <script>` rather than embedding multi-line `printf` directly in an SSH command — expect / nested-quoting mangles parens and commas in remote command strings.

### Step 5 — Do NOT touch

- `dreamcast.videomode` — v43's CRT Script geometry handles this.
- `dreamcast.retroarch.crt_switch_resolution` — global already controls Switchres for the CRT Script display profile.
- `Flycast/Flycast.cfg`, `Flycast/dreamcast.cfg`, `Flycast/Flycast.opt` — Myzar's per-system flycast configs (`video_rotation = "1"`, `aspect_ratio_index = "24"`, `reicast_screen_rotation = "vertical"`) are explicitly rejected for v43 (wrong rotation polarity, wrong viewport, would change core render path away from cabinet-tested baseline).

### Step 6 — Subsystem filter

`--only=dreamcast` touches exactly:

- The six `dreamcast.*` keys in `batocera.conf`.
- Files under `/userdata/saves/dreamcast/*.state.auto*`.
- Files under `/userdata/system/configs/retroarch/config/Flycast/*.cfg`.

Nothing else.

### Step 7 — Optional `--clean` (dangerous)

Removes `*.state.auto*` from `/userdata/saves/dreamcast/` and the per-game `Flycast/*.cfg` files before reseeding. Default: off. User-facing warning required.

## Manifest format

The script needs a manifest of which ROMs are in-game-TATE (need `=0`) versus default (use system-wide `=3`). Simplest form: two lists.

```yaml
# dreamcast-vertical.manifest.yml
rotation_default: 3
rotation_override_value: 0

# Titles whose curated savestate has in-game TATE ENABLED.
# RA must NOT add rotation, the game's internal rotation is the only one.
tate_on_in_savestate:
  - "Ikaruga (Japan)"
  - "Karous"
  - "NEO XYX"
  - "Triggerheart Exelica (Japan)"
  - "Trizeal"
  - "Under Defeat (Japan)"
  - "Radirgy"
  - "Psyvariar 2 The Will to Fabricate"
  - "Shikigami no Shiro II (Japan)"

# Optional explicit allowlist; if absent, deploy whatever .state.auto pairs
# the bundle contains for ROMs present in /userdata/roms/dreamcast/.
state_roster:
  - "Chaos Field (Japan)"
  - "Drill"
  - "Fast Striker"
  - "GigaWing 2 (USA)"
  - "Gigawing"
  - "Gunbird 2"
  - "Ikaruga (Japan)"
  - "Karous"
  - "Mars Matrix (Japan) (En,Ja)"
  - "NEO XYX"
  - "Psyvariar 2 The Will to Fabricate"
  - "Radirgy"
  - "Shikigami no Shiro II (Japan)"
  - "Triggerheart Exelica (Japan)"
  - "Trizeal"
  - "Twinkle Star Sprites (Japan) (En,Ja,Es)"
  - "Under Defeat (Japan)"
  - "Zero Gunner 2 (Japan) (En,Ja)"
```

**Important nuance:** the `tate_on_in_savestate` list is empirical, not a function of "does the game have an in-game TATE menu." Several titles (Mars Matrix, Zero Gunner 2) have an in-game TATE menu but their curated savestates captured them with TATE off, so they use the system-wide `=3`. The only way to know is to launch and observe. Document new entries as they are discovered.

## Validation targets for script

- [ ] Dry-run shows only: the six `dreamcast.*` key changes, the state file list, and the per-game cfg list. No other `batocera.conf` edits, no display profile changes, no global key changes.
- [ ] On apply:
  - `batocera-settings-get dreamcast.retroarch.savestate_auto_load` → `true`
  - `batocera-settings-get dreamcast.retroarch.savestate_auto_save` → `false`
  - `batocera-settings-get dreamcast.ratio` → `full`
  - `batocera-settings-get dreamcast.retroarch.video_force_aspect` → `false`
  - `batocera-settings-get dreamcast.retroarch.video_rotation` → `3`
- [ ] Every entry in `tate_on_in_savestate` has a matching `Flycast/<stem>.cfg` containing exactly `video_rotation = "0"` (no other keys, mode 644, root:root).
- [ ] No `Flycast/<stem>.cfg` exists for titles NOT in `tate_on_in_savestate` (clean directory; every file is an exception).
- [ ] State files present in `/userdata/saves/dreamcast/`, owned `root:root`.
- [ ] Launching a default-rotation seeded title (e.g. Chaos Field) comes up rotated CCW, fills the screen, mid-game.
- [ ] Launching a `=0`-override seeded title (e.g. Ikaruga) comes up rotated correctly via the in-game TATE alone, no double-rotation.
- [ ] Play → quit → relaunch: state file size and mtime unchanged (RA did not overwrite).

## Risks / gotchas

- **Core lock.** States are tied to `flycast`. Switching `dreamcast.core` to `flycastvl` or `redream` breaks every seeded state. Generator must refuse / warn if `dreamcast.core` is anything other than `flycast`.
- **Rotation polarity.** `=3` and `=0` overrides assume the cabinet is mounted with the screen's bottom on the cabinet's right (270° CCW logical rotation). Mirrored cabinets need `=1` system-wide and the per-game overrides may need different values. Provide a `--rotation=1|3` operator flag for the system-wide value; the per-game `=0` (no RA rotation) is mount-independent because it leaves the game's in-game TATE alone to drive rotation.
- **In-game-TATE list is empirical.** Adding a new title to the bundle requires a test launch. Generator should print a warning if `state_roster` contains titles not listed in either `tate_on_in_savestate` or a "validated default-rotation" list, prompting the operator to test and update the manifest.
- **Mid-session progress is not preserved on exit.** Same as Saturn; intended for arcade vertical shmups. Generator should print a one-line operator note about this so end-users understand the design choice.
- **Geometry assumption.** This spec assumes the cabinet has correct Dreamcast resolution from v43's CRT Script + display profile. On a fresh install with wrong defaults, geometry has to be fixed separately (or via a future Dreamcast geometry preset, distinct from this state-seed path).
- **Saving the manifest as data, not code.** Operators will add and remove titles over time. Keep the in-game-TATE list in a manifest file (yaml / csv) the generator reads, not hard-coded into the shell script. That way an update is a manifest edit, not a code review.

## See also

- [naomi-vertical-autoconfig.md](naomi-vertical-autoconfig.md): same `flycast` core, simpler deploy (rotation-only, no state-injection, no fill keys). Shares `Flycast/` per-game cfg dir with this spec — generators that write into that dir for either system must filter by ROM stem to avoid cross-contamination (NAOMI MAME short stems like `trizeal.cfg` vs Dreamcast display-name stems like `Trizeal.cfg` — no real-world collision but defensive filter required).
- [saturn-vertical-autoconfig.md](saturn-vertical-autoconfig.md): same state-injection + decoupled autoload pattern, **no** per-game rotation cfg needed (Saturn rotation is in-game and captured in the savestate).
- [psx-vertical-autoconfig.md](psx-vertical-autoconfig.md): shares the rotation + ratio=full + force_aspect=false triplet (different system prefix), but skips state-injection (PSX persists in-game TATE to its own memory card live during play). PSX per-game cfgs are richer (full custom viewport for Cave-family side-panel titles, not just rotation kill).
- [snes-vertical-autoconfig.md](snes-vertical-autoconfig.md), [pcengine-vertical-autoconfig.md](pcengine-vertical-autoconfig.md), [vectrex-vertical-autoconfig.md](vectrex-vertical-autoconfig.md): geometry-class specs (different mechanism — videomode + ratio).
- [dreamcast-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/dreamcast-vertical-vanilla-v43.md): cabinet-tested deployment with full per-title rotation matrix, deploy procedure, gotchas.
