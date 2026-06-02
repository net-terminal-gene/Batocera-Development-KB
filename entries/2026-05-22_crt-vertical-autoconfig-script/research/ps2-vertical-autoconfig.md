# Sony PlayStation 2 (PS2, standalone PCSX2-Qt) — autoconfig spec (vanilla vertical)

## Canonical prior art

Cabinet-tested deployment (12 of 13 vertical-shmup roster titles wired and validated 2026-05-24; 1 dropped in favor of Dreamcast version):
[ps2-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/ps2-vertical-vanilla-v43.md)

## Reading this from a fresh install

The generator runs on a cabinet that already has:

- Vanilla Batocera v43 + CRT Script vertical install (`display.rotate=1`, correct CRT geometry + super-res ladder).
- PS2 disc images in `/userdata/roms/ps2/` (`.chd` preferred; `.iso` / `.cso` / `.bin+cue` also supported).
- **PS2 BIOS** in `/userdata/bios/ps2/` (at least one of `SCPH30004R.bin` / `SCPH70012.bin` / `SCPH77000.bin`). Generator must warn if no BIOS file present.
- Default emulator unchanged (standalone `pcsx2` in `configgen-defaults-x86_64.yml`).

It must not touch the display profile, global rotation, videomodes, or any other system. **As of 2026-05-24 it writes nine `ps2.*` system-wide keys**, **two `ps2["<ROM>"].*` per-game keys per title**, and optionally seeds **one `.01.p2s` + `.png` bootstrap pair per title** (chmod 444) so the operator skips the manual F1 step.

## How this differs from every prior autoconfig

PS2 is the first **standalone-emulator** autoconfig in this project. All prior recipes (Saturn, Dreamcast, NAOMI, PSX, SNES, PCE, Vectrex, FBNeo, Neo Geo) target libretro cores via RetroArch `.cfg` files. PS2 uses standalone PCSX2-Qt which has no `.cfg` file mechanism — every per-game and per-system setting flows through `batocera.conf` (`ps2.*` keys) and gets materialized into `PCSX2.ini` + pcsx2-qt CLI args by `pcsx2Generator.py`.

| Concern | PS2 (this spec) | PSX | Dreamcast | Saturn |
|---------|-----------------|-----|-----------|--------|
| Emulator | **standalone PCSX2-Qt** | libretro `pcsx_rearmed` | libretro `flycast` | libretro `mednafen_saturn` (or `kronos`) |
| Per-game settings mechanism | **`ps2["<ROM>"].*` keys in batocera.conf** → configgen translates to pcsx2-qt CLI args | `.cfg` file under `PCSX-ReARMed/` | `.cfg` file under `Flycast/` | `.state.auto` file + RA `savestate_auto_*` |
| Auto-launch trigger | **`-statefile <path>` CLI arg** (set via `state_filename` per-game key) | n/a (no skippable splash) | RA `savestate_auto_load=true` reads `.state.auto` | RA `savestate_auto_load=true` reads `.state.auto` |
| Bootstrap save format | **`.p2s` file** (PCSX2 native) | n/a | `.state.auto` (libretro) | `.state.auto` (libretro) |
| Overwrite protection | **`chmod 444` on `.p2s` file** | n/a | `<system>.autosave=0` + RA `savestate_auto_save=false` | same as Dreamcast |
| Per-game cfg dir | none (no RA cfg files) | `PCSX-ReARMed/` | `Flycast/` (shared with NAOMI) | `Beetle Saturn/` |
| Assets bundled by autoconfig | 9 system-wide keys + 2 per-game keys + (optional) `.01.p2s`+`.png` per title | 3 system-wide keys + per-game cfgs + (optional) `.1.mcr` | 6 system-wide keys + 9 per-game cfgs + 36 state files | 3 system-wide keys + 38 state files |
| Cabinet validation | 12 titles 2026-05-24 | 10 titles 2026-05-23 | 18 titles | 6 titles |

Net mechanism for PS2: **9 system-wide keys + (per-game keys + locked bootstrap save state) × N**.

## Config paths (Batocera v43)

