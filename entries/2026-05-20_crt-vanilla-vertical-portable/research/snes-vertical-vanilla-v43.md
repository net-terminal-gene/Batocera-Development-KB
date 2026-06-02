# SNES (Super Nintendo) — vertical cabinet on vanilla Batocera v43

**Session:** [Vanilla vertical portable](../plan.md)  
**Default emulator (Batocera):** `libretro` + core **`snes9x`**, see `batocera.linux` `configgen-defaults.yml`  
**Related:** [PC Engine vertical](pcengine-vertical-vanilla-v43.md) (PCE on this cabinet uses **`256x224.60.00004`**; SNES vertical tuning **diverged** to a **taller** mode, see below), [Vectrex vertical](vectrex-vertical-vanilla-v43.md), [Saturn vertical](saturn-vertical-vanilla-v43.md), [Dreamcast vertical](dreamcast-vertical-vanilla-v43.md), [NAOMI vertical](naomi-vertical-vanilla-v43.md), [PSX vertical](psx-vertical-vanilla-v43.md); autoconfig spec [snes-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/snes-vertical-autoconfig.md).

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
3. Copied SNES ROMs (`.sfc`, `.smc`, `.zip`) to `/userdata/roms/snes/`. No BIOS required for SNES.

Everything below adds SNES vertical-shmup support on top of that baseline. It does not change any other system, the CRT display profile, or the global rotation; it only touches **five** `snes.*` keys (or `snes.retroarchcore.*` for the gfx_clip core option).

---

## Deployed policy (cabinet-tested, 2026-05-23)

**Cabinet:** `batocera.local` (vertical CRT, `display.rotate=1`).

**Decision:** One **global** SNES block: **taller** `videomode` than native 224 lines so **`ratio=full`** can fill without clipping the playfield; **CRT SwitchRes off** for this system; **no snes9x PPU gfx clip**; **no RetroArch overscan crop**.

**File:** `/userdata/system/batocera.conf`:

```ini
# SNES vertical CRT (cabinet-tested: full fill without bottom clip)
snes.videomode=256x256.60.00006
snes.ratio=full
snes.retroarch.crt_switch_resolution = 0
snes.retroarch.video_crop_overscan = false
snes.retroarchcore.snes9x_gfx_clip=disabled
```

**`snes.videomode=256x256.60.00006`:** chosen from **`batocera-resolution listModes`** on this device. **Not** the same token as PC Engine here (`256x224.60.00004`): with **`ratio=full`**, **`256x224`** tended to **crop the bottom** of 224-line content after rotation; **`256x240`** + **`core`** proved the framebuffer was intact; **`256x256` + `full`** was the best **fill vs sliver** trade. **`256x448.60.00007`** was **rejected** on this chain (large **left** bar, heavy picture loss).

**`snes.ratio=full`:** RetroArch **Full** aspect for fill (same class as [vectrex-vertical-vanilla-v43.md](vectrex-vertical-vanilla-v43.md)). If you need less stretch, try **`core`** or **`8/7`** and expect borders.

**`snes.retroarch.crt_switch_resolution = 0`:** **SNES-only** so RetroArch CRT SwitchRes does not fight **`snes.videomode`** while **`global.retroarch.crt_switch_resolution`** stays on for other cores.

**`snes.retroarch.video_crop_overscan = false`:** avoids RA trimming rows that still read as “game” on a CRT build.

**`snes.retroarchcore.snes9x_gfx_clip=disabled`:** maps into **`retroarch-core-options.cfg`** as **`snes9x_gfx_clip = "disabled"`**. With **`enabled`**, the core can **clip** drawable area at the edges (looked like bottom cut-off / sprites vanishing). The file was edited on-cabinet; the **`batocera.conf`** line keeps configgen aligned.

**Do not** casually add **`snes.retroarch.video_viewport_bias_y`**: a bad value **shifted** the picture and **reintroduced** edge loss during tuning.

