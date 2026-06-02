# Nintendo Switch (Citron AppImage) — autoconfig spec (vanilla vertical)

## Canonical prior art

Cabinet-tested deployment (3-title Cave roster, 2026-05-24 on v43 `10.23.6.210`):
[switch-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/switch-vertical-vanilla-v43.md)

## Reading this from a fresh install

The generator runs on a cabinet that already has:

- Vanilla Batocera v43 + CRT Script vertical install (`display.rotate=1`, correct CRT geometry + super-res ladder).
- **Unofficial Switch add-on** installed (`citron-emu.AppImage`, `edenGenerator.py`).
- Switch **keys + firmware** in `/userdata/bios/switch/`.
- ROMs in `/userdata/roms/switch/` (`.nsp` / `.xci`).

It must not touch the display profile, global rotation, videomodes catalog, or any other system. It writes **seven `switch.*` system-wide keys** only. **No bundled save data** by default (operator performs the in-game TATE ritual once per title).

## How this differs from prior autoconfigs

Switch is the **seventh recipe class**: **standalone Citron AppImage + system keys + in-game TATE save persistence**.

| Concern | Switch (this spec) | PSX (Cave) | PS2 | PSP |
|---------|-------------------|------------|-----|-----|
| Emulator | **citron-emu AppImage** | libretro `pcsx_rearmed` | standalone PCSX2-Qt | libretro `ppsspp` |
| Config layer | `switch.*` → `yuzu/qt-config.ini` via `edenGenerator.py` | RA `.cfg` + memory card | `ps2.*` → PCSX2.ini + CLI | RA `.cfg` + `.state.auto` |
| In-game TATE | **Options menu → save data** | Options → `.1.mcr` | memory card + optional `.p2s` | in-game + state tier |
| Per-game batocera keys | **none** (this roster) | viewport cfg for 2 titles | `state_filename` per title | viewport + remap tiers |
| Skip-menu autoload | **none** | n/a | `-statefile` bootstrap | `.state.auto` |
| RetroArch | **not used** | used | not used | used |

Net mechanism: **seven system-wide keys + operator TATE ritual × N titles**.

## Config paths (Batocera v43 + unofficial add-on)

| Layer | Path |
|-------|------|
| Per-system keys | `/userdata/system/batocera.conf` (`switch.*`) |
| Citron/qt config (regenerated at launch) | `/userdata/system/configs/yuzu/qt-config.ini` |
| Keys (symlinked into yuzu/citron) | `/userdata/bios/switch/keys/` |
| Firmware (symlinked into nand) | `/userdata/bios/switch/firmware/` |
| In-game TATE persistence | `/userdata/system/configs/yuzu/sdmc/` (virtual SD) |
| Emulator binary (locked) | `/userdata/system/switch/appimages/citron-emu.AppImage` |
| Configgen source | `/userdata/system/switch/configgen/generators/edenGenerator.py` |

## Script should implement

### Step 1 — Preflight

```bash
# Fail fast if add-on or keys missing
test -x /userdata/system/switch/appimages/citron-emu.AppImage || exit 1
test -f /userdata/bios/switch/keys/prod.keys || exit 1
test -f /userdata/system/switch/configgen/generators/edenGenerator.py || exit 1
```

### Step 2 — Set the seven `switch.*` system-wide keys (idempotent)

```bash
batocera-settings-set switch.emulator               citron-emu
batocera-settings-set switch.core                   citron-emu
batocera-settings-set switch.videomode              "$SWITCH_VIDEOMODE"   # default 864x486.60.00070 on reference cab
batocera-settings-set switch.yuzu_backend           1
batocera-settings-set switch.yuzu_ratio             5                     # stretch to window
batocera-settings-set switch.language               1
batocera-settings-set switch.citron_resolution_scale 2                    # 1x native
```

Optional: `batocera-settings-set switch.bezel none` if the CRT Script left bezels enabled.

Resolve `$SWITCH_VIDEOMODE` from `batocera-resolution listModes | grep '^864x486'` on the target cabinet; fall back to operator override in manifest.

### Step 3 — Operator TATE ritual (NOT automatable)

Print once per title in manifest:

```
Launch <title> → Options → General Screen → Rotate → Right Roll → Link Rotation ON → exit cleanly.
Repeat for each roster title. Save data lands under /userdata/system/configs/yuzu/sdmc/.
```

The generator **must not** claim zero-touch launch until operator confirms TATE saved for each title.

### Step 4 — Optional bundled save data (default: no)

```yaml
bundle_sdmc_saves: no   # default
```

If `yes`, tarball only the three title-specific save subtrees from a **known-good operator capture** on the same Citron build. Saves are emulator-version-sensitive; default off.

## Do NOT touch

- `switch.emulator=citron` (stock broken default)
- Eden / Ryujinx emulator keys for real ROMs
- RetroArch / `ratio` / `video_rotation` keys (Switch is not libretro here)
- Myzar-only `suyu_ratio` key name (v43 add-on uses `yuzu_ratio`)
- Operator-created `yuzu/sdmc` save data (unless `bundle_sdmc_saves: yes` and operator approves overwrite)

## Subsystem filter

Only run when deploying Switch vertical presets (`--system switch` or manifest includes `switch`).

## YAML manifest schema (optional)

```yaml
system: switch
videomode: 864x486.60.00070
yuzu_ratio: 5
citron_resolution_scale: 2
roster:
  - DoDonPachi Resurrection.nsp
  - Espgaluda 2 -Be Ascension The Third Bright Stone of Birth.xci
  - Mushihimesama.nsp
bundle_sdmc_saves: no
operator_tate_note: "Options → General Screen → Rotate → Right Roll; Link Rotation ON"
```

## Validation targets

After apply + operator TATE ritual:

1. `grep '^switch.emulator=citron-emu' /userdata/system/batocera.conf`
2. Each roster ROM launches Citron without key/firmware error
3. In-game TATE fills portrait CRT (no large letterbox bars)
4. Second launch skips TATE menu (save persisted under `yuzu/sdmc`)
5. ES menu rotation unchanged after quit

## Risks

- **Add-on dependency:** Recipe is invalid without unofficial Switch pack; stock v43 alone is insufficient.
- **Save data versioning:** Bundled sdmc from another Citron build may fail silently; prefer operator ritual.
- **`yuzu_ratio` value map:** Must use add-on semantics (`5` = stretch), not stock `citron.emulator.yml` labels without verifying `edenGenerator.py` mapping.
- **Videomode token suffix:** CRT Script catalog uses full tokens (e.g. `.00070`); short Myzar tokens may not resolve on v43.

## Sources

- [switch-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/switch-vertical-vanilla-v43.md)
- Myzar reference investigation (`10.23.6.214`)
