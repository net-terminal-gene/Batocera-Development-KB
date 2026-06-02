# SNES (snes9x) — autoconfig spec (vanilla vertical)

## Canonical prior art

Cabinet-tested **`batocera.conf`** block, tuning log, and “do not use **`256x448`** on this chain” note:  
[snes-vertical-vanilla-v43.md](../../2026-05-20_crt-vanilla-vertical-portable/research/snes-vertical-vanilla-v43.md)

## Config paths (Batocera)

| Layer | Path |
|-------|------|
| System keys | `/userdata/system/batocera.conf` prefix **`snes.`** (and optionally **`snes-msu1.`**) |
| RetroArch per-content (Batocera append) | `/userdata/system/configs/retroarch/config/snes/<ROM display name>.cfg` |
| RetroArch per-core (common overrides) | `/userdata/system/configs/retroarch/config/Snes9x/` (matches snes9x core content dir naming) |
| Core options file | `/userdata/system/configs/retroarch/cores/retroarch-core-options.cfg` (**`snes9x_gfx_clip`**, etc.) |

**Default core:** `snes9x` (`configgen-defaults.yml`). Script must not assume `snes9x_next` or `bsnes` unless the manifest or installer profile says so.

## Script should implement

1. **Merge or append** (idempotent) under `/userdata/system/batocera.conf`:

   ```ini
   snes.videomode=<from listModes; see mode selection below>
   snes.ratio=full
   snes.retroarch.crt_switch_resolution = 0
   snes.retroarch.video_crop_overscan = false
   snes.retroarchcore.snes9x_gfx_clip=disabled
   ```

2. **`snes.videomode` selection (runtime):**

   - **Preferred (this cabinet’s validated path):** pick the first **`256x256.*`** token from `DISPLAY=:0 batocera-resolution listModes` (example: **`256x256.60.00006`**). Use when the preset targets **`ratio=full`** on a **vertical** stack like the test rig.
   - **Fallback A:** if no `256x256.*`, try **`256x240.*`**, then **`256x224.*`** (same family as PCE).
   - **Do not auto-pick** **`256x448.*`** for this vertical preset unless a **separate** hardware profile manifest says it is safe (on the reference cabinet it **broke** geometry: giant **left** bar, heavy loss of picture).

3. **`crt_switch_resolution = 0`:** required when global CRT SwitchRes is enabled, same rationale as [vectrex-vertical-autoconfig.md](vectrex-vertical-autoconfig.md).

4. **`video_crop_overscan = false`:** keep in the default merge unless a manifest row opts out (edge case).

5. **`retroarchcore.snes9x_gfx_clip=disabled`:** ensures configgen writes **`snes9x_gfx_clip`** off in **`retroarch-core-options.cfg`**; script may also **sed** the file idempotently to `"disabled"` so an old `enabled` line cannot win.

6. **Optional:** duplicate the **five** lines for **`snes-msu1.`** when that system exists and policy says “mirror SNES”.

7. **Do not** emit **`snes["*.zip"].videomode=`** unless the manifest marks an exception.

8. **RetroArch optional layer:** create **`snes/<ROM>.cfg`** or **`Snes9x/<ROM>.cfg`** only when manifest requests `video_rotation`, integer scale, etc. Default v1 = **no** per-title files.

9. **Subsystem filter:** `--only=snes` touches **`snes.*`** / **`snes-msu1.*`** only; no edits to `pcengine*`, `vectrex*`, `fbneo*`, `mame*`, or unrelated **`global.*`**.

## Manifest format (optional)

| Column | Meaning |
|--------|---------|
| `rom_basename` | e.g. `Super Smash T.V..zip` |
| `videomode` | optional override from `listModes` |
| `video_rotation` | optional `0`–`3` |

Empty manifest: **no** per-ROM cfg writes.

## Validation targets for script

- [ ] Dry-run shows only **`snes.*`** (and optional **`snes-msu1.*`**) delta.
- [ ] Launch one vertical shmup + one possible horizontal exception; geometry and sync OK with global CRT SwitchRes still on.
- [ ] Re-run idempotent; ES restart documented after apply.

## See also

- [pcengine-vertical-autoconfig.md](pcengine-vertical-autoconfig.md) (PCE often stays on **`256x224.*`** + **`core`**; SNES **`full`** preset may need a **taller** mode).
- [vectrex-vertical-autoconfig.md](vectrex-vertical-autoconfig.md) (**`crt_switch_resolution`** off pattern).
- [saturn-vertical-autoconfig.md](saturn-vertical-autoconfig.md), [dreamcast-vertical-autoconfig.md](dreamcast-vertical-autoconfig.md), [naomi-vertical-autoconfig.md](naomi-vertical-autoconfig.md), [psx-vertical-autoconfig.md](psx-vertical-autoconfig.md): non-geometry-class specs (state-injection / rotation-only / rotation + fill + custom viewport).