## Tuning log (short, for the next agent)

| Step | Result |
|------|--------|
| `256x224` + `full` | Bottom **clipped** |
| `256x240` + `core` | Full game visible, **thick** letterbox |
| `256x240` + `full` | Better, still some clip |
| `256x256` + `full` | **Looks great**; optional **thin** slivers acceptable vs clip |
| `256x448` + `full` | **Bad** on this hardware (huge **left** bar, half picture wrong) → **reverted** to **`256x256`** |

## How “vertical” works for SNES here

SNES is still a **256×224**-class **horizontal** framebuffer for most titles. Cabinet **`display.rotate`** handles how the **desktop** is read; this block is about **timing + RA scaling + core clip policy**, not a second global rotation layer unless a title still needs **`snes.retroarch.video_rotation`**.

**RetroArch optional layer:** per-title tweaks under **`/userdata/system/configs/retroarch/config/Snes9x/`** or **`.../config/snes/<ROM>.cfg`** (Batocera append paths).

## Roster (this cabinet, `vertical`-style set)

| ROM (zip stem) | Notes |
|----------------|--------|
| Axelay.zip | Vertical-stage shmup |
| Caravan Shooting Collection.zip | STG compilation |
| Cosmo Gang - The Puzzle.zip | Puzzle |
| Cosmo Gang - The Video.zip | Action |
| DonkeyKongClassic (Shiru).zip | Homebrew |
| Firepower 2000.zip | Vertical STG |
| Flying Hero - Bugyuru no Daibouken.zip | Vertical |
| Imperium.zip | Vertical STG |
| Kaite Tsukutte Asoberu Dezaemon.zip | Tool |
| Nichibutsu Arcade Classics (Japan).zip | Compilation |
| Nichibutsu Arcade Classics 2 - Heiankyou Alien (Japan).zip | Compilation |
| Operation Logic Bomb - The Ultimate Search & Destroy.zip | Top-down / maze |
| Pop'n TwinBee.zip | Vertical cute-em-up |
| Raiden Densetsu.zip | Vertical STG |
| Shooting Monner (Dezaemon BS-X Hack).zip | Hack |
| Space Invaders.zip | Fixed shooter |
| Strike Gunner S.T.G.zip | Vertical STG |
| Super Aleste.zip | Vertical STG |
| Super Smash T.V..zip | Twin-stick arena (may want **horizontal** treatment) |
| Total Carnage.zip | Run-and-gun |

## MSU-1

If you use **`snes-msu1`** as a separate system in ES, mirror the **same five** keys with the **`snes-msu1.`** prefix.

## QA checklist

1. **`listModes`:** `export DISPLAY=:0; batocera-resolution listModes | grep '^256x'` and confirm **`256x256.60.00006`** exists (or retarget suffix if your `videomodes.conf` changes).
2. Launch **Pop'n TwinBee** or **Raiden Densetsu**, then a possible horizontal exception (**Super Smash T.V.**) if you need per-ROM tweaks.
3. After any `batocera.conf` edit: **`export DISPLAY=:0; batocera-es-swissknife --restart`**

## SSH note (`ssh-batocera.sh`)

If the first token looks like a **hostname** (even **`grep`**), the script treats it as the host. Use **`batocera.local`** before the remote command, e.g. `~/bin/ssh-batocera.sh batocera.local "grep …"`.

## Links

- PC Engine vertical (different `videomode` token on this cab): [pcengine-vertical-vanilla-v43.md](pcengine-vertical-vanilla-v43.md)
- Vectrex (CRT SwitchRes off pattern): [vectrex-vertical-vanilla-v43.md](vectrex-vertical-vanilla-v43.md)
- Autoconfig merge spec: [snes-vertical-autoconfig.md](../../2026-05-22_crt-vertical-autoconfig-script/research/snes-vertical-autoconfig.md)
