# PC Engine / PC Engine CD - autoconfig spec (vanilla vertical)

## Canonical prior art

Full roster notes + deployed **`batocera.conf`** block (global `256x224.60.00004`, `ratio=core`):  
[pcengine-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/pcengine-vertical-vanilla-v43.md)

## Script should implement

1. **Merge or append** (idempotent) under `/userdata/system/batocera.conf`:

   ```ini
   pcengine.videomode=<from listModes 256x224.*>
   pcenginecd.videomode=<same string>
   pcengine.ratio=core
   pcenginecd.ratio=core
   ```

   Resolve `<...>` at runtime from `batocera-resolution listModes | grep 256x224` (first match or configurable).

2. **Do not** emit per-ROM `pcengine["*.zip"].videomode=` unless the manifest marks an exception (optional hi-res / horizontal titles).

3. **RetroArch optional layer:** create or update `Beetle PCE Fast/*.cfg` only when manifest requests integer scale / aspect tweaks; default can be “no per-title files”.

4. **Core folder name:** `Beetle PCE Fast` (matches `corename` in `pce_fast_libretro.info` on Batocera).

## See also

- [vectrex-vertical-autoconfig.md](vectrex-vertical-autoconfig.md) (same generator family; **`vectrex.*`** keys only).
- [snes-vertical-autoconfig.md](snes-vertical-autoconfig.md) (same family; **SNES** uses a **taller `videomode`** than PCE on the tested vertical cab; do not reuse PCE’s **`256x224`** string for SNES).
- [saturn-vertical-autoconfig.md](saturn-vertical-autoconfig.md), [dreamcast-vertical-autoconfig.md](dreamcast-vertical-autoconfig.md), [naomi-vertical-autoconfig.md](naomi-vertical-autoconfig.md), [psx-vertical-autoconfig.md](psx-vertical-autoconfig.md): non-geometry-class specs (state-injection / rotation-only / rotation + fill + custom viewport).

## Out of scope for v1

- Mid-session resolution switch when user toggles PCE “Arcade mode” in-game (would need gameStop hooks or user education only).