| Layer | Path |
|-------|------|
| Per-system keys | `/userdata/system/batocera.conf` (`ps2.*`) |
| Per-game keys | `/userdata/system/batocera.conf` (`ps2["<ROM>"].*`) |
| PS2 memory cards (in-game TATE persistence) | `/userdata/saves/ps2/pcsx2/Mcd001.ps2`, `Mcd002.ps2` |
| Bootstrap save states (auto-loaded on launch) | `/userdata/saves/ps2/pcsx2/sstates/<ROM>.01.p2s` + `.png` |
| Auto-save-on-exit files (suppressed by this recipe) | `/userdata/saves/ps2/pcsx2/sstates/<ROM>.p2s.auto` |
| PCSX2-Qt main config (regenerated every launch by configgen) | `/userdata/system/configs/PCSX2/inis/PCSX2.ini` |
| Configgen source (for forward maintenance) | `/usr/lib/python3.12/site-packages/configgen/generators/pcsx2/pcsx2Generator.py` |
| Emulator (locked) | **standalone `pcsx2`** on x86_64 (`configgen-defaults-x86_64.yml`); libretro `pcsx2_libretro.so` is broken on v43 BC250 (AVX-512 SIGILL) |

## Script should implement

### Step 1 — Set the nine `ps2.*` system-wide keys (idempotent)

```bash
batocera-settings-set ps2.emulator                  pcsx2
batocera-settings-set ps2.autosave                  0
batocera-settings-set ps2.incrementalsavestates     0
batocera-settings-set ps2.pcsx2_bilinear_filtering  0
batocera-settings-set ps2.pcsx2_blur                true
batocera-settings-set ps2.pcsx2_gfxbackend          "$RENDERER"   # default 14 (Vulkan); 13 = Software fallback if Vulkan absent
batocera-settings-set ps2.pcsx2_vsync               1
batocera-settings-set ps2.pcsx2_resolution          1
batocera-settings-set ps2.pcsx2_texture_filtering   2
```

That is the entire mandatory system-wide write. Do NOT preemptively set `ps2.pcsx2_fastboot` (cosmetic / broken — see "Known configgen bug" below), `ps2.ratio`, `ps2.videomode`, or any other keys — the cabinet-tested baseline doesn't need them and divergence would introduce per-title surprises.

### Step 2 — Per-game bootstrap wiring (conditional, per title in manifest)

For each entry in the (operator-supplied) `roster` manifest where a `.01.p2s` bootstrap file exists:

```bash
mkdir -p /userdata/saves/ps2/pcsx2/sstates
for ROM in $ROSTER_STEMS_WITH_EXT; do
  SS="/userdata/saves/ps2/pcsx2/sstates/${ROM}.01.p2s"
  PNG="${SS}.png"

  # Only wire if the bootstrap file actually exists.
  # The operator must capture the F1 save via gameplay first;
  # this script does NOT and CANNOT generate the .p2s file.
  if [ ! -f "$SS" ]; then
    echo "WARN: no bootstrap for $ROM (operator F1 step incomplete); skipping" >&2
    continue
  fi

  batocera-settings-set "ps2[\"${ROM}\"].state_filename" "$SS"
  batocera-settings-set "ps2[\"${ROM}\"].state_slot"     1

  chmod 444 "$SS"
  [ -f "$PNG" ] && chmod 444 "$PNG"
done
```

