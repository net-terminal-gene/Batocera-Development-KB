# Vectrex — vertical cabinet on vanilla Batocera (vecx)

**Session:** [Vanilla vertical portable](../plan.md)  
**Default emulator (Batocera):** `libretro` + core **`vecx`**, see `batocera.linux` `configgen-defaults.yml`  
**Core geometry (reference):** Libretro docs list vecx **base width × height 869×1080**, **~59.72 Hz** ([Vectrex (vecx) — Libretro Docs](https://docs.libretro.com/library/vecx/)).  
**Related:** [PC Engine vertical](pcengine-vertical-vanilla-v43.md), [SNES vertical](snes-vertical-vanilla-v43.md), [Saturn vertical](saturn-vertical-vanilla-v43.md), [Dreamcast vertical](dreamcast-vertical-vanilla-v43.md), [NAOMI vertical](naomi-vertical-vanilla-v43.md), [PSX vertical](psx-vertical-vanilla-v43.md); autoconfig spec [vectrex-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/vectrex-vertical-autoconfig.md).

---

## Reading this from a fresh install

This doc assumes the operator has:

1. Flashed and booted **vanilla Batocera v43** on the cabinet hardware.
2. Run the **Batocera-CRT-Script v43 installer** and picked the **vertical / TATE** options. After reboot, the cabinet should have:
   - `display.rotate=1` in `/userdata/system/batocera.conf`
   - `global.videooutput=<your CRT output>` (e.g. `DP-1`)
   - `global.videomode=Boot_…` from the installer
   - The CRT display profile applied (`first_script.sh`, EDID, super-res ladder)
   - EmulationStation booting vertically at the cabinet's native CRT resolution
3. Copied Vectrex ROMs (`.zip` / `.vec` / `.bin`) to `/userdata/roms/vectrex/`. No BIOS required for vecx (the Vectrex ROM is built into the core).

Everything below adds Vectrex vertical support on top of that baseline. It does not change any other system, the CRT display profile, or the global rotation; it only touches **four** `vectrex.*` keys. Vectrex is unique among the per-core specs because the **vecx core needs its own RA rotation key** (`video_rotation = 3`) — unlike PCE / SNES where the global display rotation does the job, vecx with `display.rotate=1` leaves the portrait framebuffer drawn landscape.

---

## Why this is different from PCE on the same cabinet

The Vectrex panel was a **portrait** vector CRT. The vecx core exposes a **tall** base framebuffer (see link above). PC Engine vertical STGs mostly stay on a **wide** 256×224 (or 512-wide) plane and rely on **game design**, not a portrait framebuffer.

On a TATE build with **`display.rotate=1`**, Batocera often leaves **`video_rotation=0`** in RetroArch when **`batocera-resolution supportSystemRotation`** reports that the **display stack** already rotates (see `libretroConfig.py`: `display_rotate` only maps into `video_rotation` when `not supportSystemRotation()`). For **vecx**, that often leaves the **portrait** framebuffer looking **landscape** on the panel. Fix with a **Vectrex-only** override: **`vectrex.retroarch.video_rotation = 3`**, which matches Batocera’s own mapping for `display.rotate=1` when RetroArch is responsible for rotation (same file, `display_rotate == "1"` → `video_rotation` **3**). If the image is upside down, try **`1`** instead of **`3`**.

## Cabinet snapshot (2026-05-22, batocera.local)

| Item | Value |
|------|-------|
| `display.rotate` | **1** |
| `vectrex.videomode` | **`384x480.60.00028`** (plus RA overrides below, 2026-05-22) |
| ROMs present | **28** zips under `/userdata/roms/vectrex` (see roster below) |
| Batocera per-game cfg dir | `/userdata/system/configs/retroarch/config/vectrex/` (append `Game Name.zip.cfg`) |
| Batocera per-system cfg | `/userdata/system/configs/retroarch/config/vectrex.cfg` |

## Deploy policy — start here

**Goal:** one **global** 15 kHz timing for portrait Vectrex on vertical CRT, **fill** scaling, stable sync (no RA CRT SwitchRes fight), and correct **RetroArch rotation** when the display stack owns TATE rotation.

**File:** `/userdata/system/batocera.conf` (append near other system globals; adjust suffix after `listModes` if your `videomodes.conf` differs).

```ini
# Vectrex (vecx) — portrait timing + stable sync + rotation (vertical CRT)
vectrex.videomode=384x480.60.00028
vectrex.ratio=full
vectrex.retroarch.crt_switch_resolution = 0
vectrex.retroarch.video_rotation = 3
```

**`vectrex.ratio=full`:** scales the core image to **fill** the active output (RetroArch **Full** aspect). Use this when **`core`** leaves the picture **too small** in the letterboxed area. If vectors look **stretched**, try **`vectrex.ratio=9/16`** (portrait-friendly) or return to **`core`** and instead bump **`vectrex.videomode`** toward a taller line count (e.g. **`384x512.60.00029`**) so the CRT raster matches what you want.

**`vectrex.retroarch.crt_switch_resolution = 0`:** turns off RetroArch CRT SwitchRes **for this system only** so it does not fight the fixed **`vectrex.videomode`** (fixes rolling / unstable sync when global `crt_switch_resolution` is on).

**`vectrex.retroarch.video_rotation = 3`:** portrait vecx on a **`display.rotate=1`** stack where the display layer owns rotation (see above). **Vectrex-only:** does not change FBNeo, PCE, MAME, or other systems.

**Mode string:** `384x480.60.00028` was picked from **`batocera-resolution listModes`** on this device (same style as `pcengine.videomode` in [pcengine-vertical-vanilla-v43.md](pcengine-vertical-vanilla-v43.md)). Alternates on the same machine if geometry feels tight or overscanned:

- `384x512.60.00029`
- `320x512.60.00017`
- `256x512.60.00008`

Re-run `listModes` after CRT Script or GPU profile changes.

## Core options (Batocera)

Configgen wires **`vecx_res_multi`** from system key **`res_multi`** (default **1**) in `libretroOptions.py` (`_vecx_options`). If exposed in your build’s ES advanced options, keeping **1** on real CRT is usually safest for sharp vectors; raise only if you accept softer, higher internal resolution.

Hardware vecx options (render resolution, bloom, etc.) live in RetroArch **Quick Menu → Options** or in **`retroarch-core-options.cfg`**; avoid duplicating here unless a title needs a documented tweak.

## ROM roster (this cabinet)

Names are ES/Batocera stems (zip basename). All are the stock No-Intro style set under `/userdata/roms/vectrex/`:

| ROM (zip stem) |
|----------------|
| 3D Narrow Escape |
| Armor Attack |
| Bedlam |
| Berzerk |
| Blitz! - Action Football |
| Clean Sweep |
| Cosmic Chasm |
| Dark Tower |
| Fortress of Narzod |
| Heads-Up - Action Soccer |
| HyperChase - Auto Race |
| Mine Storm |
| Mine Storm II |
| Pitcher's Duel |
| Polar Rescue |
| Pole Position |
| Rip Off |
| Scramble |
| Solar Quest |
| Space Wars |
| Spike |
| Spin ball |
| Star Castle |
| Star Ship |
| Star Trek - The Motion Picture |
| StarHawk |
| Tour De France |
| WebWarp |

## Batocera `vectrex.csv` (bezels / shaders only)

`batocera.linux` ships `package/batocera/core/batocera-configgen/data/special/vectrex.csv`. **`getAltDecoration()`** uses it to return an **overlay nickname** for shaders and bezels, **not** a `90` / `270` rotation table (see comment in `videoMode.py`). Do not assume that file defines TATE rotation for vecx.

## QA checklist (vanilla)

1. Append the full **`vectrex.*`** block above (timing, ratio, **`crt_switch_resolution`**, **`video_rotation`**); keep **`display.rotate`** consistent with the rest of the vertical build.
2. Launch **Mine Storm** (built-in style) or **Spike**, then **Pole Position** (faster refresh feel, wider playfield).
3. If the image is **letterboxed** wrongly, try the alternate **`384x512`** or **`320x512`** mode strings from `listModes`.
4. If **Ozone** still feels wrong while the game is correct, same class of issue as FBNeo on this stack: prefer **RGUI** (`global.retroarch.menu_driver=rgui` is already set on this cabinet) or document an X11-only mitigation (see open FBNeo notes in the handoff).
5. After edits: **`export DISPLAY=:0; batocera-es-swissknife --restart`** (avoid `killall -9 emulationstation` when possible).

## Myzar note (do not copy blindly)

The Myzar hybrid session logged a **broken Switchres parse** for Vectrex (`x.60.00` style) and suggested **`384x480`** / **`400x512`** class timings as candidates. On **this** vanilla cabinet, **`384x480.*`** and **`384x512.*`** already appear as **full** `listModes` keys; use those verbatim instead of inventing shortened tokens.

## Links

- PCE vertical policy (same `batocera.conf` pattern): [pcengine-vertical-vanilla-v43.md](pcengine-vertical-vanilla-v43.md)
- **Autoconfig generator spec (CRT Script):** [vectrex-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/vectrex-vertical-autoconfig.md)
- Myzar timing table (reference only): [emulator-expected-resolutions.md](../../2026-05-21_crt-myzar-dp-hybrid-switchres/research/emulator-expected-resolutions.md)
- vecx geometry and options: [Libretro vecx documentation](https://docs.libretro.com/library/vecx/)
