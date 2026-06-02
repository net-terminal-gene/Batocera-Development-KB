# Sega NAOMI (Flycast) — autoconfig spec (vanilla vertical)

## Canonical prior art

Cabinet-tested deployment (1 title verified, 11 expected-PASS pending per-title sweep, no state-injection, no per-game cfgs):
[naomi-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/naomi-vertical-vanilla-v43.md)

## Reading this from a fresh install

The generator runs on a cabinet that already has:

- Vanilla Batocera v43 + CRT Script vertical install (`display.rotate=1`, correct CRT geometry + super-res ladder).
- NAOMI ROM zips in `/userdata/roms/naomi/`.
- NAOMI BIOS at `/userdata/roms/naomi/naomi.zip` (BIOS lives in the ROM dir for NAOMI, not in `/userdata/bios/`).

It must not touch the display profile, global rotation, videomodes, or any other system. **As of 2026-05-22 it writes exactly ONE key** to `batocera.conf` plus (optionally) a small per-game cfg directory for any NVRAM-stuck-TATE-on titles.

## How this differs from the Dreamcast autoconfig

NAOMI shares the `flycast` core with Dreamcast, so its per-game cfg directory is the same (`/userdata/system/configs/retroarch/config/Flycast/`). Everything else is simpler:

| Concern | NAOMI | Dreamcast |
|---------|-------|-----------|
| State-injection | **No.** Arcade ROMs boot to attract mode, no splash to skip. | Yes. Six titles need a savestate. |
| Autosave decoupling keys | **No.** No state files mean no `savestate_auto_*` keys. | Yes (3 keys). |
| Fill / aspect keys | **No.** NAOMI 640×480 fills the rotated super-res natively. | Yes (`ratio=full` + `video_force_aspect=false`). |
| System-wide rotation | **Yes.** `naomi.retroarch.video_rotation=3` (cabinet polarity). | Yes (`dreamcast.retroarch.video_rotation=3`). |
| Per-game rotation cfgs | **Conditional.** Only for ROMs whose NVRAM has service-mode TATE on (none on this cabinet's roster as of 2026-05-22). | Yes — 9 titles whose savestate captured in-game TATE on. |
| In-game TATE storage | NVRAM (`/userdata/saves/naomi/reicast/<rom>.zip.nvmem`), auto-created on first launch. | Dreamcast RAM, captured in `.state.auto`. |

Net mechanism for NAOMI: **system-wide rotation key + (conditional) per-game `video_rotation = "0"` cfgs for NVRAM-TATE-on titles.** No fill keys, no savestates, no autosave keys.

## Config paths (Batocera)

| Layer | Path |
|-------|------|
| Per-system keys | `/userdata/system/batocera.conf` (`naomi.*`) |
| Per-game rotation override | `/userdata/system/configs/retroarch/config/Flycast/<ROM_STEM>.cfg` (shared dir with Dreamcast; stems differ — NAOMI uses MAME short names like `trizeal.cfg`, Dreamcast uses display names like `Trizeal.cfg`) |
| NVRAM directory (auto-created, do NOT seed by default) | `/userdata/saves/naomi/reicast/<rom>.zip.nvmem` |
| Cartridge dump directory (auto-created, do NOT touch) | `/userdata/saves/naomi/<rom>.{A,B,C,D}1.bin` |
| Core (locked) | **`flycast`** on x86_64 (`configgen-defaults-x86_64.yml`); per-ROM cfgs are core-tied via the `Flycast/` dir name |

## Script should implement

### Step 1 — Set the one `naomi.*` key (idempotent)

```bash
batocera-settings-set naomi.retroarch.video_rotation "$ROTATION"   # default 3, operator override 1 for mirrored cabinets
```

That is the entire mandatory write. Do NOT preemptively set `naomi.ratio`, `naomi.retroarch.video_force_aspect`, or any savestate keys — none are needed for the cabinet-tested behavior, and adding speculative keys risks regressing what works.

### Step 2 — Per-game `video_rotation` cfgs for NVRAM-TATE-on titles (conditional)

For each entry in the (operator-supplied) `nvmem_tate_on` manifest:

```bash
mkdir -p /userdata/system/configs/retroarch/config/Flycast
for stem in $NVMEM_TATE_ON_STEMS; do
  printf 'video_rotation = "0"\n' > "/userdata/system/configs/retroarch/config/Flycast/${stem}.cfg"
  chmod 644 "/userdata/system/configs/retroarch/config/Flycast/${stem}.cfg"
done
chown -R root:root /userdata/system/configs/retroarch/config/Flycast
```

- **Only the rotation key.** Do NOT add `aspect_ratio_index`, `custom_viewport_*`, or other Myzar-style geometry — NAOMI does not need them.
- `chmod 644` matches every other RA cfg.
- Do NOT write per-game cfgs for the non-TATE titles. Every file in `Flycast/` should be an exception.
- The default `nvmem_tate_on` list is **empty** on a clean v43 deploy (NAOMI ROMs auto-generate NVRAM with TATE off on first launch). The list grows only if an operator imports pre-existing NVRAM files or manually enables TATE in service mode.

### Step 3 — Do NOT touch

- `naomi.videomode` — v43's CRT Script geometry handles this.
- `naomi.retroarch.crt_switch_resolution` — global already controls Switchres for the CRT Script display profile.
- `naomi.autosave` / `naomi.retroarch.savestate_auto_*` — there are no curated states to load, leave default (off).
- `Flycast/Flycast.cfg`, `Flycast/Flycast.opt`, `Flycast/naomi.cfg`, `Flycast/naomi.opt` — Myzar's per-system flycast configs (`reicast_screen_rotation = "vertical"`, `aspect_ratio_index = "24"`, `custom_viewport_width = "640"`, `custom_viewport_height = "960"`) are explicitly rejected for v43 (wrong polarity, wrong viewport, would change core render path away from cabinet-tested baseline).
- `/userdata/saves/naomi/reicast/*.nvmem` — these are auto-created by Flycast on first launch. Do NOT seed from any bundle by default; NVRAM state varies per cabinet and seeding a TATE-on NVRAM is exactly what creates the double-rotation problem this recipe avoids.
- `/userdata/saves/naomi/*.{A,B,C,D}1.bin` — cartridge bank dumps; auto-created on first launch, never touch.

### Step 4 — Subsystem filter

`--only=naomi` touches exactly:

- The one `naomi.*` key in `batocera.conf`.
- Files under `/userdata/system/configs/retroarch/config/Flycast/<naomi_rom_stem>.cfg` (and only those matching the operator manifest).

Nothing else. Critically: does NOT delete or modify any existing `Flycast/*.cfg` that match Dreamcast ROM stems — the generator must filter by NAOMI rom stem only.

### Step 5 — Optional `--clean` (dangerous)

Removes only the per-game `Flycast/<naomi_rom_stem>.cfg` files for stems in the manifest. Default: off. Must NOT remove the system-wide key, NVRAM files, or any Dreamcast cfgs.

### Step 6 — Manifest format

The script needs (a) an optional list of NAOMI ROM stems whose NVRAM is known to be TATE-on, and (b) the operator's mount polarity. Simplest form:

```yaml
# naomi-vertical.manifest.yml
rotation_system_wide: 3   # 3 = 270° CCW (this cabinet); 1 = 90° CW (mirrored)
rotation_override_value: 0   # for per-game NVMEM-TATE-on overrides

# NAOMI ROM stems whose NVRAM has service-mode TATE enabled.
# Leave empty for fresh cabinets; populate only after a launch test confirms
# double-rotation on a given title. Discovery procedure documented in the
# vanilla doc's "Per-title test procedure" section.
nvmem_tate_on: []

# Optional explicit roster (matches /userdata/roms/naomi/*.zip).
# Used only by --validate to list which ROMs the operator considers in-scope.
roster:
  - ikaruga         # cabinet-tested PASS 2026-05-22 (no override needed)
  - karous          # expected PASS, per-title launch test pending
  - psyvar2
  - radirgy
  - radirgyn
  - shikgam2
  - trgheart
  - trizeal
  - undefeat
  - illvelo
  - mamonoro
  - sl2007
```

The default manifest the autoconfig ships with should have `nvmem_tate_on: []`. The list is an operator escape hatch, not a presumption about which titles need it.

## Validation targets for script

- [ ] Dry-run shows only: the one `naomi.retroarch.video_rotation` change and (if `nvmem_tate_on` is non-empty) the listed `Flycast/<stem>.cfg` writes. No other `batocera.conf` edits, no display profile changes, no global key changes, no Dreamcast cfg touches.
- [ ] On apply:
  - `batocera-settings-get naomi.retroarch.video_rotation` → `3` (or `1` per operator polarity).
- [ ] Every entry in `nvmem_tate_on` has a matching `Flycast/<stem>.cfg` containing exactly `video_rotation = "0"` (no other keys, mode 644, root:root).
- [ ] No `Flycast/<stem>.cfg` exists for NAOMI stems NOT in `nvmem_tate_on`.
- [ ] Existing Dreamcast per-game cfgs in the same `Flycast/` dir are untouched.
- [ ] Launching `ikaruga` from NAOMI: correctly vertical, fullscreen, attract mode plays.
- [ ] (If `nvmem_tate_on` non-empty) launching one of those titles: correctly vertical via the game's internal TATE, no double-rotation.

## Risks / gotchas

- **Core lock.** Per-game cfgs are tied to `Flycast/` dir. Switching `naomi.core` away from `flycast` invalidates this recipe.
- **Rotation polarity.** `=3` and `=0` overrides assume the cabinet is mounted with the screen's bottom on the cabinet's right (270° CCW logical rotation). Mirrored cabinets need `=1` system-wide; per-game `=0` is mount-independent because it leaves NVRAM-driven rotation alone.
- **NVRAM state is per-cabinet and persistent.** Adding a per-game `=0` cfg fixes the symptom (double-rotation) but does not fix the underlying NVRAM. If the NVRAM is later deleted or replaced (auto-creates fresh, defaults to TATE off), the cfg becomes wrong and the title will render rotated only by the game's now-off internal TATE (i.e. horizontal in a portrait viewport). Generator should warn that per-game cfgs and NVRAM contents are coupled.
- **Service-mode entry is hardware-dependent.** NAOMI service-mode hotkey varies by Flycast version and cabinet input mapping. The per-game cfg path is more reliable than asking the operator to navigate the NAOMI service menu.
- **Shared `Flycast/` dir with Dreamcast.** The generator must filter writes by NAOMI ROM stem; never delete or modify a `Flycast/<stem>.cfg` that does not match the NAOMI roster. Dreamcast uses display-name stems (`Ikaruga (Japan).cfg`), NAOMI uses MAME short stems (`ikaruga.cfg`), so the chance of accidental collision is essentially zero — but a programmatic check before write is required.
- **NAOMI BIOS location is unlike everything else.** `naomi.zip` goes in `/userdata/roms/naomi/`, not `/userdata/bios/`. Generator should refuse / warn if `naomi.zip` is absent or located elsewhere.

## See also

- [dreamcast-vertical-autoconfig.md](dreamcast-vertical-autoconfig.md): same core, much more complex deploy (state-injection + decoupled autoload + 9 per-game cfgs + fill keys).
- [saturn-vertical-autoconfig.md](saturn-vertical-autoconfig.md): state-injection without rotation cfgs (different core).
- [psx-vertical-autoconfig.md](psx-vertical-autoconfig.md): one step up the complexity ladder — NAOMI needs only the rotation key; PSX adds fill keys + per-game custom viewport for Cave-family side-panel titles + (optional) bundled memory cards. Still no state-injection.
- [snes-vertical-autoconfig.md](snes-vertical-autoconfig.md), [pcengine-vertical-autoconfig.md](pcengine-vertical-autoconfig.md), [vectrex-vertical-autoconfig.md](vectrex-vertical-autoconfig.md): geometry-class specs (different mechanism — videomode + ratio).
- [naomi-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/naomi-vertical-vanilla-v43.md): cabinet-tested deployment with full per-title status table, NVRAM behavior notes, gotchas.