- **`ROM` includes the extension** (`.chd`, `.iso`, etc.). `batocera.conf` per-game key syntax uses the full ROM filename, not the stem.
- **The bootstrap file must pre-exist.** This recipe is fundamentally operator-driven for the gameplay step. The script can verify, wire, and lock — but cannot produce the bootstrap save itself. For redistributable autoconfig, see Step 4 (bundle).
- **`chmod 444` is non-negotiable.** Skipping the chmod allows accidental in-game F1 to overwrite the bootstrap, which silently breaks the recipe (next launch boots into a mid-stage save instead of the operator's intended spot).
- **Re-running is idempotent** for already-locked files (chmod 444 on an already-444 file is a no-op; batocera-settings-set with the same value is a no-op).

### Step 3 — Suppress any leftover auto-save artifacts

The cabinet may have `.p2s.auto` files from operator-confused testing. The recipe requires `ps2.autosave=0` (Step 1) which prevents future creation, but leftover files need cleanup:

```bash
for f in /userdata/saves/ps2/pcsx2/sstates/*.p2s.auto \
         /userdata/saves/ps2/pcsx2/sstates/*.p2s.auto.png \
         /userdata/saves/ps2/pcsx2/sstates/*.p2s.auto.tmp; do
  [ -f "$f" ] && rm -f "$f"
done
```

PCSX2-Qt prefers `.p2s.auto` over `.01.p2s` when both exist; leftover `.auto` files silently shadow the operator's bootstrap.

### Step 4 — (Optional) bundle bootstrap save states as static assets

The bootstrap `.01.p2s` files are operator-captured and cabinet-specific (depend on cabinet's BIOS region + game version + player skill at the launch spot). For a redistributable autoconfig targeting cabinets with identical hardware + BIOS + ROMs, the bundle MAY include pre-captured bootstraps:

```bash
if [ "$BUNDLE_BOOTSTRAPS" = "yes" ]; then
  mkdir -p /userdata/saves/ps2/pcsx2/sstates
  for ROM in $ROSTER_STEMS_WITH_EXT; do
    src="$BUNDLE_DIR/ps2/${ROM}.01.p2s"
    dst="/userdata/saves/ps2/pcsx2/sstates/${ROM}.01.p2s"
    if [ -f "$src" ] && [ ! -f "$dst" ]; then
      cp "$src" "$dst"
      cp "${src}.png" "${dst}.png" 2>/dev/null || true
      chmod 444 "$dst" "${dst}.png" 2>/dev/null || true
    fi
  done
fi
```

- **Skip-if-exists.** Never overwrite an operator's existing bootstrap — they may have captured a better launch spot.
- **Cabinet-bound.** A `.01.p2s` captured on Cabinet A may not load on Cabinet B if the BIOS differs (e.g. European vs USA) — PCSX2 embeds BIOS version into the save state header. The bundle docs should specify which BIOS the captures were taken with.
- **Bundle size.** Each `.01.p2s` is ~10–15 MB, each `.png` is ~300 KB. 12-title bundle ≈ 150 MB. Non-trivial — consider this for distribution channel choice.
- **Default: `BUNDLE_BOOTSTRAPS=no`.** Bootstraps are skill-dependent (the "launch spot" varies per operator preference), and the F1 ritual is a 2-minute operator action per title. Bundling is opt-in for cabinets that want full hands-off deploy.

### Step 5 — Do NOT touch

- `ps2.videomode` — v43's CRT Script geometry handles this. Switchres validated 2026-05-24 (launch log shows `setMode 641x480.60.00082` for every PS2 game with no extra config).
- `ps2.retroarch.*` — irrelevant: PS2 uses standalone PCSX2-Qt, not RetroArch. Configgen ignores `ps2.retroarch.*` for standalone-routed systems.
- `ps2.core` — selects libretro PS2 core, which is broken on v43 BC250. Generator should NOT set this; if operator has set it manually, the recipe falls back to libretro and breaks.
- `ps2.pcsx2_fastboot` — broken upstream (inverted return_values in pcsx2Generator.py line 273). Setting `true` writes `EnableFastBoot=false`. Cosmetic regardless because `state_filename` makes BIOS animation invisible. Generator may set `true` for forward-compatibility (in case it gets fixed upstream) but must not depend on it for functionality.
- `ps2.pcsx2_ratio` — leave at configgen default (`Auto 4:3/3:2`). Per-game `Stretch` overrides were tested and rejected by operator (distorts non-Cave titles; small bars on Cave titles judged acceptable).
- Existing operator memory cards (`Mcd001.ps2`, `Mcd002.ps2`) — never overwrite. The in-game TATE persistence layer is fully operator-owned.
- Existing operator bootstraps (`.01.p2s`) — never overwrite. The chmod 444 is the protection mechanism; this script applies it but never replaces a pre-existing file.
- `/userdata/system/configs/PCSX2/inis/PCSX2.ini` — regenerated by configgen on every launch. Manual edits are blown away. Set values via `ps2.*` keys instead.

### Step 6 — Subsystem filter

`--only=ps2` touches exactly:

- The nine `ps2.*` system-wide keys in `batocera.conf`.
- Two `ps2["<ROM>"].*` keys per title in `batocera.conf` (only for titles where the `.01.p2s` bootstrap exists).
- `chmod 444` on existing `<ROM>.01.p2s` + `.png` files (only those listed in the manifest).
- Cleanup of any `.p2s.auto` / `.p2s.auto.png` / `.p2s.auto.tmp` files in `sstates/`.
- (If `BUNDLE_BOOTSTRAPS=yes`) seed `.01.p2s` + `.png` from bundle for titles with no pre-existing bootstrap.

Nothing else. Critically: does NOT delete or modify any existing memory card, RAM dump, other-system config, or PCSX2 input/controller profile.

### Step 7 — Optional `--clean` (dangerous)

Removes only:

- The two `ps2["<ROM>"].*` per-game keys per title (system-wide keys are kept — they're harmless without per-game keys, and removing them would change behavior on next operator add).
- `chmod 644` on the bootstrap files (revert lock so operator can replace).

Must NOT remove the bootstrap `.01.p2s` files themselves (operator's gameplay capture), memory cards, or any other PS2 file.

### Step 8 — Manifest format

```yaml
# ps2-vertical.manifest.yml
renderer: 14                     # 14 = Vulkan (recommended); 13 = Software (fallback)
bundle_bootstraps: no            # yes = ship .01.p2s + .png in the bundle (~150 MB for 12-title roster)

# Operator-captured bootstrap saves required for these titles.
# The generator will wire + lock IF a matching .01.p2s exists in sstates/;
# otherwise it warns and skips.
roster:
  - Shikigami no Shiro II.chd                    # cabinet-tested PASS 2026-05-24
  - Dodonpachi Dai-Ou-Jou.chd                    # cabinet-tested PASS 2026-05-24 (small portrait bars acceptable)
  - Espgaluda (Japan).chd                        # cabinet-tested PASS 2026-05-24 (soft port; source limitation)
  - Gunbird Special Edition.chd                  # cabinet-tested PASS 2026-05-24
  - Homura (Europe).chd                          # cabinet-tested PASS 2026-05-24
  - Ibara.chd                                    # cabinet-tested PASS 2026-05-24
  - Mushihime-sama (Japan).chd                   # cabinet-tested PASS 2026-05-24
  - Psyvariar 2 - Ultimate Final.chd             # cabinet-tested PASS 2026-05-24
  - Raiden III (Europe).chd                      # cabinet-tested PASS 2026-05-24
  - Shikigami no Shiro.chd                       # cabinet-tested PASS 2026-05-24
  - Shooting Love - Trizeal (Japan).chd          # cabinet-tested PASS 2026-05-24
  - XII Stag.chd                                 # cabinet-tested PASS 2026-05-24

# Titles to explicitly skip (with reason). Generator must NOT wire these
# even if the operator has a .01.p2s present.
skip:
  - rom: Triggerheart Exelica enhanced.chd
    reason: "BIOS memory-card-create prompt loops on European SCPH30004R. SLPM-55052 Japan-only Enhanced edition. Use Dreamcast version (Triggerheart Exelica (Japan).cdi) via Flycast instead."

# Optional: PS2 BIOS region preference (informational; generator does not install BIOS).
bios_preference:
  - SCPH30004R.bin    # European, cabinet-tested
  - SCPH77000.bin     # Japanese (may resolve Japanese-locked titles like Triggerheart Enhanced; untested)
  - SCPH70012.bin     # USA
```

The default manifest ships with the 12 cabinet-tested titles. Operators with different rosters extend the list; the generator's `--validate` mode should list each manifest entry and report whether the matching `.01.p2s` exists.

## Validation targets for script

- [ ] Dry-run shows only: the nine `ps2.*` system-wide key changes, the per-title `ps2["<ROM>"].state_filename` + `state_slot` writes, and `chmod 444` operations on listed `.01.p2s` + `.png` files. No display profile changes, no global key changes, no other-system configs touched.
- [ ] On apply:
  - `batocera-settings-get ps2.emulator` → `pcsx2`.
  - `batocera-settings-get ps2.autosave` → `0`.
  - `batocera-settings-get ps2.incrementalsavestates` → `0`.
  - `batocera-settings-get ps2.pcsx2_bilinear_filtering` → `0`.
  - `batocera-settings-get ps2.pcsx2_blur` → `true`.
  - `batocera-settings-get ps2.pcsx2_gfxbackend` → `14` (or `13` per operator).
  - `batocera-settings-get ps2.pcsx2_vsync` → `1`.
  - `batocera-settings-get ps2.pcsx2_resolution` → `1`.
  - `batocera-settings-get ps2.pcsx2_texture_filtering` → `2`.
- [ ] Every entry in `roster` with an existing bootstrap has matching `state_filename` + `state_slot` keys.
- [ ] Every wired bootstrap has perms `-r--r--r--` (file) and matching `.png` (same perms).
- [ ] No `.p2s.auto` files exist in `sstates/`.
- [ ] No bootstrap files were overwritten or deleted.
- [ ] No memory cards were overwritten or deleted.
- [ ] Existing operator non-roster bootstraps (e.g. a `.07.p2s` from a different workflow) are untouched.
- [ ] Launching one wired title (e.g. **Castle Shikigami II**) → cabinet boots directly into TATE gameplay at the operator's saved spot, no menus, no BIOS animation.
- [ ] Quit, relaunch the same title → mtime on its `.01.p2s` unchanged (lock holding), launch identical.

## Known configgen bug

`pcsx2Generator.py` line 273:

```python
pcsx2INIConfig.set("EmuCore", "EnableFastBoot",
    system.config.get_bool('pcsx2_fastboot', True,
        return_values=("false", "true")))
```

The `return_values=("false", "true")` is inverted relative to other configgen uses. For all other bool keys, the convention is `(when_true, when_false)`. This means setting `ps2.pcsx2_fastboot=true` writes `EnableFastBoot = false`. Effect: BIOS animation always plays on cold boot, never skipped via this key.

**For this recipe the bug is cosmetic** because `-statefile <path>` loads the operator's bootstrap before frame 1, suppressing the BIOS animation regardless of EnableFastBoot. Generator should set `pcsx2_fastboot=true` for forward-compatibility (in case the bug is fixed upstream) but the recipe must not depend on EnableFastBoot working.

If the recipe is ever applied to a use case WITHOUT bootstrap save states (e.g. an arcade-style hosted PS2 game where the operator wants BIOS skipped but no save state), the bug would matter and a workaround is needed: either patch the generator, or set the value through PCSX2's GUI before its first managed launch and hope configgen doesn't overwrite it (it does).

## Risks / gotchas

- **Standalone-emulator lock.** The entire recipe is built on standalone PCSX2-Qt's `-statefile` / `-stateindex` CLI args. The libretro `pcsx2` core has no equivalent (libretro uses `savestate_auto_load` + `.state.auto`, fundamentally different). Switching `ps2.emulator` or `ps2.core` to libretro invalidates every per-game `state_filename` key — but libretro PS2 is broken on v43 BC250 anyway, so the only failure mode is the operator picking libretro deliberately on different hardware. Generator should warn if both `ps2.emulator=pcsx2` and `ps2.core=pcsx2` (libretro) are set — they're mutually exclusive.
- **Bootstrap captures embed BIOS version.** A `.01.p2s` taken with European SCPH30004R may not load with Japanese SCPH77000 (PCSX2 stores BIOS version in the save state header and fails the load with "BIOS version mismatch"). If bundling bootstraps for distribution, the bundle metadata MUST specify the BIOS version used during capture.
- **Region-locked Japanese titles may loop at memory card create prompts on non-Japanese BIOS.** Cabinet-confirmed: Triggerheart Exelica Enhanced (SLPM-55052) loops on European SCPH30004R. Untested: would a Japanese BIOS (SCPH77000) resolve? Generator should NOT auto-recommend BIOS swaps (BIOS distribution is legally fraught) but the manifest's `skip:` section lets operators tag known-broken titles with a reason.
- **EmulationStation per-system PS2 menu rewrites `ps2.*` block.** When the operator opens Per System Settings → PlayStation 2 in ES and changes any value, ES re-emits the whole `ps2.*` system-wide block based on its UI state, dropping any key not exposed in the UI. Specifically observed during recipe development: `ps2.pcsx2_fastboot=true` was removed when operator toggled an unrelated PS2 setting. Generator's `--validate` should detect missing keys and offer to re-apply.
- **`pcsx2_blur` semantics are inverted relative to ES label.** The ES UI may label this as "Anti-blur" or "Deblur" — `pcsx2_blur=true` in batocera.conf means `pcrtc_antiblur=true` in PCSX2.ini, i.e. anti-blur IS ENABLED, i.e. image is SHARPER. Operators who toggle "Anti-blur" off in ES (thinking they want less blur) get the opposite of what they want. Generator should NOT touch per-game `pcsx2_blur` keys; if found, log them so operator can audit.
- **Higher internal resolution causes artifacts on Cave 2D ports.** Tested on Espgaluda + DoDonPachi at 2x and 3x — sprite-edge artifacts, font shimmer. The recipe locks `pcsx2_resolution=1`. Operators with non-Cave-heavy rosters could try 2x but should expect to revert for any Cave / Triangle Service / Psikyo classic-shmup port.
- **Software renderer is no better than Vulkan for Cave 2D on this hardware.** Tested 2026-05-24: switched `pcsx2_gfxbackend` to 13 (Software) on Espgaluda — no visible sharpness difference, slightly slower. Recipe locks 14 (Vulkan). Recommendation only changes for cabinets where Vulkan is unavailable (e.g. pre-Vulkan AMD GPU).
- **PCSX2.ini regeneration timing.** Configgen rewrites `PCSX2.ini` at the START of every PS2 game launch. Settings changed via ES Per System menu apply on the NEXT launch, not retroactively. The validation step in this autoconfig should trigger a dummy launch (or just `pcsx2-qt --help` if it touches the ini) to force regeneration.
- **`state_filename` value must use the full Linux path.** No `$HOME`, no `~`, no relative paths. Configgen does not expand. Generator should validate the manifest entries produce absolute paths starting with `/userdata/saves/ps2/pcsx2/sstates/`.
- **F1 in-game during a launched bootstrap session writes a `.p2s.auto` file** (despite `autosave=0` in PCSX2.ini — `EnableFastBoot=0` is the only autosave control, and F1 is a manual save not subject to that). With `chmod 444` on `.01.p2s`, an F1 press lands on slot 0 (`.00.p2s`) by default. Cleanup of stray `.00.p2s` / other-slot files is operator responsibility; generator should NOT auto-delete (operator may have intentionally saved progress to a non-bootstrap slot).
- **Bundle provenance.** Bootstrap `.01.p2s` files captured on a specific cabinet contain that cabinet's player progress, controller state at capture, possibly screensaver/timestamp metadata. If the bundle is publicly distributed, the generator's docs should make this explicit and recommend "clean" captures (fresh memory card, only TATE flipped, F1 at first gameplay frame).

## See also

- [dreamcast-vertical-autoconfig.md](dreamcast-vertical-autoconfig.md): state-injection class on libretro Flycast — `.state.auto` files instead of `.p2s`, RA `savestate_auto_load` instead of `-statefile`.
- [saturn-vertical-autoconfig.md](saturn-vertical-autoconfig.md): same state-injection class on libretro Mednafen — earliest precedent in this project for "operator captures save state, generator wires auto-load".
- [psx-vertical-autoconfig.md](psx-vertical-autoconfig.md): different persistence model — PSX in-game TATE writes to memory card directly, no savestate needed.
- [naomi-vertical-autoconfig.md](naomi-vertical-autoconfig.md): simplest recipe (one rotation key, no per-game).
- [ps2-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/ps2-vertical-vanilla-v43.md): cabinet-tested deployment with full per-title status table, BIOS region notes, in-game TATE procedure, configgen bug details, gotchas.
