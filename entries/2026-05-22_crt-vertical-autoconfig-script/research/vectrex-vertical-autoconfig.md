# Vectrex (vecx) — autoconfig spec (vanilla vertical)

## Canonical prior art

Cabinet-validated **`batocera.conf`** block (timing, **`ratio=full`**, RetroArch overrides for sync + rotation), roster, and QA notes:  
[vectrex-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/vectrex-vertical-vanilla-v43.md)

## Config paths (Batocera)

| Layer | Path |
|-------|------|
| System keys | `/userdata/system/batocera.conf` prefix **`vectrex.`** only |
| RetroArch per-system append (Batocera generator) | `/userdata/system/configs/retroarch/config/vectrex.cfg` |
| RetroArch per-content append | `/userdata/system/configs/retroarch/config/vectrex/<ROM display name>.cfg` (e.g. `Mine Storm.zip.cfg`) |

**Core id:** `vecx` (libretro `.so` = `vecx_libretro.so`). **EmulationStation system id:** `vectrex` (lowercase). The autoconfig script must **not** write under `config/vecx/` unless you intentionally bypass Batocera’s append rules; default vertical preset is **`vectrex.*` keys in `batocera.conf`** plus optional **`vectrex/`** drop-ins from a manifest only.

## Script should implement

1. **Merge or append** (idempotent) under `/userdata/system/batocera.conf` for **`vectrex`** only:

   ```ini
   vectrex.videomode=<from listModes 384x480.*>
   vectrex.ratio=full
   vectrex.retroarch.crt_switch_resolution = 0
   vectrex.retroarch.video_rotation = <3|1>
   ```

   - **`<from listModes 384x480.*>`:** resolve at runtime, e.g. `DISPLAY=:0 batocera-resolution listModes | grep 384x480 | head -1` and take the **first colon-delimited token** (same pattern as PCE script uses for `256x224.*`). If no match, fall back to **`384x512.*`** then **`320x512.*`** (see vanilla doc alternates).
   - **`crt_switch_resolution = 0`:** **required** when global `global.retroarch.crt_switch_resolution` is non-zero, so vecx does not fight fixed `vectrex.videomode` (rolling / unstable CRT).
   - **`video_rotation`:** default **`3`** when installer records **`display.rotate=1`** (matches `libretroConfig.py` mapping for TATE). If manifest or env says upside-down on hardware, emit **`1`** instead. Do **not** infer from Myzar docs; vanilla path only.

2. **`vectrex.ratio`:** default **`full`** (validated on cabinet for “fills the screen” with portrait vecx + rotation). Script option **`core`** or **`9/16`** for users who want less stretch (see vanilla doc).

3. **Per-ROM `vectrex["*.zip"].*`:** **omit in v1** unless manifest marks an exception (none known on the 28-title test roster).

4. **RetroArch optional layer:** create **`vectrex/<ROM>.cfg`** only when manifest requests overrides (e.g. per-title `aspect_ratio_index`, `video_scale_integer`). Default = **no** per-title files; all behavior from **`vectrex.*`** + globals.

5. **Idempotency:** second run produces **no** duplicate keys; same values = no-op. Use keyed merge (awk/sed with anchors) or parse-and-rewrite only the **`vectrex.`** / **`vectrex.retroarch.*`** lines the script owns.

6. **Subsystem filter:** when script supports `--only=vectrex`, it must **not** touch `pcengine*`, `fbneo*`, `neogeo*`, `mame*`, or any **`global.*`** key except where a future shared “CRT helper” is explicitly documented.

## Manifest format (optional, v1 default empty)

Same contract as FBNeo file: **TSV or JSON** row = optional per-ROM override. Columns (suggested):

| Column | Meaning |
|--------|---------|
| `rom_basename` | e.g. `Mine Storm.zip` (must match ES game settings name rules) |
| `videomode` | optional override mode string from `listModes` |
| `ratio` | optional `core` / `full` / `9/16` |
| `video_rotation` | optional `0`–`3` |

Empty manifest: **no** `vectrex/*.cfg` writes; only **`batocera.conf`** merge above.

## Validation targets for script

- [ ] Dry-run prints exact four (or five) **`vectrex.*`** lines without touching other systems.
- [ ] Apply on test Batocera: Vectrex fills panel, **no** sync roll with global CRT SwitchRes on.
- [ ] `grep '^vectrex' /userdata/system/batocera.conf` before/after: only expected delta.
- [ ] Re-run is idempotent.
- [ ] `export DISPLAY=:0; batocera-es-swissknife --restart` documented as required after apply (or script invokes when safe).

## Out of scope for v1

- vecx **hardware render** / bloom / line width defaults (remain user Quick Menu or `retroarch-core-options.cfg`).
- Batocera **`data/special/vectrex.csv`**: decoration IDs for bezels/shaders only, **not** rotation; script does not edit that CSV.

## See also

- [pcengine-vertical-autoconfig.md](pcengine-vertical-autoconfig.md) (same merge style for **`pcengine*`** keys).
- [fbneo-vertical-autoconfig.md](fbneo-vertical-autoconfig.md) (FBNeo + Neo Geo manifest pattern).
- [saturn-vertical-autoconfig.md](saturn-vertical-autoconfig.md), [dreamcast-vertical-autoconfig.md](dreamcast-vertical-autoconfig.md), [naomi-vertical-autoconfig.md](naomi-vertical-autoconfig.md), [psx-vertical-autoconfig.md](psx-vertical-autoconfig.md): non-geometry-class specs (state-injection / rotation-only / rotation + fill + custom viewport).
